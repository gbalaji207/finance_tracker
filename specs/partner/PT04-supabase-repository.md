# PT04: Real repository for partner transfers

**Goal:** `SupabaseFinanceRepository` reads the new `partner` figures, so the Dashboard, Monthly report and Source report show them against the migrated database, and Partner categories and entries can be saved.

**Prerequisites:** PT03 done (the migration has run).

## Files

| File | Change |
|------|--------|
| `lib/core/data/supabase/row_mappers.dart` | read `partner` |
| `lib/core/data/supabase/supabase_finance_repository.dart` | `sourceReport` fills `partnerThisMonth` |
| `test/core/row_mappers_test.dart` | new tests |

## Mappers

- `sourceSummaryFromRow`: add `partner: toDouble(r['partner'])`.
- `sourceMonthRowFromRow`: add `partner: toDouble(r['partner'])`.
- `categoryFromRow`, `categoryUsageFromRow`, `templateFromRow`, `transactionFromRow` already use `TxType.values.byName(...)`, so `'partner'` maps with no change.

Use the missing-safe form for both new fields so an old row without the column still maps: `r['partner'] == null ? 0 : toDouble(r['partner'])`.

## Repository

- `sourceReport(sourceId)`: add `partnerThisMonth: thisMonth?.partner ?? 0`, next to `incomeThisMonth` and `expenseThisMonth`.
- No other change: `monthlyReport` already returns the summaries (the `partner` total comes from `MonthlyReport.partner`), `expense_by_category` deliberately excludes Partner, and category and entry writes send `type.name` / `kind.name`, which is now `partner`.

## Tests

In `row_mappers_test.dart`: a `source_summaries` row with `partner` given as a string (`"8000.00"`) and one without the key (partner 0); a `source_month_rows` row with `partner`; a category row with kind `partner`; a transaction row with type `partner`.

## Do not

Add a Partner filter beyond the existing type filter, or change SQL (a database change goes in a new numbered file).

## Verify (Supabase mode, signed in, after PT03)

- [ ] Settings: create a category `Day-to-day` with kind Partner. It appears with the purple badge and 0 entries.
- [ ] Transactions: add an entry, type Partner, source Salary, category Day-to-day, amount 1000, today's date. It saves ("Entry saved") and shows with a Partner badge and `−₹1,000`. Changing the type to Expense hides the Day-to-day category; Income still needs no category.
- [ ] Dashboard: Salary's balance dropped by ₹1,000, its Partner row reads `−₹1,000`, Expense did not change. The reconciliation strip now reads `Off by ₹1,000` for Salary's bank account until you enter the lower bank balance (the account's sources total fell by 1,000): record the new bank balance in the dialog and it matches again.
- [ ] Monthly report (current month): the By source table has Partner `−₹1,000` on Salary and `₹1,000` in the total; the KPI tile Partner is ₹1,000; total Expense and the savings rate did not change, and Day-to-day is not in Expense by category. Closing equals Opening + Income − Expense − Invested − Saved − Partner.
- [ ] Source report for Salary: `Partner this month ₹1,000`, and the current month row's Partner column shows ₹1,000.
- [ ] Edit the entry to 1500, then delete it: the figures follow and return to the original.
- [ ] A Partner template can be created and used (it fills type, source and the Partner category).
- [ ] Sample mode still works. `flutter analyze` and `flutter test` pass.

## After this

A Partner category with entries cannot be deleted (foreign keys), only archived, like any other category. Add one entry per transfer; there is nothing to configure per month.
