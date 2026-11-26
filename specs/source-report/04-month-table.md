# Source report 04: Month-by-month table

**Goal:** the table of the last six months for the selected source. This completes the Source report.

**Prerequisites:** Source report 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/source_report/widgets/month_by_month_card.dart` | `MonthByMonthCard` |
| `lib/features/source_report/view/source_report_page.dart` | change: replace the "Month by month" placeholder |

## MonthByMonthCard

`MonthByMonthCard({required List<SourceMonthRow> months})` (newest first, rendered in the given order): an `AppCard` (padding 20) with:
1. Title `Month by month` in `sectionTitle`, 8px below it.
2. `AppTable(minWidth: 520)` with columns: Month (flex 1.2), Income, Expense, Invested / saved, Closing balance (flex 1 each, right-aligned except Month).
   - Month: `AppDates.monthYearShort(month)` in `bodyStrong`.
   - Income: `Money.plain(income)` in green (`AppColors.income`), **no plus sign**.
   - Expense: `Money.plain(expense)`, no minus sign.
   - Invested / saved: `Money.plain(investedSaved)`.
   - Closing balance: `Money.plain(closing)` bold.

## Expected content (sample data)

| Month | Income | Expense | Invested / saved | Closing balance |
|-------|-------:|--------:|-----------------:|----------------:|
| Nov 2026 | ₹45,000 | ₹12,000 | ₹10,000 | ₹31,000 |
| Oct 2026 | ₹45,000 | ₹10,500 | ₹40,000 | ₹8,000 |
| Sep 2026 | ₹45,000 | ₹11,000 | ₹30,000 | ₹13,500 |
| Aug 2026 | ₹45,000 | ₹8,500 | ₹35,000 | ₹9,500 |
| Jul 2026 | ₹45,000 | ₹14,000 | ₹25,000 | ₹8,000 |
| Jun 2026 | ₹45,000 | ₹9,000 | ₹40,000 | ₹2,000 |

## Verify

- [x] Six rows exactly as above, closing balance in bold.
- [x] The full Source report matches the wireframe: header, four tiles, chart, table; no placeholders remain.
- [x] `flutter analyze` is clean.
