import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/category_usage.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/core/widgets/type_badge.dart';
import 'package:flutter/material.dart';

class CategoriesCard extends StatelessWidget {
  const CategoriesCard({
    super.key,
    required this.categories,
    required this.onEdit,
    required this.onArchive,
  });

  final List<CategoryUsage> categories;
  final ValueChanged<Category> onEdit;
  final ValueChanged<Category> onArchive;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'Used for expense, investment and savings entries. '
            'Income entries use sources instead.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.s8),
          AppTable(
            minWidth: 480,
            columns: const [
              AppTableColumn('Name', flex: 1.2),
              AppTableColumn('Kind', width: 104),
              AppTableColumn('Entries', width: 80, align: TextAlign.right),
              AppTableColumn('Actions', width: 130, align: TextAlign.right),
            ],
            rows: [
              for (final u in categories)
                AppTableRow([
                  AppTableText(u.category.name, bold: true),
                  TypeBadge(u.category.kind),
                  AppTableText('${u.entryCount}'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.s16,
                    children: [
                      AppTextLink(
                        label: 'Edit',
                        onPressed: () => onEdit(u.category),
                      ),
                      AppTextLink(
                        label: 'Archive',
                        onPressed: () => onArchive(u.category),
                      ),
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
