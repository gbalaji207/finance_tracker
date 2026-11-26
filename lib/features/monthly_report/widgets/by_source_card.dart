import 'package:finance_tracker/core/models/monthly_report.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:flutter/material.dart';

class BySourceCard extends StatelessWidget {
  const BySourceCard({super.key, required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('By source', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.s8),
          AppTable(
            minWidth: 640,
            columns: const [
              AppTableColumn('Source', flex: 1.3),
              AppTableColumn('Opening', align: TextAlign.right),
              AppTableColumn('Income', align: TextAlign.right),
              AppTableColumn('Expense', align: TextAlign.right),
              AppTableColumn('Invested', align: TextAlign.right),
              AppTableColumn('Saved', align: TextAlign.right),
              AppTableColumn('Closing', align: TextAlign.right),
            ],
            rows: [
              for (final s in report.bySource)
                AppTableRow([
                  AppTableText(s.source.name, bold: true),
                  AppTableText(Money.plain(s.opening)),
                  AppTableText(
                    Money.signed(s.income, TxType.income),
                    color: AppColors.income,
                  ),
                  AppTableText(Money.signed(s.expense, TxType.expense)),
                  AppTableText(Money.signed(s.invested, TxType.investment)),
                  AppTableText(Money.signed(s.saved, TxType.savings)),
                  AppTableText(Money.plain(s.closing), bold: true),
                ]),
              AppTableRow(
                [
                  const AppTableText('Total', bold: true),
                  AppTableText(Money.plain(report.opening), bold: true),
                  AppTableText(
                    Money.plain(report.income),
                    bold: true,
                    color: AppColors.income,
                  ),
                  AppTableText(Money.plain(report.expense), bold: true),
                  AppTableText(Money.plain(report.invested), bold: true),
                  AppTableText(Money.plain(report.saved), bold: true),
                  AppTableText(Money.plain(report.closing), bold: true),
                ],
                highlight: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Closing = opening + income − expense − invested − saved',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
