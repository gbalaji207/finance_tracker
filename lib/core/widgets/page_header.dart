import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.crossAlignment = WrapCrossAlignment.center,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final WrapCrossAlignment crossAlignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: crossAlignment,
      spacing: AppSpacing.s16,
      runSpacing: AppSpacing.s16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: AppTextStyles.pageTitle),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.s4),
              Text(subtitle!, style: AppTextStyles.subtitle),
            ],
          ],
        ),
        if (actions.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.s12,
            children: actions,
          ),
      ],
    );
  }
}
