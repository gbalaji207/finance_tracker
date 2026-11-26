import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/transaction_page.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/widgets/amount_text.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
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
  });

  final TransactionPage page;
  final List<Source> sources;
  final DateTime month;
  final String? sourceFilter;
  final TxType? typeFilter;
  final String Function(String sourceId) sourceName;
  final String Function(String? categoryId) categoryName;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<String?> onSourceChanged;
  final ValueChanged<TxType?> onTypeChanged;
  final ValueChanged<String> onQueryChanged;

  /// Sentinel for "all": a dropdown item with a null value does not show as
  /// selected, so "all" is a real value that is mapped back to null.
  static const _all = 'all';

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _filters(),
          const SizedBox(height: AppSpacing.s16),
          AppTable(
            // Scrolls sideways instead of overflowing in a narrow card.
            minWidth: 640,
            columns: const [
              AppTableColumn('Date', width: 56),
              AppTableColumn('Description'),
              AppTableColumn('Source', width: 104),
              AppTableColumn('Category', width: 112),
              AppTableColumn('Type', width: 100),
              AppTableColumn('Amount', width: 100, align: TextAlign.right),
            ],
            rows: [
              for (final t in page.items)
                AppTableRow([
                  AppTableText(AppDates.dayMonth(t.date), secondary: true),
                  AppTableText(t.description),
                  AppTableText(sourceName(t.sourceId)),
                  AppTableText(categoryName(t.categoryId), secondary: true),
                  TypeBadge(t.type),
                  AmountText(amount: t.amount, type: t.type),
                ]),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${page.items.length} of ${page.total} entries',
                style: AppTextStyles.subtitle,
              ),
              Text(
                'Page ${page.page} of ${page.pageCount}',
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    final monthLabel = AppDates.monthYear(month);
    final fields = <Widget>[
      AppDropdown<String>(
        label: 'Month',
        value: monthLabel,
        items: [AppDropdownItem(monthLabel, monthLabel)],
        onChanged: (_) => onMonthChanged(month),
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
