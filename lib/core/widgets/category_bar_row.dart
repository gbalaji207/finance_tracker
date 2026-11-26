import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class CategoryBarRow extends StatelessWidget {
  const CategoryBarRow({
    super.key,
    required this.label,
    required this.amountText,
    required this.fraction,
  });

  final String label;
  final String amountText;
  final double fraction;

  static const double _barHeight = 14;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(_barHeight / 2));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: AppSpacing.s16,
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: AppTextStyles.body),
        ),
        Expanded(
          child: Container(
            height: _barHeight,
            decoration: const BoxDecoration(
              color: AppColors.track,
              borderRadius: radius,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(
                  height: _barHeight,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 90,
          child: Text(
            amountText,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyStrong,
          ),
        ),
      ],
    );
  }
}
