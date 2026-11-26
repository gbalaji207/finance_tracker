# Source report 02: Summary tiles

**Goal:** four KPI tiles for the selected source.

**Prerequisites:** Source report 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/source_report/widgets/source_summary_tiles.dart` | `SourceSummaryTiles` |
| `lib/features/source_report/view/source_report_page.dart` | change: replace the "Summary" placeholder |

## SourceSummaryTiles

`SourceSummaryTiles({required SourceReport report})` renders `ResponsiveWrap(minItemWidth: 200, spacing: 16)` of four `KpiTile`s:

| Label | Value |
|-------|-------|
| Balance as on today | `Money.plain(report.balanceToday)` |
| Income this month | `Money.plain(report.incomeThisMonth)` |
| Expense this month | `Money.plain(report.expenseThisMonth)` |
| Invested / saved to date | `Money.plain(report.investedSavedToDate)` |

## Expected content (sample data)

`₹31,000`, `₹45,000`, `₹12,000`, `₹1,80,000`.

## Verify

- [x] Four tiles with the values above, wrapping on narrower windows.
- [x] `flutter analyze` is clean.
