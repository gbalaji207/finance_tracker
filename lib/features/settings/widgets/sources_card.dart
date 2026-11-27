import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_badge.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:flutter/material.dart';

class SourcesCard extends StatelessWidget {
  const SourcesCard({
    super.key,
    required this.sources,
    required this.onEdit,
    this.editingId,
    required this.onToggleActive,
  });

  final List<Source> sources;
  final ValueChanged<Source> onEdit;

  /// The source being edited; its row is highlighted.
  final String? editingId;
  final ValueChanged<Source> onToggleActive;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sources', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'Each income stream or property is a source. Archived sources '
            'keep their history but are hidden from new entries.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.s8),
          AppTable(
            minWidth: 700,
            columns: const [
              AppTableColumn('Name', flex: 1.1),
              AppTableColumn('Kind', width: 96),
              AppTableColumn('Bank account', width: 120),
              AppTableColumn(
                'Opening balance',
                width: 120,
                align: TextAlign.right,
              ),
              AppTableColumn('Status', width: 96),
              AppTableColumn('Actions', width: 130, align: TextAlign.right),
            ],
            rows: [
              for (final s in sources)
                AppTableRow(
                  background: s.id == editingId ? AppColors.rowSelected : null,
                  [
                    AppTableText(s.name, bold: true),
                    AppTableText(s.kind, secondary: true),
                    AppTableText(s.bankAccountName ?? '—'),
                    AppTableText(Money.plain(s.openingBalance)),
                    s.isActive
                        ? const AppBadge(
                            text: 'Active',
                            background: AppColors.incomeBg,
                            foreground: AppColors.income,
                          )
                        : const AppBadge(
                            text: 'Archived',
                            background: AppColors.neutralBg,
                            foreground: AppColors.neutralFg,
                          ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSpacing.s16,
                      children: [
                        AppTextLink(label: 'Edit', onPressed: () => onEdit(s)),
                        AppTextLink(
                          label: s.isActive ? 'Archive' : 'Restore',
                          onPressed: () => onToggleActive(s),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
