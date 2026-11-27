import 'package:finance_tracker/core/models/bank_reconciliation.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/core/widgets/info_box.dart';
import 'package:finance_tracker/core/widgets/status_pill.dart';
import 'package:flutter/material.dart';

/// Totals across all bank accounts, then one row per account with its own
/// "Update" link.
class ReconciliationStrip extends StatefulWidget {
  const ReconciliationStrip({
    super.key,
    required this.data,
    required this.onUpdate,
  });

  final BankReconciliation data;

  /// Opens the bank balance dialog for that account.
  final ValueChanged<BankAccountReconciliation> onUpdate;

  @override
  State<ReconciliationStrip> createState() => _ReconciliationStripState();
}

class _ReconciliationStripState extends State<ReconciliationStrip> {
  bool _expanded = true;

  static String _plural(int n) => n == 1 ? 'account' : 'accounts';

  Widget _topPill(BankReconciliation data) {
    if (data.allMatch) {
      return const StatusPill(text: 'Matches · difference ₹0');
    }
    final parts = <String>[
      if (data.offCount > 0)
        'Off by ${Money.plain(data.offAmount)} in ${data.offCount} '
            '${_plural(data.offCount)}',
      if (data.missingCount > 0)
        'Balance not set for ${data.missingCount} '
            '${_plural(data.missingCount)}',
    ];
    return StatusPill(text: parts.join(' · '), tone: StatusTone.warning);
  }

  Widget _rowPill(BankAccountReconciliation row) {
    if (!row.isSet) {
      return const StatusPill(text: 'Not set', tone: StatusTone.warning);
    }
    if (row.matches) return const StatusPill(text: 'Matches · ₹0');
    return StatusPill(
      text: 'Off by ${Money.plain(row.difference!.abs())}',
      tone: StatusTone.warning,
    );
  }

  Widget _bankBalanceCell(BankAccountReconciliation row) {
    if (!row.isSet) {
      return const AppTableText('Not set', secondary: true);
    }
    final asOf = row.asOf;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: Money.plain(row.bankBalance!),
            style: AppTextStyles.body,
          ),
          if (asOf != null)
            TextSpan(
              text: ' · ${AppDates.dayMonth(asOf)}',
              style: AppTextStyles.caption,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s16,
        horizontal: AppSpacing.s20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.s40,
            runSpacing: AppSpacing.s16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Figure(
                caption: 'Sum of source balances',
                value: Money.plain(data.sourcesTotal),
              ),
              _Figure(
                caption: data.missingCount > 0
                    ? 'Bank balances, all accounts '
                          '(${data.missingCount} not set)'
                    : 'Bank balances, all accounts',
                value: Money.plain(data.bankTotal),
              ),
              _topPill(data),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          if (data.accounts.isEmpty)
            const InfoBox(
              child: Text(
                'Add a bank account in Settings to compare your balances '
                'with the bank.',
              ),
            )
          else ...[
            const Divider(height: 1, thickness: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.s8),
            Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                expanded: _expanded,
                child: AppTextLink(
                  label: 'Bank accounts (${data.accounts.length})',
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ),
            ),
            if (_expanded)
              AppTable(
                minWidth: 640,
                columns: const [
                  AppTableColumn('Account', flex: 1.2),
                  AppTableColumn('Sources', width: 120, align: TextAlign.right),
                  AppTableColumn(
                    'Bank balance',
                    width: 170,
                    align: TextAlign.right,
                  ),
                  AppTableColumn('Status', width: 150),
                  AppTableColumn('', width: 80, align: TextAlign.right),
                ],
                rows: [
                  for (final row in data.accounts)
                    AppTableRow([
                      Text(row.account.name, style: AppTextStyles.bodyStrong),
                      AppTableText(Money.plain(row.sourcesTotal)),
                      _bankBalanceCell(row),
                      _rowPill(row),
                      AppTextLink(
                        label: 'Update',
                        onPressed: () => widget.onUpdate(row),
                      ),
                    ]),
                ],
              ),
          ],
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
