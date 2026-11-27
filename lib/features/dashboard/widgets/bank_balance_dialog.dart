import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/models/bank_reconciliation.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/entry_validation.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_date_field.dart';
import 'package:finance_tracker/core/widgets/app_dialog.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/info_box.dart';
import 'package:finance_tracker/core/widgets/status_pill.dart';
import 'package:flutter/material.dart';

typedef BankBalanceResult = ({String accountId, double balance, DateTime asOf});

/// Asks which bank account and what balance. Completes with the entered
/// values on Save and with null when cancelled or dismissed.
Future<BankBalanceResult?> showBankBalanceDialog(
  BuildContext context, {
  required List<BankAccountReconciliation> accounts,
  required String initialAccountId,
}) {
  return showAppDialog<BankBalanceResult>(
    context,
    (_) => BankBalanceDialog(
      accounts: accounts,
      initialAccountId: initialAccountId,
    ),
  );
}

class BankBalanceDialog extends StatefulWidget {
  const BankBalanceDialog({
    super.key,
    required this.accounts,
    required this.initialAccountId,
  });

  /// The accounts to choose from.
  final List<BankAccountReconciliation> accounts;
  final String initialAccountId;

  @override
  State<BankBalanceDialog> createState() => _BankBalanceDialogState();
}

class _BankBalanceDialogState extends State<BankBalanceDialog> {
  final _amount = TextEditingController();
  late String _accountId;
  late DateTime _asOf;

  BankAccountReconciliation get _selected =>
      widget.accounts.firstWhere((a) => a.account.id == _accountId);

  @override
  void initState() {
    super.initState();
    _accountId = widget.initialAccountId;
    _fillFromAccount();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// Sets the amount and the date to the selected account's current values.
  void _fillFromAccount() {
    final row = _selected;
    _amount.text = row.bankBalance?.toStringAsFixed(0) ?? '';
    _asOf = row.asOf ?? appToday();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final typed = parseAmount(_amount.text);
    return AppDialog(
      title: 'Update bank balance',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s16,
        children: [
          Text(
            'Choose the bank account and enter the balance shown in its '
            'statement. The dashboard compares it with the sum of that '
            "account's source balances.",
            style: AppTextStyles.bodySecondary,
          ),
          AppDropdown<String>(
            label: 'Bank account',
            value: _accountId,
            items: [
              for (final a in widget.accounts)
                AppDropdownItem(a.account.id, a.account.name),
            ],
            onChanged: (id) {
              if (id == null || id == _accountId) return;
              setState(() {
                _accountId = id;
                _fillFromAccount();
              });
            },
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s12,
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Bank balance (₹)',
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: AppDateField(
                  label: 'As on',
                  value: _asOf,
                  onChanged: (d) => setState(() => _asOf = d),
                ),
              ),
            ],
          ),
          InfoBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s8,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: AppSpacing.s12,
                  children: [
                    Flexible(
                      child: Text(
                        "Sum of this account's sources",
                        style: AppTextStyles.rowLabel,
                      ),
                    ),
                    Text(
                      Money.plain(selected.sourcesTotal),
                      style: AppTextStyles.rowValue,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: AppSpacing.s12,
                  children: [
                    Text('Difference', style: AppTextStyles.rowLabel),
                    if (typed == null)
                      Text('—', style: AppTextStyles.rowValue)
                    else if ((selected.sourcesTotal - typed).abs() < 0.005)
                      const StatusPill(text: '₹0 · Matches')
                    else
                      StatusPill(
                        text:
                            'Off by ${Money.plain((selected.sourcesTotal - typed).abs())}',
                        tone: StatusTone.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.large,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: 'Save bank balance',
          size: AppButtonSize.large,
          onPressed: typed == null
              ? null
              : () => Navigator.of(context).pop<BankBalanceResult>((
                  accountId: _accountId,
                  balance: typed,
                  asOf: _asOf,
                )),
        ),
      ],
    );
  }
}
