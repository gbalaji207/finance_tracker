import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/template_input.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/entry_validation.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/labeled_checkbox.dart';
import 'package:finance_tracker/core/widgets/side_drawer.dart';
import 'package:finance_tracker/core/widgets/type_selector.dart';
import 'package:flutter/material.dart';

/// Adds a template. Meant to sit inside a [SideDrawer]; [onClose] closes it
/// after a save or a cancel.
class TemplateForm extends StatefulWidget {
  const TemplateForm({
    super.key,
    required this.sources,
    required this.categories,
    required this.nextSortOrder,
    required this.onSave,
    required this.onClose,
  });

  /// Active sources and categories only.
  final List<Source> sources;
  final List<Category> categories;

  /// The sort order given to the new template.
  final int nextSortOrder;

  /// Saves the template. Resolves to an error message, or null on success.
  final Future<String?> Function(TemplateInput input) onSave;

  final VoidCallback onClose;

  @override
  State<TemplateForm> createState() => _TemplateFormState();
}

class _TemplateFormState extends State<TemplateForm> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();

  TxType _type = TxType.expense;

  /// Source and category start empty on purpose: a preselected first item led
  /// to wrong entries, so both must be chosen (the form validates on save).
  String _sourceId = '';
  String? _categoryId;
  bool _quickAdd = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  /// A category belongs to one kind, so changing the type drops the chosen
  /// category and it has to be chosen again.
  void _selectType(TxType type) {
    setState(() {
      _type = type;
      _categoryId = null;
      _error = null;
    });
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  /// The first problem with the form, or null.
  String? _validate() {
    if (_name.text.trim().isEmpty) return 'Enter a template name.';
    if (_sourceId.isEmpty) return 'Select a source.';
    if (_type != TxType.income && _categoryId == null) {
      return 'Select a category.';
    }
    if (_amount.text.trim().isNotEmpty) {
      final amount = parseAmount(_amount.text);
      if (amount == null || amount <= 0) {
        return 'Default amount must be above zero.';
      }
    }
    return null;
  }

  Future<void> _save() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() => _saving = true);
    final input = TemplateInput(
      name: _name.text.trim(),
      type: _type,
      sourceId: _sourceId,
      categoryId: _type == TxType.income ? null : _categoryId,
      amount: _amount.text.trim().isEmpty ? null : parseAmount(_amount.text),
      description: _description.text.trim(),
      quickAdd: _quickAdd,
      sortOrder: widget.nextSortOrder,
    );
    final error = await widget.onSave(input);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      AppSnack.error(context, error);
      return;
    }
    AppSnack.info(context, AppConfig.note('Template saved'));
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories.where((c) => c.kind == _type).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Padding(
          padding: SideDrawer.titleGap,
          child: Text('New template', style: AppTextStyles.sectionTitle),
        ),
        AppTextField(
          label: 'Template name',
          hintText: 'e.g. Internet bill',
          controller: _name,
          onChanged: (_) => _clearError(),
        ),
        TypeSelector(label: 'Type', value: _type, onChanged: _selectType),
        AppDropdown<String>(
          label: 'Source',
          hintText: 'Select',
          // An empty id means nothing is chosen yet.
          value: _sourceId.isEmpty ? null : _sourceId,
          items: [
            for (final s in widget.sources) AppDropdownItem(s.id, s.name),
          ],
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _sourceId = v;
                _error = null;
              });
            }
          },
        ),
        if (_type != TxType.income)
          AppDropdown<String>(
            label: 'Category',
            hintText: 'Select',
            helperText: 'Hidden for income templates.',
            value: _categoryId,
            items: [for (final c in categories) AppDropdownItem(c.id, c.name)],
            onChanged: (v) => setState(() {
              _categoryId = v;
              _error = null;
            }),
          ),
        AppTextField(
          label: 'Default amount (optional)',
          hintText: 'Ask each time',
          controller: _amount,
          onChanged: (_) => _clearError(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        AppTextField(
          label: 'Description',
          hintText: 'Pre-filled description',
          controller: _description,
        ),
        LabeledCheckbox(
          value: _quickAdd,
          onChanged: (v) => setState(() => _quickAdd = v),
          label: Text('Show in Dashboard quick add', style: AppTextStyles.body),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            AppButton(
              label: 'Save template',
              size: AppButtonSize.large,
              expand: true,
              onPressed: _saving ? null : _save,
            ),
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.large,
              expand: true,
              onPressed: _saving ? null : widget.onClose,
            ),
          ],
        ),
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
  }
}
