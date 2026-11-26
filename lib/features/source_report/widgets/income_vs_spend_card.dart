import 'dart:math' as math;

import 'package:finance_tracker/core/models/source_report.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

class IncomeVsSpendCard extends StatelessWidget {
  const IncomeVsSpendCard({super.key, required this.months});

  /// Newest first; drawn oldest to newest, left to right.
  final List<SourceMonthRow> months;

  static const double _barAreaHeight = 160;
  static const double _barWidth = 28;
  static const double _barGap = 6;

  @override
  Widget build(BuildContext context) {
    final ordered = months.reversed.toList();
    final maxIncome = ordered.fold<double>(0, (m, r) => math.max(m, r.income));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.s16,
            runSpacing: AppSpacing.s8,
            children: [
              Text('Income vs spend', style: AppTextStyles.sectionTitle),
              const Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.s16,
                children: [
                  _LegendItem(color: AppColors.chartIncome, label: 'Income'),
                  _LegendItem(color: AppColors.chartExpense, label: 'Expense'),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Semantics(
            label: _semanticsLabel(ordered),
            image: true,
            child: Container(
              height: 190,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.controlBorder),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: AppSpacing.s24,
                children: [
                  for (final m in ordered)
                    Expanded(child: _MonthGroup(row: m, maxIncome: maxIncome)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _semanticsLabel(List<SourceMonthRow> ordered) {
    if (ordered.isEmpty) return 'Bar chart: income against expense per month';
    final first = AppDates.monthName(ordered.first.month);
    final last = AppDates.monthName(ordered.last.month);
    return 'Bar chart: income against expense per month, '
        '$first to $last ${ordered.last.month.year}';
  }
}

class _MonthGroup extends StatelessWidget {
  const _MonthGroup({required this.row, required this.maxIncome});

  final SourceMonthRow row;
  final double maxIncome;

  double _height(double amount) => maxIncome == 0
      ? 0
      : amount / maxIncome * IncomeVsSpendCard._barAreaHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 28px bars; they shrink only when the group is too narrow for two.
        final barWidth = math.min(
          IncomeVsSpendCard._barWidth,
          (constraints.maxWidth - IncomeVsSpendCard._barGap) / 2,
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 6,
          children: [
            SizedBox(
              height: IncomeVsSpendCard._barAreaHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: IncomeVsSpendCard._barGap,
                children: [
                  _Bar(
                    color: AppColors.chartIncome,
                    width: barWidth,
                    height: _height(row.income),
                  ),
                  _Bar(
                    color: AppColors.chartExpense,
                    width: barWidth,
                    height: _height(row.expense),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              // Scales down instead of wrapping when the group is very narrow.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppDates.monthShort(row.month),
                  style: AppTextStyles.caption,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.color, required this.width, required this.height});

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Text(label, style: AppTextStyles.subtitle),
      ],
    );
  }
}
