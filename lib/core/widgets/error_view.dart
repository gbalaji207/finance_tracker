import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// Shown in place of a page's content when loading failed.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text('Could not load this page', style: AppTextStyles.sectionTitle),
            Text(message, style: AppTextStyles.bodySecondary),
            AppButton(
              label: 'Try again',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.medium,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
