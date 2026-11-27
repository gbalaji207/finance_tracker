import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  const InfoBox({super.key, required this.child, this.bordered = false});

  final Widget child;

  /// Filled (page background) by default; bordered is white with a 1px border.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: bordered ? AppColors.surface : AppColors.pageBg,
        border: bordered ? Border.all(color: AppColors.cardBorder) : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: child,
    );
  }
}
