# Monthly report 02: Totals (KPI tiles)

**Goal:** five KPI tiles with the month's totals.

**Prerequisites:** Monthly report 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/monthly_report/widgets/report_kpis.dart` | `ReportKpis` |
| `lib/features/monthly_report/view/monthly_report_page.dart` | change: replace the "Totals" placeholder |

## ReportKpis

`ReportKpis({required MonthlyReport report})` renders `ResponsiveWrap(minItemWidth: 170, spacing: 16)` of five `KpiTile`s:

| Label | Value |
|-------|-------|
| Income | `Money.plain(report.income)` |
| Expense | `Money.plain(report.expense)` |
| Invested | `Money.plain(report.invested)` |
| Saved | `Money.plain(report.saved)` |
| Savings rate (invested + saved) | `${(report.savingsRate * 100).round()}%` |

## Expected content (sample data)

`₹2,28,000`, `₹82,600`, `₹30,000`, `₹16,000`, `20%`.

## Do not

Compute totals in the widget; use the getters on `MonthlyReport`.

## Verify

- [x] Five tiles in one row on a wide window, wrapping on narrower ones, showing the values above.
- [x] `flutter analyze` is clean.
