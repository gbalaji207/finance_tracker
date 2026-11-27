# B06: Reports from the database

**Goal:** the Monthly report and the Source-wise report show real numbers; the month selector and the source dropdown really work.

**Prerequisites:** B05 done.

## Files

| File | Change |
|------|--------|
| `lib/core/data/supabase/supabase_finance_repository.dart` | implement `monthlyReport`, `sourceReport` |
| `lib/core/models/monthly_report.dart` | `savingsRate` safe when income is 0 |
| `lib/core/data/mock_finance_repository.dart` | `sourceReport(id)` labels the report with the requested source |
| `lib/features/monthly_report/cubit/*`, `view/monthly_report_page.dart` | real month change |
| `lib/features/source_report/cubit/*`, `view/source_report_page.dart` | real source dropdown |
| `lib/features/source_report/widgets/income_vs_spend_card.dart` | scale and label fixes |
| `lib/features/source_report/widgets/month_by_month_card.dart` | empty case |
| `lib/features/monthly_report/widgets/expense_categories_card.dart` | empty case |
| `lib/core/data/supabase/row_mappers.dart`, `test/core/row_mappers_test.dart` | mappers and tests |

## Repository

**`monthlyReport(month)`**: run in parallel (`Future.wait`) `sourceSummaries(month)` and rpc `expense_by_category` with `p_month`. Result: `MonthlyReport(bySource: summaries, expenseByCategory: rows.map(CategoryTotal(name: row['category'], amount: toDouble(row['amount']))))`. The rpc already returns largest first.

**`sourceReport(sourceId)`**:
1. The source: `allSources()` entry with that id (throw `StateError('Source not found')` if missing).
2. This month's row: `sourceSummaries(appMonth())`, the entry for the source (when the source is missing from the result, use zeros).
3. `balanceToday`: `sourceBalance(sourceId)`.
4. `months`: rpc `source_month_rows` with `p_source`, `p_end_month: sqlDate(appToday())`, `p_months: 6`, mapped to `SourceMonthRow(month: parsed date, income, expense, investedSaved: invested_saved, closing)`. Order is already newest first.
5. `SourceReport(source, balanceToday, incomeThisMonth: income, expenseThisMonth: expense, investedSavedToDate: invested_saved_to_date, months)`.

Add `sourceMonthRowFromRow` to the mappers.

## Model fix

`MonthlyReport.savingsRate`: return `0` when `income == 0` (instead of dividing by zero).

## Monthly report behaviour

- `MonthlyReportCubit.changeMonth(month)`: emit the new month, fetch `monthlyReport(month)`, emit it. No full-page spinner (keep the old report until the new one arrives); ignore stale results with a request counter; on failure the page shows `AppSnack.error` and keeps the old data.
- `ExpenseCategoriesCard`: when `expenseByCategory` is empty show `EmptyNote('No expenses in this month.')` in its place.
- The page subtitle and "Export CSV" button stay as they are.

## Source report behaviour

- State: `selectedSourceId` becomes `String?` (initially `null`); add `List<Source> sources`.
- `load()`: fetch `allSources()`; the selected id is the current one, or the first **active** source (or the first source when none is active); then fetch `sourceReport(id)`; emit loaded. No sources: loaded with `report == null`, and the page shows `EmptyNote('No sources yet. Add one in Settings.')` below the header.
- `select(String id)`: set the id, fetch that report, emit (keep the old report until the new one arrives, same stale-result guard, error as SnackBar).
- Page: the Source dropdown lists every source from state (archived ones labelled `"${name} (archived)"`), value = selected id, `onChanged` calls `select`. The Period dropdown stays a single "Last 6 months" option.
- `MockFinanceRepository.sourceReport(id)` still returns the Aqua 105 numbers but sets `source` to the requested source (looked up in the mock sources, falling back to Aqua 105), so the header and dropdown agree in sample mode.
- `IncomeVsSpendCard`:
  - Scale: use `maxValue` = the largest of all `income` and `expense` values across the months (instead of the largest income) so no bar can exceed 160. When `maxValue` is 0 every bar is 0 high. In sample data the maximum is still 45000, so nothing changes there.
  - The `Semantics` label is built from the data: `Bar chart: income against expense per month, ${monthYearShort(oldest)} to ${monthYearShort(newest)}`.
  - Fewer than six months (a young source) must render without overflow; no months: `EmptyNote('No history yet.')`.
- `MonthByMonthCard`: no months shows the same `EmptyNote`.

## Tests

Add: a `source_month_rows` row maps to `SourceMonthRow`; `MonthlyReport` with income 0 has `savingsRate == 0`.

## Verify (Supabase mode, signed in)

- [x] Monthly report, November 2026: income ₹2,28,000, expense ₹82,600, invested ₹30,000, saved ₹16,000, closing ₹1,32,400, savings rate about 20%. By-source table: openings 15,000 / 6,000 / 8,000 / 4,000 (total ₹33,000) and the four closing balances from the Dashboard. Categories: Housing ₹32,000, Groceries ₹15,000, Property upkeep ₹14,600, Other ₹12,000, Utilities ₹9,000.
- [x] Previous month (October 2026): income ₹2,23,000, expense ₹76,600, invested ₹40,000, saved ₹94,000, closing ₹33,000; categories Housing ₹32,000, Groceries ₹14,000, Other ₹12,000, Property upkeep ₹10,500, Utilities ₹8,100.
- [x] A month with no entries (for example January 2027): totals show ₹0, savings rate 0%, "No expenses in this month." and no crash.
- [x] Source report: choosing **Aqua 105** shows balance ₹31,000, income this month ₹45,000, expense ₹12,000, to date ₹1,80,000, and the six months June to November with closing 2,000 / 8,000 / 9,500 / 13,500 / 8,000 / 31,000 (as in the wireframe table, oldest at the bottom).
- [x] Choosing **Salary** shows only October and November: November income ₹1,20,000, expense ₹55,800, invested/saved ₹26,000, closing ₹53,200; October income ₹1,20,000, expense ₹57,000, invested/saved ₹50,000, closing ₹15,000. The chart shows two groups without overflow.
- [x] **Old freelance** (archived) shows balance ₹0 and an empty or near-empty history without errors.
- [x] Sample mode: Source report still shows the Aqua 105 numbers; its dropdown now lists the five sample sources. `flutter analyze` and `flutter test` pass.
