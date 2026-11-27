import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/amount_text.dart';
import 'package:finance_tracker/core/widgets/app_badge.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_dialog.dart';
import 'package:finance_tracker/core/widgets/info_box.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/category_bar_row.dart';
import 'package:finance_tracker/core/widgets/key_value_row.dart';
import 'package:finance_tracker/core/widgets/kpi_tile.dart';
import 'package:finance_tracker/core/widgets/responsive_wrap.dart';
import 'package:finance_tracker/core/widgets/section_header.dart';
import 'package:finance_tracker/core/widgets/status_pill.dart';
import 'package:finance_tracker/core/widgets/two_pane.dart';
import 'package:finance_tracker/core/widgets/type_badge.dart';
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
                Text('Display', style: AppTextStyles.pageTitle),
                _section('Cards and badges', [
                  AppCard(
                    child: SectionHeader(
                      title: 'Recent entries',
                      actionLabel: 'View all',
                      onAction: _notWired,
                    ),
                  ),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      for (final t in TxType.values) TypeBadge(t),
                    ],
                  ),
                  const Wrap(
                    spacing: AppSpacing.s16,
                    runSpacing: AppSpacing.s8,
                    children: [
                      AmountText(amount: 45000, type: TxType.income),
                      AmountText(amount: 32000, type: TxType.expense),
                      AmountText(amount: 20000, type: TxType.investment),
                      AmountText(amount: 0, type: TxType.savings),
                    ],
                  ),
                ]),
                _section('KPI tiles', [
                  const ResponsiveWrap(
                    minItemWidth: 170,
                    children: [
                      KpiTile(label: 'Income', value: '₹1,32,400'),
                      KpiTile(label: 'Expenses', value: '₹68,500'),
                      KpiTile(label: 'Investments', value: '₹20,000'),
                      KpiTile(label: 'Savings', value: '₹15,000'),
                      KpiTile(label: 'Net', value: '₹28,900'),
                    ],
                  ),
                ]),
                _section('Key-value rows and status', [
                  const AppCard(
                    child: Column(
                      spacing: AppSpacing.s8,
                      children: [
                        KeyValueRow(label: 'Opening balance', value: '₹50,000'),
                        KeyValueRow(
                          label: 'Received this month',
                          value: '+₹45,000',
                          valueColor: AppColors.income,
                        ),
                      ],
                    ),
                  ),
                  const Wrap(
                    spacing: AppSpacing.s12,
                    children: [
                      StatusPill(text: 'Matches'),
                      StatusPill(text: 'Needs review', tone: StatusTone.warning),
                    ],
                  ),
                ]),
                _section('Category bars', [
                  const CategoryBarRow(
                    label: 'Rent',
                    amountText: '₹32,000',
                    fraction: 1.0,
                  ),
                  const CategoryBarRow(
                    label: 'Groceries',
                    amountText: '₹15,000',
                    fraction: 0.47,
                  ),
                  const CategoryBarRow(
                    label: 'Transport',
                    amountText: '₹9,000',
                    fraction: 0.28,
                  ),
                ]),
                _section('Two pane', [
                  const TwoPane(
                    primaryMin: 300,
                    secondaryMin: 200,
                    primary: AppCard(
                      child: SizedBox(height: 160, child: Text('Primary pane')),
                    ),
                    secondary: AppCard(
                      child: SizedBox(height: 80, child: Text('Secondary pane')),
                    ),
                  ),
                ]),
                _section('Table', [
                  AppCard(
                    child: AppTable(
                      minWidth: 520,
                      columns: const [
                        AppTableColumn('Date', width: 64),
                        AppTableColumn('Description'),
                        AppTableColumn('Type', width: 104),
                        AppTableColumn('Amount', width: 110, align: TextAlign.right),
                      ],
                      rows: [
                        AppTableRow([
                          const AppTableText('05 Nov', secondary: true),
                          const AppTableText('Salary'),
                          const TypeBadge(TxType.income),
                          const AmountText(amount: 45000, type: TxType.income),
                        ]),
                        AppTableRow([
                          const AppTableText('08 Nov', secondary: true),
                          const AppTableText('Rent'),
                          const TypeBadge(TxType.expense),
                          const AmountText(amount: 32000, type: TxType.expense),
                        ]),
                        AppTableRow([
                          const AppTableText('12 Nov', secondary: true),
                          const AppTableText('Index fund SIP'),
                          const TypeBadge(TxType.investment),
                          const AmountText(amount: 20000, type: TxType.investment),
                        ]),
                        AppTableRow(
                          [
                            const AppTableText(''),
                            const AppTableText('Total', bold: true),
                            const AppTableText(''),
                            const AppTableText('₹97,000', bold: true),
                          ],
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                ]),
                Text('Part 2 additions', style: AppTextStyles.pageTitle),
                _section('Buttons (all variants)', [
                  Wrap(
                    spacing: AppSpacing.s12,
                    runSpacing: AppSpacing.s12,
                    children: [
                      AppButton(label: 'Primary', onPressed: _notWired),
                      AppButton(
                        label: 'Secondary',
                        variant: AppButtonVariant.secondary,
                        onPressed: _notWired,
                      ),
                      AppButton(
                        label: 'Danger',
                        variant: AppButtonVariant.danger,
                        onPressed: _notWired,
                      ),
                      AppButton(
                        label: 'Danger outline',
                        variant: AppButtonVariant.dangerOutline,
                        onPressed: _notWired,
                      ),
                    ],
                  ),
                ]),
                _section('Password field', [
                  const AppTextField(
                    label: 'Password',
                    hintText: 'Your password',
                    obscureText: true,
                  ),
                ]),
                _section('Badges', [
                  const Wrap(
                    spacing: AppSpacing.s8,
                    children: [
                      AppBadge(
                        text: 'Active',
                        background: AppColors.incomeBg,
                        foreground: AppColors.income,
                      ),
                      AppBadge(
                        text: 'Archived',
                        background: AppColors.neutralBg,
                        foreground: AppColors.neutralFg,
                      ),
                    ],
                  ),
                ]),
                _section('Info boxes', [
                  for (final bordered in [false, true])
                    InfoBox(
                      bordered: bordered,
                      child: const Column(
                        spacing: AppSpacing.s8,
                        children: [
                          KeyValueRow(label: 'Opening balance', value: '₹50,000'),
                          KeyValueRow(label: 'Closing balance', value: '₹1,32,400'),
                        ],
                      ),
                    ),
                ]),
                _section('Selected table row', [
                  AppCard(
                    child: AppTable(
                      minWidth: 360,
                      columns: const [
                        AppTableColumn('Name'),
                        AppTableColumn('Status', width: 100),
                      ],
                      rows: const [
                        AppTableRow([
                          AppTableText('Salary'),
                          AppTableText('Active', secondary: true),
                        ]),
                        AppTableRow(
                          [
                            AppTableText('Side hustle', bold: true),
                            AppTableText('Selected', secondary: true),
                          ],
                          background: AppColors.rowSelected,
                        ),
                        AppTableRow([
                          AppTableText('VR'),
                          AppTableText('Active', secondary: true),
                        ]),
                      ],
                    ),
                  ),
                ]),
                _section('Dialogs', [
                  Wrap(
                    spacing: AppSpacing.s12,
                    runSpacing: AppSpacing.s12,
                    children: [
                      AppButton(
                        label: 'Open sample dialog',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => showAppDialog<void>(
                          context,
                          (dialogContext) => AppDialog(
                            title: 'Sample dialog',
                            content: Text(
                              'This is the standard dialog shell.',
                              style: AppTextStyles.body,
                            ),
                            actions: [
                              AppButton(
                                label: 'Cancel',
                                variant: AppButtonVariant.secondary,
                                onPressed: () => Navigator.of(dialogContext).pop(),
                              ),
                              AppButton(
                                label: 'Save',
                                onPressed: () => Navigator.of(dialogContext).pop(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppButton(
                        label: 'Open destructive dialog',
                        variant: AppButtonVariant.dangerOutline,
                        onPressed: () => showAppDialog<void>(
                          context,
                          (dialogContext) => AppDialog(
                            title: 'Delete this entry?',
                            content: Text(
                              'This cannot be undone.',
                              style: AppTextStyles.body,
                            ),
                            actions: [
                              AppButton(
                                label: 'Cancel',
                                variant: AppButtonVariant.secondary,
                                onPressed: () => Navigator.of(dialogContext).pop(),
                              ),
                              AppButton(
                                label: 'Delete',
                                variant: AppButtonVariant.danger,
                                onPressed: () => Navigator.of(dialogContext).pop(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
