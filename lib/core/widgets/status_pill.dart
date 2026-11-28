import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum StatusTone { success, warning }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.text,
    this.tone = StatusTone.success,
  });

  final String text;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      StatusTone.success => (AppColors.incomeBg, AppColors.income),
      StatusTone.warning => (AppColors.expenseBg, AppColors.expenseFg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s6,
        horizontal: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: AppTextStyles.buttonSmall.copyWith(color: fg)),
    );
  }
}
