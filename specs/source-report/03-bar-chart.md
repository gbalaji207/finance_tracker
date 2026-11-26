# Source report 03: Income vs spend chart

**Goal:** a grouped bar chart (income and expense per month) built from plain widgets, with a legend.

**Prerequisites:** Source report 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/source_report/widgets/income_vs_spend_card.dart` | `IncomeVsSpendCard` |
| `lib/features/source_report/view/source_report_page.dart` | change: replace the "Income vs spend chart" placeholder |

## IncomeVsSpendCard

`IncomeVsSpendCard({required List<SourceMonthRow> months})`. `months` arrives newest first; the chart shows them **oldest to newest, left to right** (reverse before drawing).

An `AppCard` (padding 20) with a `Column(crossAxisAlignment: stretch)`:

1. **Header row** (space-between, wrapping if needed), 16px below it: title `Income vs spend` in `sectionTitle`; legend on the right: two items 16px apart, each a 12×12 square (radius 3) and 6px gap and a label in `subtitle`: `AppColors.chartIncome` "Income", `AppColors.chartExpense` "Expense".
2. **Chart area:** height 190, horizontal padding 8, a 1px bottom border in `controlBorder`, wrapped in `Semantics(label: 'Bar chart: income against expense per month, June to November 2026', image: true)`. Inside, a `Row(crossAxisAlignment: end)` with 24px gaps and one `Expanded` group per month. Each group is a `Column(mainAxisAlignment: end, spacing: 6)`:
   - A `Row(mainAxisSize: min, crossAxisAlignment: end, spacing: 6)` of two bars, each **28 wide**, top corners radius 4:
     - income bar: color `chartIncome`, height `income / maxIncome * 160`;
     - expense bar: color `chartExpense`, height `expense / maxIncome * 160`;
     
     where `maxIncome` is the largest `income` among the months (so the tallest bar is 160). The bar area is 160 high and bars align to its bottom.
   - Month label `AppDates.monthShort(month)` in `caption`, 6px bottom padding.

No value labels on the bars and no extra packages.

## Expected content (sample data)

Six groups Jun, Jul, Aug, Sep, Oct, Nov. Income bars are all 160 high; expense bar heights are approximately 32, 50, 30, 39, 37, 43.

## Do not

Add tooltips, axes or interactivity.

## Verify

- [ ] Six groups in the order Jun to Nov with a teal income bar and an amber expense bar each, sitting on a thin baseline.
- [ ] Legend on the top right shows teal "Income" and amber "Expense".
- [ ] Expense bars are visibly lower than income bars with the heights above; nothing overflows when the window narrows to about 700px. `flutter analyze` is clean.
