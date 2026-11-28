# AR02: Accounts report page

**Goal:** the page at `/reports/accounts` with the filters, summary tiles, ledger table and paging, working in sample mode, plus the sidebar item.

**Prerequisites:** AR01 done.

## Files

| File | Change |
|------|--------|
| `lib/app/routes.dart` | `accountsReport = '/reports/accounts'` |
| `lib/app/router.dart` | the route |
| `lib/core/widgets/app_sidebar.dart` | `Accounts report` item after `Source report` |
| `lib/features/accounts_report/cubit/accounts_report_state.dart`, `accounts_report_cubit.dart` | state and Cubit |
| `lib/features/accounts_report/view/accounts_report_page.dart` | `AccountsReportPage` |
| `lib/features/accounts_report/widgets/ledger_filters.dart` | `LedgerFilters` |
| `lib/features/accounts_report/widgets/ledger_summary.dart` | `LedgerSummary` |
| `lib/features/accounts_report/widgets/ledger_table_card.dart` | `LedgerTableCard` |
| `test/features/accounts_report/accounts_report_cubit_test.dart` | new tests |

## State and Cubit

`AccountsReportState`: `status` (`LoadStatus`, with `error`), `sources` (all, active and archived), `from`, `to`, `sourceFilter` (`String?`), `typeFilter` (`TxType?`), `ledger` (`AccountLedger?`), `listLoading`, `errorMessage`, `actionError`. Defaults: `from` = `appMonth()`, `to` = the last day of that month (`DateTime(y, m + 1, 0)`). Use `copyWith` with explicit clear flags for the two nullable filters, as `TransactionsState` does.

`AccountsReportCubit(FinanceRepository)`, following the pattern of `TransactionsCubit` (a request counter so only the latest response is used, the old data stays visible while reloading):
- `load()`: sources plus page 1 of the ledger; sets `loaded` or `error` (with `friendlyError`).
- `setRange(DateTime from, DateTime to)`, `setSourceFilter(String?)`, `setTypeFilter(TxType?)`: update state and reload page 1.
- `goToPage(int)`; `clearActionError()`.
- A failure while reloading keeps the old data and sets `actionError` (the page shows it as a SnackBar).

## Page

`AccountsReportPage` creates the Cubit like the other pages and shows, in a column with spacing 20:

1. `PageHeader(title: 'Accounts report', subtitle: 'Every credit and debit with a running balance')`; in sample mode the subtitle starts with `Sample data · `.
2. `LedgerSummary` (below).
3. `LedgerTableCard` (below), which holds the filters, the table and the footer.

Loading shows a centred progress indicator, an error shows `ErrorView` with Try again, as on the other pages.

## LedgerFilters

A row of five fields (stacked in a column under 860px wide): **From** and **To** (`AppDateField`), **Bank account** (`All accounts` plus every bank account, archived ones marked `(archived)`), **Source** (`All sources` plus the sources it is given, archived ones marked `(archived)`), **Type** (`All types` plus every value of `TxType.values`). Picking a From after To moves To to the same day; picking a To before From moves From to the same day. Use the sentinel `'all'` for the three dropdowns (see `TransactionsListCard`).

The state has `bankAccounts` (from `allBankAccounts()`), `bankAccountFilter` and a getter `sourcesForFilter`: the sources of the chosen bank account, or all of them. The page passes `sourcesForFilter` to the filters. `setBankAccountFilter(id)` reloads page 1 and clears the source filter when the chosen source does not belong to that account.

## LedgerSummary

`ResponsiveWrap(minItemWidth: 200, spacing: 16)` of four `KpiTile`s: `Opening balance` (`Money.plain(opening)`), `Total credit`, `Total debit`, `Closing balance`. Under the tiles a `caption`: when a Type filter is set, `Closing is calculated over the shown rows only.`; otherwise nothing.

## LedgerTableCard

An `AppCard` with `LedgerFilters`, a 2px progress line while `listLoading`, then `AppTable(minWidth: 640)` with columns:

| Column | Width / flex | Align | Cell |
|--------|--------------|-------|------|
| Date | 110 | left | `AppDates.dayMonthYear(date)`, secondary, one line |
| Description | flex | left | description, one line with an ellipsis and a tooltip (see `AppTableText.maxLines`) |
| Credit | 120 | right | `Money.plain(credit)` in `AppColors.income`, or `—` (secondary) when zero |
| Debit | 120 | right | `Money.plain(debit)`, or `—` when zero |
| Closing | 130 | right | `Money.plain(closing)`, bold (negative shows `−₹…`) |

An empty result shows `EmptyNote('No entries in this range.')`. The footer matches the Transactions one: `Showing 1–10 of 10 entries` and `Previous` / `Page 1 of 1` / `Next` links.

## Router and sidebar

`page(AppRoutes.accountsReport, (_) => const AccountsReportPage())` inside the shell route; the sidebar item `('Accounts report', AppRoutes.accountsReport)` goes after `Source report`.

## Tests

`accounts_report_cubit_test.dart` with `MockFinanceRepository`: after `load()` the ledger covers November with 10 rows; `setTypeFilter(TxType.income)` leaves only credits; `setSourceFilter('salary')` leaves four rows; `setBankAccountFilter('sbi-rentals')` leaves five rows with `opening` 12000 and limits `sourcesForFilter` to Aqua 105 and VR; choosing `sbi-rentals` after the source `salary` clears the source filter, while a source that is in the account (`vr`) stays chosen; `setRange` to an October range gives no rows; the defaults are the first and last day of the mock month (1 and 30 Nov 2026).

## Do not

Add search or export. Change other pages.

## Verify (sample mode)

- [ ] The sidebar shows `Accounts report` and highlights it on the page; the page loads with From `1 Nov 2026` and To `30 Nov 2026`.
- [ ] The summary reads Opening `₹33,000`, Total credit `₹2,28,000`, Total debit `₹72,200`, Closing `₹1,88,800`.
- [ ] Ten rows, newest first; each row has either a Credit or a Debit and a `—` in the other; the oldest row (5 Nov, Salary credited) has Closing `₹1,53,000` and the newest `₹1,88,800`.
- [ ] Type = Income leaves the four income rows with only Credits, and the note about the shown rows appears; Source = Salary leaves four rows; Bank account = SBI Rentals leaves five rows, Opening `₹12,000`, Closing `₹69,000`, and the Source dropdown then offers only Aqua 105 and VR; picking an October range shows `No entries in this range.`
- [ ] Setting From after To moves To; nothing overflows at about 900px wide.
- [ ] `flutter analyze` and `flutter test` pass.
