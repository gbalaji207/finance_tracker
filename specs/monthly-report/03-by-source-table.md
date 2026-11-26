# Monthly report 03: By-source table

**Goal:** the table showing opening, flows and closing balance per source, with a totals row.

**Prerequisites:** Monthly report 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/monthly_report/widgets/by_source_card.dart` | `BySourceCard` |
| `lib/features/monthly_report/view/monthly_report_page.dart` | change: replace the "By source" placeholder |

## BySourceCard

`BySourceCard({required MonthlyReport report})`: an `AppCard` (padding 20) with `Column(crossAxisAlignment: start)`:

1. Title `By source` in `sectionTitle`, 8px below it.
2. `AppTable(minWidth: 640)` with columns: Source (flex 1.3), Opening, Income, Expense, Invested, Saved, Closing (flex 1 each, all right-aligned except Source).
   - **Source rows:** name `bodyStrong`; Opening `Money.plain(opening)`; Income `Money.signed(income, TxType.income)` in green; Expense, Invested, Saved via `Money.signed` with their types; Closing `Money.plain(closing)` bold.
   - **Totals row** (`highlight: true`, bold text): `Total`, then plain `Money.plain` of `report.opening`, `income` (green), `expense`, `invested`, `saved`, `closing`. No plus/minus signs in this row.
3. A footnote 12px below the table in `caption`: `Closing = opening + income − expense − invested − saved`.

## Expected content (sample data)

| Source | Opening | Income | Expense | Invested | Saved | Closing |
|--------|--------:|-------:|--------:|---------:|------:|--------:|
| Salary | ₹15,000 | +₹1,20,000 | −₹55,800 | −₹20,000 | −₹6,000 | ₹53,200 |
| Side hustle | ₹6,000 | +₹35,000 | −₹8,600 | −₹10,000 | ₹0 | ₹22,400 |
| Aqua 105 | ₹8,000 | +₹45,000 | −₹12,000 | ₹0 | −₹10,000 | ₹31,000 |
| VR | ₹4,000 | +₹28,000 | −₹6,200 | ₹0 | ₹0 | ₹25,800 |
| **Total** | ₹33,000 | ₹2,28,000 | ₹82,600 | ₹30,000 | ₹16,000 | ₹1,32,400 |

## Do not

Add sorting or row actions.

## Verify

- [ ] Table values match the table above; the Total row is shaded and bold.
- [ ] With the window narrower than about 900px the table scrolls horizontally instead of overflowing.
- [ ] The footnote is visible under the table. `flutter analyze` is clean.
