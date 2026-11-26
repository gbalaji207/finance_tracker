import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({super.key, required this.name, this.height = 120});

  final String name;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Text('$name (placeholder)', style: AppTextStyles.bodySecondary),
    );
  }
}
