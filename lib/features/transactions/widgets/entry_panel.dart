import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/entry_input.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/utils/entry_validation.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_date_field.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/type_selector.dart';
import 'package:finance_tracker/features/transactions/cubit/add_entry_cubit.dart';
import 'package:finance_tracker/features/transactions/cubit/add_entry_state.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The right-hand panel: "New entry" by default, "Edit entry" when
/// [editing] is set. The page gives it `key: ValueKey(editing?.id ?? 'new')`
/// so the text controllers are initialised again for each entry.
class EntryPanel extends StatefulWidget {
  const EntryPanel({
    super.key,
    required this.templates,
    required this.sourceName,
    required this.sources,
    required this.categories,
    required this.onDelete,
    this.onClose,
    this.editing,
    this.initialTemplate,
  });

  /// Called when the form is finished and its drawer should close: after
  /// "Save entry", "Save changes", "Cancel" and a confirmed delete.
  final VoidCallback? onClose;

  final List<EntryTemplate> templates;
  final String Function(String sourceId) sourceName;

  /// Active sources, plus the archived one the edited entry uses (if any).
  final List<Source> sources;

  /// Active categories, plus the archived one the edited entry uses (if any).
  final List<Category> categories;

  /// The entry being edited; null for add mode.
  final Transaction? editing;

  /// A template to apply once when the panel first appears.
  final EntryTemplate? initialTemplate;

  /// Asks for confirmation and resolves to true when the entry should be
  /// deleted. The page implements it (it needs the repository), so the panel
  /// itself stays free of data access.
  final Future<bool> Function(Transaction entry) onDelete;

  @override
  State<EntryPanel> createState() => _EntryPanelState();
}

class _EntryPanelState extends State<EntryPanel> {
  late final TextEditingController _amount;
  late final TextEditingController _description;
  final _amountFocus = FocusNode();

  /// The template last chosen in the "Fill from template" dropdown.
  String? _templateId;

  /// Validation message shown under the buttons.
  String? _error;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _amount = TextEditingController(
      text: editing == null ? '' : editing.amount.toStringAsFixed(0),
    );
    _description = TextEditingController(text: editing?.description ?? '');
    final template = widget.initialTemplate;
    if (template != null && editing == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyTemplate(template.id);
      });
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  void _applyTemplate(String? id) {
    if (id == null) return;
    final template = widget.templates.firstWhere((t) => t.id == id);
    final applied = context.read<AddEntryCubit>().applyTemplate(template);
    setState(() => _templateId = id);
    _amount.text = applied.amount?.toStringAsFixed(0) ?? '';
    _description.text = applied.description;
  }

  /// Validates the form; returns the input to save, or null after showing the
  /// problem.
  EntryInput? _buildInput() {
    final form = context.read<AddEntryCubit>().state;
    final problem = validateEntry(
      amountText: _amount.text,
      sourceId: form.sourceId,
      type: form.type,
      categoryId: form.categoryId,
    );
    if (problem != null) {
      setState(() => _error = problem);
      return null;
    }
    return EntryInput(
      date: form.date,
      type: form.type,
      sourceId: form.sourceId,
      categoryId: form.type == TxType.income ? null : form.categoryId,
      amount: parseAmount(_amount.text)!,
      description: _description.text.trim(),
    );
  }

  /// Add mode. [addAnother] keeps type, source, category and date and moves
  /// focus to the amount field; otherwise the form returns to its defaults.
  Future<void> _save({required bool addAnother}) async {
    final input = _buildInput();
    if (input == null) return;
    final error = await context.read<TransactionsCubit>().addEntry(input);
    if (!mounted) return;
    if (error != null) {
      AppSnack.error(context, error);
      return;
    }
    AppSnack.info(context, AppConfig.note('Entry saved'));
    _amount.clear();
    _description.clear();
    setState(() => _templateId = null);
    if (addAnother) {
      _amountFocus.requestFocus();
    } else {
      context.read<AddEntryCubit>().reset();
      widget.onClose?.call();
    }
  }

  Future<void> _saveChanges() async {
    final editing = widget.editing;
    if (editing == null) return;
    final input = _buildInput();
    if (input == null) return;
    final error = await context.read<TransactionsCubit>().updateEntry(
      editing.id,
      input,
    );
    if (!mounted) return;
    if (error != null) {
      AppSnack.error(context, error);
      return;
    }
    AppSnack.info(context, AppConfig.note('Changes saved'));
    _leaveEditMode();
  }

  /// Leaving edit mode: clear the selection, reset the form and close.
  void _leaveEditMode() {
    context.read<TransactionsCubit>().select(null);
    context.read<AddEntryCubit>().reset();
    widget.onClose?.call();
  }

  Future<void> _delete() async {
    final editing = widget.editing;
    if (editing == null) return;
    final confirmed = await widget.onDelete(editing);
    if (!confirmed || !mounted) return;
    final error = await context.read<TransactionsCubit>().deleteEntry(
      editing.id,
    );
    if (!mounted) return;
    if (error != null) {
      AppSnack.error(context, error);
      return;
    }
    AppSnack.info(context, AppConfig.note('Entry deleted'));
    _leaveEditMode();
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select<TransactionsCubit, bool>(
      (c) => c.state.saving,
    );
    return BlocConsumer<AddEntryCubit, AddEntryState>(
      listener: (context, state) => _clearError(),
      builder: (context, state) {
        final cubit = context.read<AddEntryCubit>();
        final categories = widget.categories
            .where((c) => c.kind == state.type)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            _header(),
            TypeSelector(
              label: 'Type',
              value: state.type,
              onChanged: cubit.selectType,
            ),
            if (!_isEditing)
              AppDropdown<String>(
                label: 'Fill from template (optional)',
                hintText: 'Choose a template…',
                value: _templateId,
                items: [
                  for (final t in widget.templates)
                    AppDropdownItem(
                      t.id,
                      '${t.name} · ${widget.sourceName(t.sourceId)}',
                    ),
                ],
                onChanged: _applyTemplate,
              ),
            AppDropdown<String>(
              label: 'Source',
              hintText: 'Select',
              // An empty id means nothing is chosen yet.
              value: state.sourceId.isEmpty ? null : state.sourceId,
              items: [
                for (final s in widget.sources) AppDropdownItem(s.id, s.name),
              ],
              onChanged: (v) {
                if (v != null) cubit.selectSource(v);
              },
            ),
            if (state.type != TxType.income)
              AppDropdown<String>(
                label: 'Category',
                hintText: 'Select',
                helperText: 'Hidden for income entries.',
                value: state.categoryId,
                items: [
                  for (final c in categories) AppDropdownItem(c.id, c.name),
                ],
                onChanged: cubit.selectCategory,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s12,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Amount (₹)',
                    hintText: '0',
                    controller: _amount,
                    focusNode: _amountFocus,
                    onChanged: (_) => _clearError(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                Expanded(
                  child: AppDateField(
                    label: 'Date',
                    value: state.date,
                    onChanged: cubit.selectDate,
                  ),
                ),
              ],
            ),
            AppTextField(
              label: 'Description',
              hintText: 'Where it went, e.g. SBI FD',
              controller: _description,
              onChanged: (_) => _clearError(),
            ),
            ..._buttons(saving),
            if (_error != null)
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _header() {
    final editing = widget.editing;
    // Leaves room on the right for the drawer's close button.
    const closeGap = EdgeInsets.only(right: 40);
    if (editing == null) {
      return Padding(
        padding: closeGap,
        child: Text('New entry', style: AppTextStyles.sectionTitle),
      );
    }
    return Padding(
      padding: closeGap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit entry', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.s4),
          Text(
            '${editing.description} · ${AppDates.dayMonthYear(editing.date)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  List<Widget> _buttons(bool saving) {
    if (!_isEditing) {
      return [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s8,
          children: [
            AppButton(
              label: 'Save entry',
              size: AppButtonSize.large,
              expand: true,
              onPressed: saving ? null : () => _save(addAnother: false),
            ),
            AppButton(
              label: 'Save and add another',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.large,
              expand: true,
              onPressed: saving ? null : () => _save(addAnother: true),
            ),
          ],
        ),
      ];
    }
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s8,
        children: [
          AppButton(
            label: 'Save changes',
            size: AppButtonSize.large,
            expand: true,
            onPressed: saving ? null : _saveChanges,
          ),
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.large,
            expand: true,
            onPressed: saving ? null : _leaveEditMode,
          ),
        ],
      ),
      Container(
        padding: const EdgeInsets.only(top: 14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: AppButton(
          label: 'Delete entry',
          variant: AppButtonVariant.dangerOutline,
          expand: true,
          onPressed: saving ? null : _delete,
        ),
      ),
    ];
  }
}
