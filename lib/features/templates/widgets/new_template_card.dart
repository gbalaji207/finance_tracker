import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/template_input.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/entry_validation.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/labeled_checkbox.dart';
import 'package:flutter/material.dart';

class NewTemplateCard extends StatefulWidget {
  const NewTemplateCard({
    super.key,
    required this.sources,
    required this.categories,
    required this.nextSortOrder,
    required this.onSave,
  });

  /// Active sources and categories only.
  final List<Source> sources;
  final List<Category> categories;

  /// The sort order given to the new template.
  final int nextSortOrder;

  /// Saves the template. Resolves to an error message, or null on success.
  final Future<String?> Function(TemplateInput input) onSave;

  @override
  State<NewTemplateCard> createState() => _NewTemplateCardState();
}

class _NewTemplateCardState extends State<NewTemplateCard> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();

  TxType _type = TxType.expense;
  late String _sourceId;
  String? _categoryId;
  bool _quickAdd = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // No hardcoded ids: the first source and first expense category.
    _sourceId = widget.sources.isEmpty ? '' : widget.sources.first.id;
    _categoryId = _firstCategory(TxType.expense);
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  /// First category of [type], or null for income (which has none).
  String? _firstCategory(TxType type) {
    if (type == TxType.income) return null;
    for (final c in widget.categories) {
      if (c.kind == type) return c.id;
    }
    return null;
  }

  void _selectType(TxType? type) {
    if (type == null) return;
    setState(() {
      _type = type;
      _categoryId = _firstCategory(type);
      _error = null;
    });
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  /// The first problem with the form, or null.
  String? _validate() {
    if (_name.text.trim().isEmpty) return 'Enter a template name.';
    if (_sourceId.isEmpty) return 'Choose a source.';
    if (_type != TxType.income && _categoryId == null) {
      return 'Choose a category.';
    }
    if (_amount.text.trim().isNotEmpty) {
      final amount = parseAmount(_amount.text);
      if (amount == null || amount <= 0) {
        return 'Default amount must be above zero.';
      }
    }
    return null;
  }

  void _resetForm() {
    _name.clear();
    _amount.clear();
    _description.clear();
    setState(() {
      _type = TxType.expense;
      _sourceId = widget.sources.isEmpty ? '' : widget.sources.first.id;
      _categoryId = _firstCategory(TxType.expense);
      _quickAdd = false;
      _error = null;
    });
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
    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories.where((c) => c.kind == _type).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text('New template', style: AppTextStyles.sectionTitle),
          AppTextField(
            label: 'Template name',
            hintText: 'e.g. Internet bill',
            controller: _name,
            onChanged: (_) => _clearError(),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s12,
            children: [
              Expanded(
                child: AppDropdown<TxType>(
                  label: 'Type',
                  value: _type,
                  items: [
                    for (final t in TxType.values) AppDropdownItem(t, t.label),
                  ],
                  onChanged: _selectType,
                ),
              ),
              Expanded(
                child: AppDropdown<String>(
                  label: 'Source',
                  value: _sourceId,
                  items: [
                    for (final s in widget.sources)
                      AppDropdownItem(s.id, s.name),
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
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s12,
            children: [
              Expanded(
                child: _type == TxType.income
                    ? const SizedBox.shrink()
                    : AppDropdown<String>(
                        label: 'Category',
                        value: _categoryId,
                        items: [
                          for (final c in categories)
                            AppDropdownItem(c.id, c.name),
                        ],
                        onChanged: (v) => setState(() {
                          _categoryId = v;
                          _error = null;
                        }),
                      ),
              ),
              Expanded(
                child: AppTextField(
                  label: 'Default amount (optional)',
                  hintText: 'Ask each time',
                  controller: _amount,
                  onChanged: (_) => _clearError(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          AppTextField(
            label: 'Description',
            hintText: 'Pre-filled description',
            controller: _description,
          ),
          LabeledCheckbox(
            value: _quickAdd,
            onChanged: (v) => setState(() => _quickAdd = v),
            label: Text(
              'Show in Dashboard quick add',
              style: AppTextStyles.body,
            ),
          ),
          AppButton(
            label: 'Save template',
            size: AppButtonSize.large,
            expand: true,
            onPressed: _saving ? null : _save,
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
      ),
    );
  }
}
