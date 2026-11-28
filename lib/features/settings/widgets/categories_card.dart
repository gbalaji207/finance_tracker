import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/category_usage.dart';
import 'package:finance_tracker/core/models/kinds.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/app_badge.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/core/widgets/empty_note.dart';
import 'package:finance_tracker/core/widgets/type_badge.dart';
import 'package:finance_tracker/features/settings/widgets/list_card_header.dart';
import 'package:flutter/material.dart';

class CategoriesCard extends StatefulWidget {
  const CategoriesCard({
    super.key,
    required this.categories,
    required this.onAdd,
    required this.onEdit,
    required this.onToggleActive,
    this.editingId,
  });

  final List<CategoryUsage> categories;
  final VoidCallback onAdd;

  /// The category being renamed; its row is highlighted.
  final String? editingId;
  final ValueChanged<Category> onEdit;

  /// Archives an active category or restores an archived one.
  final ValueChanged<Category> onToggleActive;

  @override
  State<CategoriesCard> createState() => _CategoriesCardState();
}

class _CategoriesCardState extends State<CategoriesCard> {
  /// Sentinel for "all": see the note in the sources card.
  static const _all = 'all';

  /// The kind to show; null means every kind.
  TxType? _kind;

  @override
  Widget build(BuildContext context) {
    final shown = [
      for (final u in widget.categories)
        if (_kind == null || u.category.kind == _kind) u,
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListCardHeader(
            title: 'Categories',
            subtitle:
                'Used for expense, investment, savings and Jillu entries. '
                'Income entries use sources instead.',
            addLabel: 'Add category',
            onAdd: widget.onAdd,
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: 220,
            child: AppDropdown<String>(
              label: 'Kind',
              value: _kind?.name ?? _all,
              items: [
                const AppDropdownItem(_all, 'All kinds'),
                for (final k in kCategoryKinds)
                  AppDropdownItem(k.name, k.label),
              ],
              onChanged: (v) => setState(
                () => _kind = v == null || v == _all
                    ? null
                    : TxType.values.byName(v),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          if (shown.isEmpty)
            const EmptyNote('No categories of this kind.')
          else
            AppTable(
              minWidth: 576,
              columns: const [
                AppTableColumn('Name', flex: 1.2),
                AppTableColumn('Kind', width: 112),
                AppTableColumn('Entries', width: 80, align: TextAlign.right),
                AppTableColumn(
                  'Status',
                  width: 96,
                  mobile: AppTableMobile.trailing,
                ),
                AppTableColumn(
                  'Actions',
                  width: 130,
                  align: TextAlign.right,
                  mobile: AppTableMobile.action,
                ),
              ],
              rows: [
                for (final u in shown)
                  AppTableRow(
                    background: u.category.id == widget.editingId
                        ? AppColors.rowSelected
                        : null,
                    [
                      AppTableText(u.category.name, bold: true, maxLines: 1),
                      TypeBadge(u.category.kind),
                      AppTableText('${u.entryCount}'),
                      u.category.isActive
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
                          AppTextLink(
                            label: 'Edit',
                            onPressed: () => widget.onEdit(u.category),
                          ),
                          AppTextLink(
                            label: u.category.isActive ? 'Archive' : 'Restore',
                            onPressed: () => widget.onToggleActive(u.category),
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
