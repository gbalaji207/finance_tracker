import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class TypeBadge extends StatelessWidget {
  const TypeBadge(this.type, {super.key});

  final TxType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s4,
        horizontal: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: type.badgeBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusBadge),
      ),
      child: Text(
        type.label,
        style: AppTextStyles.badge.copyWith(color: type.badgeFg),
      ),
    );
  }
}
