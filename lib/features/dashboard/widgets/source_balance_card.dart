import 'package:finance_tracker/core/models/source_summary.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/key_value_row.dart';
import 'package:flutter/material.dart';

class SourceBalanceCard extends StatelessWidget {
  const SourceBalanceCard({
    super.key,
    required this.summary,
    this.balanceLabel = 'Balance as on today',
    this.monthLabel = 'This month',
  });

  final SourceSummary summary;
  final String balanceLabel;
  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: AppSpacing.s8,
            children: [
              Flexible(
                child: Text(
                  summary.source.name,
                  style: AppTextStyles.cardTitle,
                ),
              ),
              Text(summary.source.kind, style: AppTextStyles.caption),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(balanceLabel, style: AppTextStyles.caption),
              Text(
                Money.plain(summary.closing),
                style: AppTextStyles.balanceValue,
              ),
            ],
          ),
          _TopBorder(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(monthLabel, style: AppTextStyles.caption),
                KeyValueRow(
                  label: 'Income',
                  value: Money.signed(summary.income, TxType.income),
                  valueColor: AppColors.income,
                ),
                KeyValueRow(
                  label: 'Expense',
                  value: Money.signed(summary.expense, TxType.expense),
                ),
                KeyValueRow(
                  label: 'Invested',
                  value: Money.signed(summary.invested, TxType.investment),
                ),
                KeyValueRow(
                  label: 'Saved',
                  value: Money.signed(summary.saved, TxType.savings),
                ),
              ],
            ),
          ),
          _TopBorder(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Invested / saved to date ',
                    style: AppTextStyles.caption,
                  ),
                  TextSpan(
                    text: Money.plain(summary.investedSavedToDate),
                    style: AppTextStyles.captionBold,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Content under a 1px divider line, with 12px padding above the content.
class _TopBorder extends StatelessWidget {
  const _TopBorder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: AppSpacing.s12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: child,
    );
  }
}
