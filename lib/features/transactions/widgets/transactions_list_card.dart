import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/transaction.dart';
import 'package:finance_tracker/core/models/transaction_page.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/widgets/amount_text.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/core/widgets/empty_note.dart';
import 'package:finance_tracker/core/widgets/type_badge.dart';
import 'package:flutter/material.dart';

class TransactionsListCard extends StatelessWidget {
  const TransactionsListCard({
    super.key,
    required this.page,
    required this.sources,
    required this.month,
    required this.sourceFilter,
    required this.typeFilter,
    required this.sourceName,
    required this.categoryName,
    required this.onMonthChanged,
    required this.onSourceChanged,
    required this.onTypeChanged,
    required this.onQueryChanged,
    required this.onPageChanged,
    required this.selectedId,
    required this.onEdit,
    this.listLoading = false,
  });

  final TransactionPage page;
  final List<Source> sources;

  /// First day of the month; null means all months.
  final DateTime? month;
  final String? sourceFilter;
  final TxType? typeFilter;
  final String Function(String sourceId) sourceName;
  final String Function(String? categoryId) categoryName;
  final ValueChanged<DateTime?> onMonthChanged;
  final ValueChanged<String?> onSourceChanged;
  final ValueChanged<TxType?> onTypeChanged;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<int> onPageChanged;
  final bool listLoading;

  /// Id of the entry being edited, highlighted in the list.
  final String? selectedId;
  final ValueChanged<Transaction> onEdit;

  /// Sentinel for "all": a dropdown item with a null value does not show as
  /// selected, so "all" is a real value that is mapped back to null.
  static const _all = 'all';

  static String _monthKey(DateTime m) =>
      '${m.year}-${m.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _filters(),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            height: 2,
            child: listLoading
                ? const LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primary,
                  )
                : null,
          ),
          if (page.items.isEmpty)
            const EmptyNote('No entries match these filters.')
          else
            _table(),
          const SizedBox(height: AppSpacing.s16),
          _footer(),
        ],
      ),
    );
  }

  Widget _table() {
    return AppTable(
      // Scrolls sideways instead of overflowing in a narrow card.
      minWidth: 900,
      columns: const [
        AppTableColumn('Date', width: 72),
        AppTableColumn('Description'),
        AppTableColumn('Source', width: 140),
        AppTableColumn('Category', width: 150),
        AppTableColumn('Type', width: 112),
        AppTableColumn(
          'Amount',
          width: 120,
          align: TextAlign.right,
          mobile: AppTableMobile.trailing,
        ),
        AppTableColumn(
          '',
          width: 64,
          align: TextAlign.right,
          mobile: AppTableMobile.action,
        ),
      ],
      rows: [
        for (final t in page.items)
          AppTableRow(
            background: t.id == selectedId ? AppColors.rowSelected : null,
            [
              AppTableText(
                AppDates.dayMonth(t.date),
                secondary: true,
                maxLines: 1,
              ),
              AppTableText(t.description, maxLines: 1),
              AppTableText(sourceName(t.sourceId), maxLines: 1),
              AppTableText(
                categoryName(t.categoryId),
                secondary: true,
                maxLines: 1,
              ),
              TypeBadge(t.type),
              AmountText(amount: t.amount, type: t.type),
              t.id == selectedId
                  ? Text(
                      'Editing',
                      style: AppTextStyles.buttonSmall.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    )
                  : AppTextLink(label: 'Edit', onPressed: () => onEdit(t)),
            ],
          ),
      ],
    );
  }

  Widget _footer() {
    final total = page.total;
    final from = total == 0 ? 0 : (page.page - 1) * kPageSize + 1;
    final to = total == 0 ? 0 : from + page.items.length - 1;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.s16,
      runSpacing: AppSpacing.s8,
      children: [
        Text(
          total == 0 ? 'No entries' : 'Showing $from–$to of $total entries',
          style: AppTextStyles.subtitle,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            if (page.page > 1)
              AppTextLink(
                label: 'Previous',
                onPressed: () => onPageChanged(page.page - 1),
              ),
            Text(
              'Page ${page.page} of ${page.pageCount}',
              style: AppTextStyles.subtitle,
            ),
            if (page.page < page.pageCount)
              AppTextLink(
                label: 'Next',
                onPressed: () => onPageChanged(page.page + 1),
              ),
          ],
        ),
      ],
    );
  }

  /// "All months", the current month and the 11 before it; the selected month
  /// is added when it is outside that range.
  List<DateTime> _monthOptions() {
    final now = appMonth();
    final options = [
      for (var i = 0; i < 12; i++) DateTime(now.year, now.month - i),
    ];
    final selected = month;
    if (selected != null &&
        !options.any((m) => _monthKey(m) == _monthKey(selected))) {
      options.add(selected);
    }
    return options;
  }

  Widget _filters() {
    final selectedMonth = month;
    final fields = <Widget>[
      AppDropdown<String>(
        label: 'Month',
        value: selectedMonth == null ? _all : _monthKey(selectedMonth),
        items: [
          const AppDropdownItem(_all, 'All months'),
          for (final m in _monthOptions())
            AppDropdownItem(_monthKey(m), AppDates.monthYear(m)),
        ],
        onChanged: (v) {
          if (v == null) return;
          if (v == _all) {
            onMonthChanged(null);
          } else {
            final parts = v.split('-');
            onMonthChanged(DateTime(int.parse(parts[0]), int.parse(parts[1])));
          }
        },
      ),
      AppDropdown<String>(
        label: 'Source',
        value: sourceFilter ?? _all,
        items: [
          const AppDropdownItem(_all, 'All sources'),
          for (final s in sources) AppDropdownItem(s.id, s.name),
        ],
        onChanged: (v) => onSourceChanged(v == null || v == _all ? null : v),
      ),
      AppDropdown<String>(
        label: 'Type',
        value: typeFilter?.name ?? _all,
        items: [
          const AppDropdownItem(_all, 'All types'),
          for (final t in TxType.values) AppDropdownItem(t.name, t.label),
        ],
        onChanged: (v) => onTypeChanged(
          v == null || v == _all ? null : TxType.values.byName(v),
        ),
      ),
      AppTextField(
        label: 'Search description',
        hintText: 'e.g. EMI',
        onChanged: onQueryChanged,
      ),
    ];
    const flex = [1, 1, 1, 2];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 636) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s12,
            children: [
              for (var i = 0; i < fields.length; i++)
                Expanded(flex: flex[i], child: fields[i]),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s12,
          children: fields,
        );
      },
    );
  }
}
