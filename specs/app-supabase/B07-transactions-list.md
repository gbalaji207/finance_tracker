# B07: Transactions list with real filters and paging

**Goal:** the Transactions list queries the database: month, source and type filters, description search and Previous/Next paging all work.

**Prerequisites:** B06 done (B05 for the shared helpers).

## Files

| File | Change |
|------|--------|
| `lib/core/data/finance_repository.dart` | change the `transactions` signature |
| `lib/core/data/mock_finance_repository.dart` | accept the new parameters and still return the same page |
| `lib/core/data/supabase/supabase_finance_repository.dart` | implement `transactions` |
| `lib/features/transactions/cubit/transactions_state.dart`, `transactions_cubit.dart` | filters drive queries |
| `lib/features/transactions/widgets/transactions_list_card.dart` | month list, footer, loading, empty |
| `lib/features/transactions/cubit/add_entry_cubit.dart`, `widgets/add_entry_panel.dart` | id-free defaults |
| `lib/features/transactions/view/transactions_page.dart` | wiring |

## Repository

```dart
Future<TransactionPage> transactions({
  DateTime? month,            // null = all months
  String? sourceId,
  TxType? type,
  String query = '',
  int page = 1,
});
const kPageSize = 10;         // in finance_repository.dart
```
Mock: same parameters, still ignores them.

Supabase: select `id, tx_date, type, source_id, category_id, amount, description` from `transactions`, then
- month: `tx_date >= first day` and `< first day of next month` (`sqlDate`);
- sourceId: `eq source_id`; type: `eq type` with `type.name`;
- query (trimmed, non-empty): `ilike description` with `%query%`; escape `\`, `%` and `_` in the text first;
- order by `tx_date` descending, then `created_at` descending;
- `range((page-1)*kPageSize, page*kPageSize-1)` and ask for the exact total count in the same request (the package's `count(CountOption.exact)`; adapt to the installed version).

Result: `TransactionPage(items, total, page, pageCount: max(1, ceil(total / kPageSize)))`.

## State and cubit

`TransactionsState`: `month` becomes `DateTime?` and starts as `appMonth()`; add `bool listLoading` (initially false).

`TransactionsCubit`:
- `load()` loads the reference data and then the first page with the current filters.
- `setMonth`, `setSourceFilter`, `setTypeFilter`: update the filter, reset to page 1 and reload the list only.
- `setQuery(text)`: update `query` immediately (so the field keeps what is typed) and reload page 1 after 300 ms of no typing (a `Timer` cancelled in `close()`).
- `goToPage(n)`: reload that page.
- Reloading the list sets `listLoading: true` first and keeps the old page visible. A request counter ignores any response that is not the latest. A failure sets `listLoading: false` and surfaces a message through a one-shot `errorMessage` the page shows with `AppSnack.error`.
- If a loaded page is empty while `total > 0` and `page > 1` (after deletions), load the last page instead.
- Provide `Future<void> reloadList()` for later specs (reload current filters and page).

## List card

- Month dropdown: `All months` (value `'all'`) plus the current month and the 11 before it, newest first (value `yyyy-MM`, label `AppDates.monthYear`); `onMonthChanged` is `ValueChanged<DateTime?>` (null = all). Use the current `month` as the selected value (if it is outside those 12, add it to the items).
- Search field: unchanged, calls `onQueryChanged`; it must not lose focus or text when the list reloads (keep it outside the part that rebuilds from loading state, or give it a stable controller).
- A `LinearProgressIndicator` (height 2, color `AppColors.primary`) above the table while `listLoading`.
- No rows: `EmptyNote('No entries match these filters.')` instead of the table.
- Footer: left text `Showing ${from}–${to} of $total entries` (`No entries` when total is 0); right side a `Row(spacing: 12)` of `AppTextLink('Previous')` (hidden on page 1), `Page ${page} of ${pageCount}`, `AppTextLink('Next')` (hidden on the last page). New parameter `ValueChanged<int> onPageChanged`.

## Entry panel defaults (no hardcoded ids)

- `AddEntryCubit` defaults: `type` expense; `sourceId` the first source of the constructor's list (`''` if it is empty); `categoryId` the first category whose kind is expense (null if none); `date` `appToday()`. (In sample data the default category is therefore **Housing** instead of Groceries.)
- Use `activeSources` and `activeCategories` (B04) for the panel and the cubit.
- If there are no active sources the panel shows `InfoBox` text `Add a source in Settings before adding entries.` instead of the form.

## Do not

Write anything. Keep the filters in memory only (not in the URL).

## Verify (Supabase mode, sample data)

- [x] Default view: month November 2026, footer `Showing 1–10 of 27 entries`, `Page 1 of 3`, "Next" visible, "Previous" hidden. Next, Next: `Showing 21–27 of 27 entries`, "Next" hidden.
- [x] Source = Aqua 105 gives 4 entries; Type = Income gives 4; Type = Investment gives 2 (SIP: index fund and Mutual fund top-up); both together (Aqua 105 + Income) give 1.
- [x] Search `groceries` gives 6 entries; clearing it restores 27. Typing quickly does not flicker or reorder results.
- [x] Month = All months: 56 entries, `Page 1 of 6`; searching `EMI` there gives 2 (October and November Home EMI). Month = October 2026: 17 entries.
- [x] Search for text that matches nothing shows "No entries match these filters."
- [x] Rows show names of sources and categories (no raw ids), income rows show `—` as category.
- [x] Sample mode: footer reads `Showing 1–10 of 38 entries`, `Page 1 of 4` with "Next" visible (the list itself does not change in sample mode); the entry panel now defaults to category Housing.
- [x] `flutter analyze` and `flutter test` pass.
