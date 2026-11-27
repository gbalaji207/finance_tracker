import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_date_field.dart';
import 'package:finance_tracker/core/widgets/app_dialog.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/info_box.dart';
import 'package:finance_tracker/core/widgets/status_pill.dart';
import 'package:flutter/material.dart';

typedef BankBalanceResult = ({double balance, DateTime asOf});

/// Asks for a new bank balance. Completes with the entered values on Save and
/// with null when cancelled or dismissed.
Future<BankBalanceResult?> showBankBalanceDialog(
  BuildContext context, {
  required double sourcesTotal,
  required double currentBankBalance,
  required DateTime asOf,
}) {
  return showAppDialog<BankBalanceResult>(
    context,
    (_) => BankBalanceDialog(
      sourcesTotal: sourcesTotal,
      currentBankBalance: currentBankBalance,
      asOf: asOf,
    ),
  );
}

class BankBalanceDialog extends StatefulWidget {
  const BankBalanceDialog({
    super.key,
    required this.sourcesTotal,
    required this.currentBankBalance,
    required this.asOf,
  });

  final double sourcesTotal;
  final double currentBankBalance;
  final DateTime asOf;

  @override
  State<BankBalanceDialog> createState() => _BankBalanceDialogState();
}

class _BankBalanceDialogState extends State<BankBalanceDialog> {
  late final TextEditingController _amount;
  late DateTime _asOf;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: widget.currentBankBalance.toStringAsFixed(0),
    );
    _asOf = widget.asOf;
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// Removes commas and spaces, then parses; null when empty or invalid.
  double? get _typed =>
      double.tryParse(_amount.text.replaceAll(RegExp(r'[,\s]'), ''));

  @override
  Widget build(BuildContext context) {
    final typed = _typed;
    return AppDialog(
      title: 'Update bank balance',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s16,
        children: [
          Text(
            'Enter the balance shown in your bank statement. The dashboard '
            'compares it with the sum of your source balances.',
            style: AppTextStyles.bodySecondary,
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
                        'Sum of source balances',
                        style: AppTextStyles.rowLabel,
                      ),
                    ),
                    Text(
                      Money.plain(widget.sourcesTotal),
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
                    else if (typed == widget.sourcesTotal)
                      const StatusPill(text: '₹0 · Matches')
                    else
                      StatusPill(
                        text:
                            'Off by ${Money.plain((widget.sourcesTotal - typed).abs())}',
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
              : () => Navigator.of(
                  context,
                ).pop<BankBalanceResult>((balance: typed, asOf: _asOf)),
        ),
      ],
    );
  }
}
