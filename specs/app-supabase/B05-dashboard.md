# B05: Dashboard from the database

**Goal:** the Dashboard shows real balances, the bank reconciliation and the latest entries, and the month selector really changes the source cards.

**Prerequisites:** B04 done.

## Files

| File | Change |
|------|--------|
| `lib/core/models/bank_reconciliation.dart` | `bankBalance` and `asOf` become nullable; `difference` becomes `double?` |
| `lib/core/models/source_summary.dart` | add `double? monthOpening`; `opening` returns `monthOpening ?? source.openingBalance` |
| `lib/core/data/mock_finance_repository.dart` | pass `monthOpening` for the four mock summaries (15000, 6000, 8000, 4000) |
| `lib/core/data/supabase/row_mappers.dart` | add `sourceSummaryFromRow` |
| `lib/core/data/supabase/supabase_finance_repository.dart` | implement three methods |
| `lib/features/dashboard/cubit/dashboard_cubit.dart` | `changeMonth` reloads the cards |
| `lib/features/dashboard/widgets/reconciliation_strip.dart` | handle "no bank balance yet" |
| `lib/features/dashboard/widgets/source_balance_card.dart` | labels for other months |
| `lib/features/dashboard/widgets/source_cards_section.dart`, `dashboard_page.dart` | pass the labels |
| `lib/features/dashboard/widgets/bank_balance_dialog.dart` call site | handle nulls |
| `test/core/row_mappers_test.dart` | add tests |

## Repository

| Method | Implementation |
|--------|----------------|
| `reconciliation()` | rpc `current_reconciliation` returns one row: `sources_total`, `bank_balance` (may be null), `as_of` (may be null). Build `BankReconciliation(sourcesTotal, bankBalance, asOf)` with the nullable fields as they are |
| `sourceSummaries(month)` | rpc `source_summaries` with `p_month: sqlDate(month)`. Each row becomes a `SourceSummary`: `source` from `source_id`, `name`, `kind`, `opening_balance`, `is_active`; `monthOpening` from `month_opening`; income, expense, invested, saved, closing as named; `investedSavedToDate` from `invested_saved_to_date` |
| `recentTransactions()` | `transactions` ordered by `tx_date` descending then `created_at` descending, limit 6 |

## Dashboard behaviour

- `DashboardCubit.changeMonth(month)`: emit the new `month`, then fetch `sourceSummaries(month)` only and emit the new summaries (the rest of the page stays; no full-page spinner). On failure emit an error SnackBar through the page (put the message in a one-shot `errorMessage` that the page listens to) and keep the old data. Ignore a result that arrives after a newer month was chosen (keep a request counter).
- **Source cards:** `SourceBalanceCard` takes two new parameters, `balanceLabel` and `monthLabel`. For the current month (`month == appMonth()`) they are `Balance as on today` and `This month`; for any other month `Balance at end of ${AppDates.monthYear(month)}` and `AppDates.monthYear(month)`. `SourceCardsSection` and the page compute and pass them.
- **No cards:** if `summaries` is empty show `EmptyNote('No sources yet. Add one in Settings.')` instead of the cards.
- **Reconciliation strip:**
  - Bank balance present: as before.
  - `bankBalance == null`: the second item shows caption `Bank balance` and the value `Not set`; no status pill.
  - `asOf` shows in the caption only when it is not null.
- The "Update bank balance" call site (Dashboard 06) passes `currentBankBalance: data.bankBalance ?? data.sourcesTotal` and `asOf: data.asOf ?? appToday()`.
- Recent entries and quick add need no change (names resolve through `allSources()` from B04).

## Tests

Add to `row_mappers_test.dart`: a summary row with numbers as strings maps correctly (`opening` equals `month_opening`, `closing` as given); a reconciliation row with null bank balance maps to nulls.

## Do not

Make the reconciliation or recent entries depend on the selected month; they are "as of now". Write anything.

## Verify (Supabase mode, signed in, November 2026 and the sample data)

- [x] Source cards: Salary ₹53,200 with income +₹1,20,000, expense −₹55,800, invested −₹20,000, saved −₹6,000, to date ₹76,000; Side hustle ₹22,400 (+₹35,000, −₹8,600, −₹10,000, ₹0, to date ₹30,000); Aqua 105 ₹31,000 (+₹45,000, −₹12,000, ₹0, −₹10,000, to date ₹1,80,000); VR ₹25,800 (+₹28,000, −₹6,200, ₹0, ₹0, to date ₹24,000). The archived "Old freelance" card is not shown.
- [x] Strip: sum ₹1,32,400, bank ₹1,32,400 (entered 26 Nov), green "Matches" pill.
- [x] Recent entries: six rows, newest first: Home EMI and Groceries (25 Nov), SIP: index fund (24 Nov), the two Rent received entries (22 Nov, either order), Groceries (21 Nov).
- [x] Quick add: Home EMI, SIP: index fund, Rent received (Aqua 105), Internet bill.
- [x] Month selector, previous month: cards read "Balance at end of October 2026" and show Salary ₹15,000, Side hustle ₹6,000, Aqua 105 ₹8,000, VR ₹4,000. Go back to November: the numbers above return. Go to December 2026: balances stay (₹53,200 etc.) with all flows `₹0`.
- [x] Turn the network off (dev tools, Offline) and reload: the Dashboard shows "Could not reach the server. Check your connection." with a working "Try again" once back online.
- [x] Sample mode unchanged. `flutter analyze` and `flutter test` pass.
