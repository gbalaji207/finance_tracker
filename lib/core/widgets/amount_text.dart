import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:flutter/material.dart';

class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.amount,
    required this.type,
    this.textAlign = TextAlign.right,
  });

  final double amount;
  final TxType type;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      Money.signed(amount, type),
      textAlign: textAlign,
      style: AppTextStyles.bodyStrong.copyWith(
        color: type == TxType.income ? AppColors.income : AppColors.textPrimary,
      ),
    );
  }
}
