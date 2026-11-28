import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/account_ledger.dart';
import 'package:finance_tracker/core/models/bank_account.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/app_dates.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_table.dart';
import 'package:finance_tracker/core/widgets/app_text_link.dart';
import 'package:finance_tracker/core/widgets/empty_note.dart';
import 'package:finance_tracker/features/accounts_report/widgets/ledger_filters.dart';
import 'package:flutter/material.dart';

/// The filters, the ledger table and the paging footer.
class LedgerTableCard extends StatelessWidget {
  const LedgerTableCard({
    super.key,
    required this.ledger,
    required this.bankAccounts,
    required this.sources,
    required this.from,
    required this.to,
    required this.bankAccountFilter,
    required this.sourceFilter,
    required this.typeFilter,
    required this.onRangeChanged,
    required this.onBankAccountChanged,
    required this.onSourceChanged,
    required this.onTypeChanged,
    required this.onPageChanged,
    this.listLoading = false,
  });

  final AccountLedger ledger;
  final List<BankAccount> bankAccounts;

  /// Already limited to the chosen bank account.
  final List<Source> sources;
  final DateTime from;
  final DateTime to;
  final String? bankAccountFilter;
  final String? sourceFilter;
  final TxType? typeFilter;
  final void Function(DateTime from, DateTime to) onRangeChanged;
  final ValueChanged<String?> onBankAccountChanged;
  final ValueChanged<String?> onSourceChanged;
  final ValueChanged<TxType?> onTypeChanged;
  final ValueChanged<int> onPageChanged;
  final bool listLoading;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LedgerFilters(
            from: from,
            to: to,
            bankAccounts: bankAccounts,
            sources: sources,
            bankAccountFilter: bankAccountFilter,
            sourceFilter: sourceFilter,
            typeFilter: typeFilter,
            onRangeChanged: onRangeChanged,
            onBankAccountChanged: onBankAccountChanged,
            onSourceChanged: onSourceChanged,
            onTypeChanged: onTypeChanged,
          ),
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
          if (ledger.rows.isEmpty)
            const EmptyNote('No entries in this range.')
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
      minWidth: 640,
      columns: const [
        AppTableColumn('Date', width: 110),
        AppTableColumn('Description'),
        AppTableColumn('Credit', width: 120, align: TextAlign.right),
        AppTableColumn('Debit', width: 120, align: TextAlign.right),
        AppTableColumn('Closing', width: 130, align: TextAlign.right),
      ],
      rows: [
        for (final r in ledger.rows)
          AppTableRow([
            AppTableText(
              AppDates.dayMonthYear(r.date),
              secondary: true,
              maxLines: 1,
            ),
            AppTableText(r.description, maxLines: 1),
            r.credit == 0
                ? const AppTableText('—', secondary: true)
                : AppTableText(
                    Money.plain(r.credit),
                    color: AppColors.income,
                    maxLines: 1,
                  ),
            r.debit == 0
                ? const AppTableText('—', secondary: true)
                : AppTableText(Money.plain(r.debit), maxLines: 1),
            AppTableText(Money.plain(r.closing), bold: true, maxLines: 1),
          ]),
      ],
    );
  }

  Widget _footer() {
    final total = ledger.total;
    final first = total == 0 ? 0 : (ledger.page - 1) * kLedgerPageSize + 1;
    final last = total == 0 ? 0 : first + ledger.rows.length - 1;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.s16,
      runSpacing: AppSpacing.s8,
      children: [
        Text(
          total == 0 ? 'No entries' : 'Showing $first–$last of $total entries',
          style: AppTextStyles.subtitle,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            if (ledger.page > 1)
              AppTextLink(
                label: 'Previous',
                onPressed: () => onPageChanged(ledger.page - 1),
              ),
            Text(
              'Page ${ledger.page} of ${ledger.pageCount}',
              style: AppTextStyles.subtitle,
            ),
            if (ledger.page < ledger.pageCount)
              AppTextLink(
                label: 'Next',
                onPressed: () => onPageChanged(ledger.page + 1),
              ),
          ],
        ),
      ],
    );
  }
}
