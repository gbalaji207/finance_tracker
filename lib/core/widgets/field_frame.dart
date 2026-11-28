import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Shared look for text field, dropdown and date field: optional label above,
/// the input box in the middle, optional helper text below.
class FieldFrame extends StatelessWidget {
  const FieldFrame({
    super.key,
    this.label,
    this.helperText,
    required this.child,
  });

  final String? label;
  final String? helperText;
  final Widget child;

  /// Decoration that draws the 44px input box.
  static InputDecoration decoration({String? hintText, Widget? suffixIcon}) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      borderSide: BorderSide(color: color, width: width),
    );
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
      isDense: true,
      filled: true,
      fillColor: AppColors.surface,
      constraints: const BoxConstraints(
        minHeight: AppSpacing.controlHeight,
        maxHeight: AppSpacing.controlHeight,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s12,
      ),
      border: border(AppColors.inputBorder, 1),
      enabledBorder: border(AppColors.inputBorder, 1),
      focusedBorder: border(AppColors.primary, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.s6),
        ],
        child,
        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.s6),
          Text(helperText!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}
