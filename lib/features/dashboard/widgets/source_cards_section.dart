import 'package:finance_tracker/core/models/source_summary.dart';
import 'package:finance_tracker/core/widgets/responsive_wrap.dart';
import 'package:finance_tracker/features/dashboard/widgets/source_balance_card.dart';
import 'package:flutter/material.dart';

class SourceCardsSection extends StatelessWidget {
  const SourceCardsSection({super.key, required this.summaries});

  final List<SourceSummary> summaries;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrap(
      minItemWidth: 220,
      maxColumns: 4,
      spacing: 16,
      children: [
        for (final s in summaries) SourceBalanceCard(summary: s),
      ],
    );
  }
}
