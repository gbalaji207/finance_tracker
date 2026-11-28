import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/core/widgets/type_badge.dart';
import 'package:flutter/material.dart';

class TemplatesListCard extends StatelessWidget {
  const TemplatesListCard({
    super.key,
    required this.templates,
    required this.sourceName,
    required this.categoryName,
    required this.onUse,
    required this.onEdit,
  });

  final List<EntryTemplate> templates;
  final String Function(String sourceId) sourceName;
  final String Function(String? categoryId) categoryName;
  final ValueChanged<EntryTemplate> onUse;
  final ValueChanged<EntryTemplate> onEdit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your templates', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.s8),
          AppTable(
            minWidth: 760,
            columns: const [
              AppTableColumn('Name', flex: 1.2),
              AppTableColumn('Type', width: 112),
              AppTableColumn('Source', width: 140),
              AppTableColumn('Category', width: 150),
              AppTableColumn(
                'Default amount',
                width: 130,
                align: TextAlign.right,
              ),
              AppTableColumn('Actions', width: 120, align: TextAlign.right),
            ],
            rows: [
              for (final t in templates)
                AppTableRow([
                  AppTableText(t.name, bold: true, maxLines: 1),
                  TypeBadge(t.type),
                  AppTableText(sourceName(t.sourceId), maxLines: 1),
                  AppTableText(
                    categoryName(t.categoryId),
                    secondary: true,
                    maxLines: 1,
                  ),
                  AppTableText(
                    t.amount == null ? '—' : Money.plain(t.amount!),
                    maxLines: 1,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.s16,
                    children: [
                      AppTextLink(label: 'Use', onPressed: () => onUse(t)),
                      AppTextLink(label: 'Edit', onPressed: () => onEdit(t)),
                    ],
                  ),
                ]),
            ],
          ),
        ],
      ),
    );
  }
}
