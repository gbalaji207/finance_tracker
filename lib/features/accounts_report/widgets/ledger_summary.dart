import 'package:finance_tracker/core/models/account_ledger.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/kpi_tile.dart';
import 'package:finance_tracker/core/widgets/responsive_wrap.dart';
import 'package:flutter/material.dart';

/// Opening balance, total credit, total debit and closing balance for the
/// whole filtered range.
class LedgerSummary extends StatelessWidget {
  const LedgerSummary({
    super.key,
    required this.ledger,
    required this.typeFiltered,
  });

  final AccountLedger ledger;

  /// True when a Type filter hides some entries from the running balance.
  final bool typeFiltered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s8,
      children: [
        ResponsiveWrap(
          minItemWidth: 200,
          spacing: 16,
          children: [
            KpiTile(
              label: 'Opening balance',
              value: Money.plain(ledger.opening),
            ),
            KpiTile(
              label: 'Total credit',
              value: Money.plain(ledger.totalCredit),
            ),
            KpiTile(
              label: 'Total debit',
              value: Money.plain(ledger.totalDebit),
            ),
            KpiTile(
              label: 'Closing balance',
              value: Money.plain(ledger.closing),
            ),
          ],
        ),
        if (typeFiltered)
          Text(
            'Closing is calculated over the shown rows only.',
            style: AppTextStyles.caption,
          ),
      ],
    );
  }
}
