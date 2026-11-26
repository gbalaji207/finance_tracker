import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/core/widgets/section_header.dart';
import 'package:flutter/material.dart';

class QuickAddCard extends StatelessWidget {
  const QuickAddCard({
    super.key,
    required this.templates,
    required this.sourceName,
    required this.onUse,
    required this.onManage,
    required this.onCopyLastMonth,
  });

  final List<EntryTemplate> templates;
  final String Function(String sourceId) sourceName;
  final ValueChanged<EntryTemplate> onUse;
  final VoidCallback onManage;
  final VoidCallback onCopyLastMonth;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Quick add',
            actionLabel: 'Manage',
            onAction: onManage,
          ),
          for (final t in templates)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: AppSpacing.s12,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: AppTextStyles.bodyStrong),
                        Text(
                          '${sourceName(t.sourceId)} · ${t.type.label}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    label: 'Use',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.small,
                    onPressed: () => onUse(t),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.s12),
          Align(
            alignment: Alignment.centerLeft,
            child: AppTextLink(
              label: 'Copy entries from last month',
              onPressed: onCopyLastMonth,
            ),
          ),
        ],
      ),
    );
  }
}
