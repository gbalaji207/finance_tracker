import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// The top of a Settings table card: title and description on the left, the
/// Add button on the right.
class ListCardHeader extends StatelessWidget {
  const ListCardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.addLabel,
    required this.onAdd,
  });

  final String title;
  final String subtitle;
  final String addLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s16,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.s4),
              Text(subtitle, style: AppTextStyles.subtitle),
            ],
          ),
        ),
        AppButton(label: addLabel, onPressed: onAdd),
      ],
    );
  }
}
