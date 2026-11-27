# PT02: Partner in the reports and source cards

**Goal:** show the partner transfer in the three places: the Monthly report (table column and KPI tile), the Dashboard source cards, and the Source report (summary tile and month table column).

**Prerequisites:** PT01 done.

## Files

| File | Change |
|------|--------|
| `lib/features/monthly_report/widgets/by_source_card.dart` | Partner column |
| `lib/features/monthly_report/widgets/report_kpis.dart` | Partner tile |
| `lib/features/dashboard/widgets/source_balance_card.dart` | Partner row |
| `lib/features/source_report/widgets/source_summary_tiles.dart` | Partner tile |
| `lib/features/source_report/widgets/month_by_month_card.dart` | Partner column |

## Monthly report: By source

`AppTable(minWidth: 720)` (was 640). Columns in this order: Source, Opening, Income, Expense, Invested, Saved, **Partner**, Closing. The new column is right aligned like the others.

- Source rows: `AppTableText(Money.signed(s.partner, TxType.partner))` (so `−₹8,000`, and `₹0` for zero).
- Total row: `AppTableText(Money.plain(report.partner), bold: true)`.
- Footer caption becomes `Closing = opening + income − expense − invested − saved − partner`.

## Monthly report: KPI tiles

In `ReportKpis` add `KpiTile(label: 'Partner', value: Money.plain(report.partner))` **between Saved and the savings rate tile** (six tiles). Everything else unchanged; the savings rate does not include it.

## Dashboard: source card

In `SourceBalanceCard`'s "This month" block add, directly under Saved:
```dart
KeyValueRow(label: 'Partner', value: Money.signed(summary.partner, TxType.partner))
```
Nothing else on the card changes (balance, `Invested / saved to date`).

## Source report

- `SourceSummaryTiles`: add `KpiTile(label: 'Partner this month', value: Money.plain(report.partnerThisMonth))` after `Expense this month` (five tiles; keep `minItemWidth: 200`).
- `MonthByMonthCard`: `minWidth: 600` (was 520); columns Month, Income, Expense, Invested / saved, **Partner**, Closing balance. Partner cell: `AppTableText(Money.plain(m.partner))`.
- `IncomeVsSpendCard` (the bar chart) is **not** changed: its Expense bar stays expenses only.

## Expected content (sample data)

- Monthly report, By source (November): Salary Partner `−₹8,000`, the other three `₹0`; Total `₹8,000`. Salary's Expense reads `−₹47,800`, Total expense `₹74,600`. KPI tiles: Income ₹2,28,000, Expense ₹74,600, Invested ₹30,000, Saved ₹16,000, **Partner ₹8,000**, savings rate 20%.
- Dashboard: the Salary card shows Partner `−₹8,000`; the other cards `₹0`.
- Source report (Aqua 105): tile `Partner this month ₹0`; the Sep 2026 row shows Expense ₹6,000 and Partner ₹5,000, all other rows ₹0.

## Do not

Change the formulas, the chart, or the Expense by category card. Add a filter or link from the Partner figures.

## Verify

- [ ] The By source table shows the Partner column between Saved and Closing, with the values above; the Closing column still equals Opening + Income − Expense − Invested − Saved − Partner for every row.
- [ ] Six KPI tiles; the savings rate is still 20%. They wrap cleanly at 900px wide.
- [ ] The Salary card on the Dashboard has the Partner row; the cards' balances are unchanged.
- [ ] Source report: the new tile and the Partner column show; the chart looks as before.
- [ ] `flutter analyze` and `flutter test` pass.
