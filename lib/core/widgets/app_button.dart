import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool expand;

  double get _height => switch (size) {
        AppButtonSize.small => AppSpacing.buttonSmall,
        AppButtonSize.medium => AppSpacing.controlHeight,
        AppButtonSize.large => AppSpacing.buttonLarge,
      };

  double get _hPadding =>
      size == AppButtonSize.small ? AppSpacing.s16 : AppSpacing.s20;

  TextStyle get _textStyle => size == AppButtonSize.small
      ? AppTextStyles.buttonSmall
      : AppTextStyles.button;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == AppButtonVariant.primary;
    final fg = isPrimary ? Colors.white : AppColors.primaryDark;
    final style = ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: WidgetStatePropertyAll(Size(0, _height)),
      fixedSize: expand ? WidgetStatePropertyAll(Size.fromHeight(_height)) : null,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: _hPadding),
      ),
      textStyle: WidgetStatePropertyAll(_textStyle),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        ),
      ),
      backgroundColor: WidgetStatePropertyAll(
        isPrimary ? AppColors.primary : AppColors.surface,
      ),
      foregroundColor: WidgetStatePropertyAll(fg),
      side: isPrimary
          ? null
          : const WidgetStatePropertyAll(BorderSide(color: AppColors.primary)),
      mouseCursor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
      ),
    );

    final text = Text(label, style: _textStyle.copyWith(color: fg));
    final Widget button = isPrimary
        ? FilledButton(onPressed: onPressed, style: style, child: text)
        : OutlinedButton(onPressed: onPressed, style: style, child: text);

    final result = Opacity(opacity: onPressed == null ? 0.5 : 1, child: button);
    return expand ? SizedBox(width: double.infinity, child: result) : result;
  }
}
