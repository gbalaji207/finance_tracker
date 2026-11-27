import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Opens a dialog with the app's dimmed barrier. Esc and a click on the
/// barrier close it. Each real dialog is its own widget returning an
/// [AppDialog].
Future<T?> showAppDialog<T>(BuildContext context, WidgetBuilder builder) {
  return showDialog<T>(
    context: context,
    barrierColor: AppColors.scrim.withValues(alpha: 0.35),
    builder: builder,
  );
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: AppSpacing.s40,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            boxShadow: const [
              BoxShadow(
                color: Color(0x401F2328),
                blurRadius: 40,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s16,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: AppTextStyles.dialogTitle),
                ),
                content,
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s4),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: AppSpacing.s12,
                    runSpacing: AppSpacing.s12,
                    children: actions,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
