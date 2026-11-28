import 'package:finance_tracker/core/models/kinds.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_badge.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/core/widgets/empty_note.dart';
import 'package:finance_tracker/features/settings/widgets/list_card_header.dart';
import 'package:flutter/material.dart';

class SourcesCard extends StatefulWidget {
  const SourcesCard({
    super.key,
    required this.sources,
    required this.onAdd,
    required this.onEdit,
    this.editingId,
    required this.onToggleActive,
  });

  final List<Source> sources;
  final VoidCallback onAdd;
  final ValueChanged<Source> onEdit;

  /// The source being edited; its row is highlighted.
  final String? editingId;
  final ValueChanged<Source> onToggleActive;

  @override
  State<SourcesCard> createState() => _SourcesCardState();
}

class _SourcesCardState extends State<SourcesCard> {
  /// Sentinel for "all": a dropdown item with a null value does not show as
  /// selected, so "all" is a real value that is mapped back to null.
  static const _all = 'all';

  /// The kind to show; null means every kind.
  String? _kind;

  @override
  Widget build(BuildContext context) {
    final shown = [
      for (final s in widget.sources)
        if (_kind == null || s.kind == _kind) s,
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListCardHeader(
            title: 'Sources',
            subtitle:
                'Each income stream or property is a source. Archived sources '
                'keep their history but are hidden from new entries.',
            addLabel: 'Add source',
            onAdd: widget.onAdd,
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: 220,
            child: AppDropdown<String>(
              label: 'Kind',
              value: _kind ?? _all,
              items: [
                const AppDropdownItem(_all, 'All kinds'),
                for (final k in kSourceKinds) AppDropdownItem(k, k),
              ],
              onChanged: (v) =>
                  setState(() => _kind = v == null || v == _all ? null : v),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          if (shown.isEmpty)
            const EmptyNote('No sources of this kind.')
          else
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
                for (final s in shown)
                  AppTableRow(
                    background: s.id == widget.editingId
                        ? AppColors.rowSelected
                        : null,
                    [
                      AppTableText(s.name, bold: true, maxLines: 1),
                      AppTableText(s.kind, secondary: true, maxLines: 1),
                      AppTableText(s.bankAccountName ?? '—', maxLines: 1),
                      AppTableText(Money.plain(s.openingBalance), maxLines: 1),
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
                          AppTextLink(
                            label: 'Edit',
                            onPressed: () => widget.onEdit(s),
                          ),
                          AppTextLink(
                            label: s.isActive ? 'Archive' : 'Restore',
                            onPressed: () => widget.onToggleActive(s),
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
