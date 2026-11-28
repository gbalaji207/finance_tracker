import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.width,
  });

  final Widget child;

  /// Defaults to [AppSpacing.cardPadding], or the compact value on phones.
  final EdgeInsets? padding;
  final Color? borderColor;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding:
          padding ??
          EdgeInsets.all(
            MediaQuery.sizeOf(context).width < AppSpacing.mobileBreakpoint
                ? AppSpacing.cardPaddingCompact
                : AppSpacing.cardPadding,
          ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: borderColor ?? AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: child,
    );
  }
}
