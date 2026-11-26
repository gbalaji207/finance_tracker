# Monthly report 04: Expenses by category

**Goal:** the horizontal bar list of expense categories. This completes the Monthly report.

**Prerequisites:** Monthly report 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/monthly_report/widgets/expense_categories_card.dart` | `ExpenseCategoriesCard` |
| `lib/features/monthly_report/view/monthly_report_page.dart` | change: replace the "Expenses by category" placeholder |

## ExpenseCategoriesCard

`ExpenseCategoriesCard({required List<CategoryTotal> categories})`: an `AppCard` (padding 20) with `Column(crossAxisAlignment: stretch, spacing: 12)`:
1. Title `Expenses by category` in `sectionTitle`.
2. One `CategoryBarRow` per category, in the given order: `label: name`, `amountText: Money.plain(amount)`, `fraction: amount / maxAmount` where `maxAmount` is the largest amount in the list.

## Expected content (sample data)

| Category | Amount | Bar fraction (approx.) |
|----------|-------:|-----------------------:|
| Housing | ₹32,000 | 1.00 |
| Groceries | ₹15,000 | 0.47 |
| Property upkeep | ₹14,600 | 0.46 |
| Other | ₹12,000 | 0.38 |
| Utilities | ₹9,000 | 0.28 |

## Do not

Sort or filter in the widget; render in the order given.

## Verify

- [x] Five rows with teal bars whose lengths follow the fractions above and amounts right-aligned.
- [x] The whole Monthly report matches the wireframe; no placeholder boxes remain. `flutter analyze` is clean.
