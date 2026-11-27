import 'package:finance_tracker/core/models/monthly_report.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/kpi_tile.dart';
import 'package:finance_tracker/core/widgets/responsive_wrap.dart';
import 'package:flutter/material.dart';

class ReportKpis extends StatelessWidget {
  const ReportKpis({super.key, required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrap(
      minItemWidth: 170,
      spacing: 16,
      children: [
        KpiTile(label: 'Income', value: Money.plain(report.income)),
        KpiTile(label: 'Expense', value: Money.plain(report.expense)),
        KpiTile(label: 'Invested', value: Money.plain(report.invested)),
        KpiTile(label: 'Saved', value: Money.plain(report.saved)),
        KpiTile(label: 'Jillu', value: Money.plain(report.partner)),
        KpiTile(
          label: 'Savings rate (invested + saved)',
          value: '${(report.savingsRate * 100).round()}%',
        ),
      ],
    );
  }
}
