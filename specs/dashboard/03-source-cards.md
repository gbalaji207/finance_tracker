# Dashboard 03: Source balance cards

**Goal:** one card per source showing today's balance, this month's flows and the invested/saved total.

**Prerequisites:** Dashboard 01 done (02 is independent).

## Files

| File | Class |
|------|-------|
| `lib/features/dashboard/widgets/source_balance_card.dart` | `SourceBalanceCard` |
| `lib/features/dashboard/widgets/source_cards_section.dart` | `SourceCardsSection` |
| `lib/features/dashboard/view/dashboard_page.dart` | change: replace the "Source balance cards" placeholder |

## SourceCardsSection

`SourceCardsSection({required List<SourceSummary> summaries})` renders `ResponsiveWrap(minItemWidth: 220, maxColumns: 4, spacing: 16)` of `SourceBalanceCard`s.

## SourceBalanceCard

`SourceBalanceCard({required SourceSummary summary})`: an `AppCard` (padding 20) with a `Column(crossAxisAlignment: start, spacing: 12)`:

1. **Title row** (space-between): source name in `cardTitle`; source `kind` in `caption`.
2. **Balance block:** `Balance as on today` in `caption`, then `Money.plain(closing)` in `balanceValue`.
3. **This month block:** a top border (1px `divider`) with 12px padding above the content, then a `Column(spacing: 6)`:
   - `This month` in `caption`
   - `KeyValueRow('Income', Money.signed(income, TxType.income), valueColor: AppColors.income)`
   - `KeyValueRow('Expense', Money.signed(expense, TxType.expense))`
   - `KeyValueRow('Invested', Money.signed(invested, TxType.investment))`
   - `KeyValueRow('Saved', Money.signed(saved, TxType.savings))`
4. **Footer:** a top border (1px `divider`) with 12px padding above: a `Text.rich` with `Invested / saved to date ` in `caption`, followed by `Money.plain(investedSavedToDate)` in `captionBold`.

Zero values display as `₹0` with no sign (this comes from `Money.signed`).

## Expected content (sample data)

| Card | Balance | Income | Expense | Invested | Saved | To date |
|------|---------|--------|---------|----------|-------|---------|
| Salary (Employment) | ₹53,200 | +₹1,20,000 | −₹55,800 | −₹20,000 | −₹6,000 | ₹4,10,000 |
| Side hustle (Freelance) | ₹22,400 | +₹35,000 | −₹8,600 | −₹10,000 | ₹0 | ₹60,000 |
| Aqua 105 (Rental) | ₹31,000 | +₹45,000 | −₹12,000 | ₹0 | −₹10,000 | ₹1,80,000 |
| VR (Rental) | ₹25,800 | +₹28,000 | −₹6,200 | ₹0 | ₹0 | ₹0 |

## Do not

Make the cards clickable or compute any value in the widget.

## Verify

- [x] Four cards in one row on a wide window (≥ about 1100px content width), two rows of two on a medium window, one column on a narrow one.
- [x] Each card shows exactly the numbers in the table; income values are green.
- [x] Cards have equal widths and consistent spacing (16px). `flutter analyze` is clean.
