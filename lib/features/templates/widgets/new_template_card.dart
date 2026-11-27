import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class NewTemplateCard extends StatefulWidget {
  const NewTemplateCard({
    super.key,
    required this.sources,
    required this.categories,
    required this.onSave,
  });

  final List<Source> sources;
  final List<Category> categories;
  final VoidCallback onSave;

  @override
  State<NewTemplateCard> createState() => _NewTemplateCardState();
}

class _NewTemplateCardState extends State<NewTemplateCard> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();

  TxType _type = TxType.expense;
  String _sourceId = 'vr';
  String? _categoryId = 'utilities';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        widget.categories.where((c) => c.kind == _type).toList();
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
                    if (v != null) setState(() => _sourceId = v);
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
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
              ),
              Expanded(
                child: AppTextField(
                  label: 'Default amount (optional)',
                  hintText: 'Ask each time',
                  controller: _amount,
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
          AppButton(
            label: 'Save template',
            size: AppButtonSize.large,
            expand: true,
            onPressed: widget.onSave,
          ),
        ],
      ),
    );
  }
}
