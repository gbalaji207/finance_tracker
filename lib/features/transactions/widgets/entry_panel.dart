import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_date_field.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
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
    this.editing,
  });

  final List<EntryTemplate> templates;
  final String Function(String sourceId) sourceName;
  final List<Source> sources;
  final List<Category> categories;

  /// The entry being edited; null for add mode.
  final Transaction? editing;

  @override
  State<EntryPanel> createState() => _EntryPanelState();
}

class _EntryPanelState extends State<EntryPanel> {
  late final TextEditingController _amount;
  late final TextEditingController _description;

  /// The template last chosen in the "Fill from template" dropdown.
  String? _templateId;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _amount = TextEditingController(
      text: editing == null ? '' : editing.amount.toStringAsFixed(0),
    );
    _description = TextEditingController(text: editing?.description ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _applyTemplate(String? id) {
    if (id == null) return;
    final template = widget.templates.firstWhere((t) => t.id == id);
    final applied = context.read<AddEntryCubit>().applyTemplate(template);
    setState(() => _templateId = id);
    _amount.text = applied.amount?.toStringAsFixed(0) ?? '';
    _description.text = applied.description;
  }

  /// Add mode: show the message, then clear the form.
  void _save() {
    _showMessage('Saved (sample data, nothing is stored yet)');
    context.read<AddEntryCubit>().reset();
    _amount.clear();
    _description.clear();
    setState(() => _templateId = null);
  }

  /// Leaving edit mode: clear the selection and reset the form.
  void _leaveEditMode() {
    context.read<TransactionsCubit>().select(null);
    context.read<AddEntryCubit>().reset();
  }

  void _saveChanges() {
    _showMessage('Changes saved (sample data, nothing is stored yet)');
    _leaveEditMode();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddEntryCubit, AddEntryState>(
      builder: (context, state) {
        final cubit = context.read<AddEntryCubit>();
        final categories = widget.categories
            .where((c) => c.kind == state.type)
            .toList();
        return AppCard(
          borderColor: AppColors.primary,
          child: Column(
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
                value: state.sourceId,
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
              ),
              ..._buttons(),
              if (!_isEditing)
                Text(
                  'Keyboard: N new entry · Enter save · Esc close',
                  style: AppTextStyles.caption,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _header() {
    final editing = widget.editing;
    if (editing == null) {
      return Text('New entry', style: AppTextStyles.sectionTitle);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Edit entry', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.s4),
        Text(
          '${editing.description} · ${AppDates.dayMonthYear(editing.date)}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  List<Widget> _buttons() {
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
              onPressed: _save,
            ),
            AppButton(
              label: 'Save and add another',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.large,
              expand: true,
              onPressed: _save,
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
            onPressed: _saveChanges,
          ),
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.large,
            expand: true,
            onPressed: _leaveEditMode,
          ),
        ],
      ),
      Container(
        padding: const EdgeInsets.only(top: 14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        // Until the delete dialog exists this only shows a message.
        child: AppButton(
          label: 'Delete entry',
          variant: AppButtonVariant.dangerOutline,
          expand: true,
          onPressed: () => _showMessage('Not wired yet (sample data)'),
        ),
      ),
    ];
  }
}
