import 'package:finance_tracker/core/models/bank_reconciliation.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/core/widgets/status_pill.dart';
import 'package:flutter/material.dart';

class ReconciliationStrip extends StatelessWidget {
  const ReconciliationStrip({
    super.key,
    required this.data,
    required this.onUpdateBankBalance,
  });

  final BankReconciliation data;
  final VoidCallback onUpdateBankBalance;

  @override
  Widget build(BuildContext context) {
    final matches = data.difference == 0;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s16,
        horizontal: AppSpacing.s20,
      ),
      child: Row(
        spacing: AppSpacing.s16,
        children: [
          Expanded(
            child: Wrap(
              spacing: AppSpacing.s40,
              runSpacing: AppSpacing.s16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Figure(
                  caption: 'Sum of source balances',
                  value: Money.plain(data.sourcesTotal),
                ),
                _Figure(
                  caption: 'Bank balance (entered ${AppDates.dayMonth(data.asOf)})',
                  value: Money.plain(data.bankBalance),
                ),
                if (matches)
                  const StatusPill(text: 'Matches · difference ₹0')
                else
                  StatusPill(
                    text: 'Off by ${Money.plain(data.difference.abs())}',
                    tone: StatusTone.warning,
                  ),
              ],
            ),
          ),
          AppTextLink(
            label: 'Update bank balance',
            onPressed: onUpdateBankBalance,
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.caption, required this.value});

  final String caption;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(caption, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.summaryValue),
      ],
    );
  }
}
