import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/widgets/amount_text.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/section_header.dart';
import 'package:finance_tracker/core/widgets/type_badge.dart';
import 'package:flutter/material.dart';

class RecentEntriesCard extends StatelessWidget {
  const RecentEntriesCard({
    super.key,
    required this.entries,
    required this.sourceName,
    required this.onViewAll,
  });

  final List<Transaction> entries;
  final String Function(String sourceId) sourceName;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recent entries',
            actionLabel: 'View all',
            onAction: onViewAll,
          ),
          AppTable(
            // Scrolls sideways instead of overflowing in a narrow card.
            minWidth: 520,
            columns: const [
              AppTableColumn('Date', width: 64),
              AppTableColumn('Description'),
              AppTableColumn('Source', width: 110),
              AppTableColumn('Type', width: 104),
              AppTableColumn('Amount', width: 110, align: TextAlign.right),
            ],
            rows: [
              for (final e in entries)
                AppTableRow([
                  AppTableText(AppDates.dayMonth(e.date), secondary: true),
                  AppTableText(e.description),
                  AppTableText(sourceName(e.sourceId)),
                  TypeBadge(e.type),
                  AmountText(amount: e.amount, type: e.type),
                ]),
            ],
          ),
        ],
      ),
    );
  }
}
