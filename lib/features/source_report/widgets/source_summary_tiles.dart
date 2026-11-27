import 'package:finance_tracker/core/models/source_report.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/kpi_tile.dart';
import 'package:finance_tracker/core/widgets/responsive_wrap.dart';
import 'package:flutter/material.dart';

class SourceSummaryTiles extends StatelessWidget {
  const SourceSummaryTiles({super.key, required this.report});

  final SourceReport report;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrap(
      minItemWidth: 200,
      spacing: 16,
      children: [
        KpiTile(
          label: 'Balance as on today',
          value: Money.plain(report.balanceToday),
        ),
        KpiTile(
          label: 'Income this month',
          value: Money.plain(report.incomeThisMonth),
        ),
        KpiTile(
          label: 'Expense this month',
          value: Money.plain(report.expenseThisMonth),
        ),
        KpiTile(
          label: 'Jillu this month',
          value: Money.plain(report.partnerThisMonth),
        ),
        KpiTile(
          label: 'Invested / saved to date',
          value: Money.plain(report.investedSavedToDate),
        ),
      ],
    );
  }
}
