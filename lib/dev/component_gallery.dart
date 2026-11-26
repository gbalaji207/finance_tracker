import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_date_field.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/core/widgets/labeled_checkbox.dart';
import 'package:finance_tracker/core/widgets/type_selector.dart';
import 'package:flutter/material.dart';

/// Temporary gallery of reusable components. Extended in spec 04.
class ComponentGallery extends StatefulWidget {
  const ComponentGallery({super.key});

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  String? _source = 'bank';
  DateTime _date = DateTime(2026, 11, 26);
  TxType _type = TxType.expense;
  bool _checkA = true;
  bool _checkB = false;

  void _notWired() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Not wired yet (sample data)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s32,
              children: [
                Text('Inputs', style: AppTextStyles.pageTitle),
                _section('Buttons', [
                  for (final variant in AppButtonVariant.values)
                    Wrap(
                      spacing: AppSpacing.s12,
                      runSpacing: AppSpacing.s12,
                      children: [
                        for (final size in AppButtonSize.values)
                          AppButton(
                            label: '${variant.name} ${size.name}',
                            variant: variant,
                            size: size,
                            onPressed: _notWired,
                          ),
                      ],
                    ),
                  const AppButton(label: 'Disabled primary', onPressed: null),
                  AppButton(
                    label: 'Expanded primary',
                    expand: true,
                    onPressed: _notWired,
                  ),
                ]),
                _section('Link', [
                  AppTextLink(label: 'View all', onPressed: _notWired),
                ]),
                _section('Fields', [
                  const AppTextField(label: 'Description', hintText: 'e.g. Groceries'),
                  const AppTextField(
                    label: 'Amount',
                    hintText: '0',
                    helperText: 'Enter the amount in rupees',
                    keyboardType: TextInputType.number,
                  ),
                  AppDropdown<String>(
                    label: 'Source',
                    value: _source,
                    items: const [
                      AppDropdownItem('bank', 'Bank account'),
                      AppDropdownItem('cash', 'Cash'),
                      AppDropdownItem('card', 'Credit card'),
                    ],
                    onChanged: (v) => setState(() => _source = v),
                  ),
                  AppDropdown<String>(
                    label: 'Category',
                    hintText: 'Select a category',
                    items: const [
                      AppDropdownItem('food', 'Food'),
                      AppDropdownItem('rent', 'Rent'),
                    ],
                    onChanged: (_) {},
                  ),
                  AppDateField(
                    label: 'Date',
                    value: _date,
                    onChanged: (d) => setState(() => _date = d),
                  ),
                ]),
                _section('Type selector', [
                  TypeSelector(
                    label: 'Type',
                    value: _type,
                    onChanged: (t) => setState(() => _type = t),
                  ),
                ]),
                _section('Checkboxes', [
                  LabeledCheckbox(
                    value: _checkA,
                    onChanged: (v) => setState(() => _checkA = v),
                    label: Text('Include in report', style: AppTextStyles.body),
                  ),
                  LabeledCheckbox(
                    value: _checkB,
                    onChanged: (v) => setState(() => _checkB = v),
                    label: Text('Repeat every month', style: AppTextStyles.body),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s12,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          ...children,
        ],
      );
}
