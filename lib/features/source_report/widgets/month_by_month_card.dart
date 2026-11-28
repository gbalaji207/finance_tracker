import 'package:finance_tracker/core/models/source_report.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/empty_note.dart';
import 'package:flutter/material.dart';

class MonthByMonthCard extends StatelessWidget {
  const MonthByMonthCard({super.key, required this.months});

  /// Newest first; rendered in the order given.
  final List<SourceMonthRow> months;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Month by month', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.s8),
          if (months.isEmpty)
            const EmptyNote('No history yet.')
          else
            AppTable(
              minWidth: 600,
              columns: const [
                AppTableColumn('Month', flex: 1.2),
                AppTableColumn('Income', align: TextAlign.right),
                AppTableColumn('Expense', align: TextAlign.right),
                AppTableColumn('Invested / saved', align: TextAlign.right),
                AppTableColumn('Jillu', align: TextAlign.right),
                AppTableColumn(
                  'Closing balance',
                  align: TextAlign.right,
                  mobile: AppTableMobile.trailing,
                ),
              ],
              rows: [
                for (final m in months)
                  AppTableRow([
                    AppTableText(AppDates.monthYearShort(m.month), bold: true),
                    AppTableText(
                      Money.plain(m.income),
                      color: AppColors.income,
                    ),
                    AppTableText(Money.plain(m.expense)),
                    AppTableText(Money.plain(m.investedSaved)),
                    AppTableText(Money.plain(m.partner)),
                    AppTableText(Money.plain(m.closing), bold: true),
                  ]),
              ],
            ),
        ],
      ),
    );
  }
}
