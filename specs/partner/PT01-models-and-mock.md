# PT01: Partner type, models and mock data

**Goal:** the data layer for partner transfers in sample mode: the new `TxType.partner`, the new amounts in the report models, a Partner category in the mock data, mock figures that include a transfer, and tests. The report and card layouts change in PT02; here only the minimum UI changes needed so you can create the category and an entry.

**Prerequisites:** BA07 done.

## Files

| File | Change |
|------|--------|
| `lib/core/theme/app_colors.dart` | `partnerFg`, `partnerBg` |
| `lib/core/models/tx_type.dart` | new value `partner` |
| `lib/core/models/source_summary.dart` | `partner` |
| `lib/core/models/monthly_report.dart` | `partner` getter |
| `lib/core/models/source_report.dart` | `SourceMonthRow.partner`, `SourceReport.partnerThisMonth` |
| `lib/features/settings/widgets/new_category_card.dart` | Partner is a choosable kind |
| `lib/features/settings/widgets/categories_card.dart` | description text |
| `lib/core/data/mock_finance_repository.dart` | mock data and in-memory copies |
| `test/core/mock_finance_repository_test.dart`, `test/core/balance_math_test.dart` | tests |

## Colors and type

```dart
// AppColors, next to the other type pairs
static const partnerFg = Color(0xFF4C1D95);
static const partnerBg = Color(0xFFEFE6FA);
```

`TxType` gets `partner` **last** (after `savings`): label `Partner`, `badgeBg` = `partnerBg`, `badgeFg` = `partnerFg`. Every `switch` over `TxType` must stay exhaustive. Money direction does not change: `Money.signed(8000, TxType.partner)` is `−₹8,000`, and `balance_math.dart` already treats every non-income type as outgoing (do not change it).

Places that loop over `TxType.values` (the Type selector in the entry panel, the template form dropdown, the Transactions type filter, the badge previews) pick the new value up automatically. Check that the entry panel's five type buttons still fit without overflow (labels already scale down).

## Models

```dart
// SourceSummary: new field, default keeps old call sites compiling
const SourceSummary({ /* existing */, this.partner = 0 });
final double partner;          // sent to the partner this month; add to props

// MonthlyReport
double get partner => _sum((s) => s.partner);

// SourceMonthRow: new field with default 0, add to props
final double partner;
// SourceReport: new field with default 0, add to props
final double partnerThisMonth;
```
`savingsRate` is unchanged. Update the closing-balance comment where one exists: `closing = opening + income − expense − invested − saved − partner`.

## Settings

- `NewCategoryCard`: `_kinds` becomes `[expense, investment, savings, partner]`; update the doc comment accordingly. The default stays Expense.
- `CategoriesCard`: change the description sentence so it says the categories are used for expense, investment, savings and partner entries (keep the rest of the sentence as it is).

## Mock data

All other mock numbers stay as they are, so the reconciliation, bank balances and closing balances do **not** change. The transfer is carved out of figures that already exist:

- New mock category `partner-allowance`, name `Partner allowance`, kind `partner`, active, listed after `fixed-deposit` (so `categories()` has 8).
- **Salary summary:** `expense` 55800 becomes **47800** and `partner` is **8000**. Closing stays 53200 (15000 + 120000 − 47800 − 20000 − 6000 − 8000).
- Side hustle, Aqua 105 and VR: `partner` 0 (the default).
- **Monthly report:** expense total becomes **74600**, partner total **8000**; income, invested, saved, opening and closing unchanged. `expenseByCategory` (descending): Housing 32000, Groceries 15000, Property upkeep 14600, Utilities 9000, **Other 4000** (amounts sum to 74600).
- **Source report (Aqua 105):** `partnerThisMonth` 0. In `months`, only **2026-09** changes: `expense` 11000 becomes **6000** and `partner` is **5000** (closing stays 13500). All other rows have `partner` 0.
- `_summariesNow` (the copy that carries edited source details) and any other place that rebuilds a `SourceSummary` must copy `partner`; sources added in memory get `partner` 0.

## Tests

- `mock_finance_repository_test.dart`: update the closing-balance check to `closing == opening + income − expense − invested − saved − partner` for every summary; the sum of `closing` is still 132400 and `reconciliation().difference` still 0; `monthlyReport` totals: income 228000, expense 74600, invested 30000, saved 16000, **partner 8000**, and `expenseByCategory` sums to 74600; `categories()` includes `Partner allowance` with kind `partner`; `sourceReport('aqua-105').months` still has 6 rows and the 2026-09 row has partner 5000. Fix any other assertion that used the old expense figures (55800, 82600, 12000 for Other).
- `balance_math_test.dart`: a `TxType.partner` entry reduces the balance like an expense.

## Do not

Change the Monthly report, Dashboard or Source report layouts (PT02), touch Supabase code (PT04), or add a Partner entry to the mock transaction lists.

## Verify

- [ ] `flutter analyze` is clean and `flutter test` passes.
- [ ] Sample mode, Settings: the New category Kind dropdown offers Partner; saving a Partner category shows it in the list with a purple `Partner` badge.
- [ ] Transactions: the New entry panel has five type buttons (Partner last) that fit; choosing Partner lists only the Partner categories; the type filter has a Partner option.
- [ ] Dashboard figures are the same as before except Salary's Expense (now ₹47,800). Balances, the reconciliation strip and bank balances are unchanged.
- [ ] Monthly report: Expense total is ₹74,600 and Other is ₹4,000 in the categories list; nothing else moved. The Partner amount is not displayed yet.
