# 04: Display components

**Goal:** cards, badges, amounts, KPI tiles, key-value rows, status pill, category bar, table and two layout helpers; extend the component gallery to show them.

**Prerequisites:** specs 01 to 03 done.

## Files to create

| File | Class |
|------|-------|
| `lib/core/widgets/app_card.dart` | `AppCard` |
| `lib/core/widgets/section_header.dart` | `SectionHeader` |
| `lib/core/widgets/type_badge.dart` | `TypeBadge` |
| `lib/core/widgets/amount_text.dart` | `AmountText` |
| `lib/core/widgets/kpi_tile.dart` | `KpiTile` |
| `lib/core/widgets/key_value_row.dart` | `KeyValueRow` |
| `lib/core/widgets/status_pill.dart` | `StatusPill`, `StatusTone` |
| `lib/core/widgets/category_bar_row.dart` | `CategoryBarRow` |
| `lib/core/widgets/app_table.dart` | `AppTable`, `AppTableColumn`, `AppTableRow`, `AppTableText` |
| `lib/core/widgets/responsive_wrap.dart` | `ResponsiveWrap` |
| `lib/core/widgets/two_pane.dart` | `TwoPane` |
| `lib/dev/component_gallery.dart` | change: add a "Display" part |

## Specs

**AppCard** `({required Widget child, EdgeInsets? padding, Color? borderColor, double? width})`: background `surface`, 1px border (`borderColor ?? cardBorder`), radius 12, `child` inside the padding. `padding` defaults to `AppSpacing.cardPadding` (20), or `cardPaddingCompact` (16) when the screen is narrower than `mobileBreakpoint`.

**SectionHeader** `({required String title, String? actionLabel, VoidCallback? onAction})`: `Row` space-between, vertically centered; title `sectionTitle`; if `actionLabel` is set show an `AppTextLink`. Adds 8px below itself.

**TypeBadge** `(TxType type)`: padding 4 vertical / 8 horizontal, radius 6, background `type.badgeBg`, text `type.label` in `badge` style colored `type.badgeFg`. Size to content.

**AmountText** `({required double amount, required TxType type, TextAlign textAlign = TextAlign.right})`: text from `Money.signed`, style `bodyStrong`, color `AppColors.income` for income, `textPrimary` otherwise.

**KpiTile** `({required String label, required String value})`: a card (radius 12, 1px `cardBorder`, background `surface`) with padding 16 vertical / 20 horizontal; label `caption`; value `kpiValue` with 4px above.

**KeyValueRow** `({required String label, required String value, Color? valueColor})`: `Row` space-between; label `rowLabel`; value `rowValue` colored `valueColor ?? textPrimary`.

**StatusPill** `({required String text, StatusTone tone = StatusTone.success})`: padding 6 / 12, fully rounded (radius 999), text 13px 600. Success: bg `incomeBg`, text `income`. Warning: bg `expenseBg`, text `expenseFg`.

**CategoryBarRow** `({required String label, required String amountText, required double fraction})`: `Row` centered, 16px gaps: label in a 150px box (`body`); `Expanded` track (height 14, radius 7, `track` color) containing a `FractionallySizedBox(widthFactor: fraction)` fill (height 14, radius 7, `primary`); amount in a 90px box, right-aligned, `bodyStrong`.

**ResponsiveWrap** `({required List<Widget> children, required double minItemWidth, double spacing = 16, int? maxColumns})`: `LayoutBuilder`; `columns = ((w + spacing) / (minItemWidth + spacing)).floor().clamp(1, min(children.length, maxColumns ?? children.length))`; item width `(w - spacing * (columns - 1)) / columns`; render a `Wrap(spacing, runSpacing: spacing)` of `SizedBox(width: itemWidth, child: item)`.

**TwoPane** `({required Widget primary, required Widget secondary, double primaryMin = 520, double secondaryMin = 280, int primaryFlex = 2, int secondaryFlex = 1, double? secondaryWidth, double gap = 16})`: `LayoutBuilder`.
- With `secondaryWidth` set: wide when `w >= primaryMin + gap + secondaryWidth`, then `Row(crossAxisAlignment: start)` of `Expanded(primary)`, gap, `SizedBox(width: secondaryWidth, secondary)`.
- Otherwise wide when `w >= primaryMin + gap + secondaryMin`, then `Row` with `Expanded(flex: primaryFlex)` and `Expanded(flex: secondaryFlex)`.
- When not wide: `Column(spacing: gap)` with both stretched to full width.

**AppTable**
```dart
class AppTableColumn { const AppTableColumn(this.title, {this.flex = 1, this.width, this.align = TextAlign.left}); }
class AppTableRow { const AppTableRow(this.cells, {this.highlight = false}); final List<Widget> cells; }
AppTable({required List<AppTableColumn> columns, required List<AppTableRow> rows, double? minWidth})
AppTableText(String text, {bool bold = false, Color? color, bool secondary = false})   // body 14 text; secondary uses bodySecondary
```
- Cells are laid out in a `Row` with 12px gaps; a column with `width` becomes a `SizedBox(width)`, otherwise `Expanded`. `AppTableColumn.flex` is a `double` (some pages use 1.2 or 1.3), so pass `flex: (flex * 10).round()` to `Expanded`. Each cell is wrapped in `Align` (right-aligned for `TextAlign.right`, else left, vertically centered).
- Header row: titles in `label` style, padding top 4 / bottom 12 / horizontal 4, 1px bottom border `divider`.
- Body rows: padding 12 vertical / 4 horizontal, 1px bottom border `divider`, minimum height 44.
- `highlight` row (totals): background `pageBg`, radius 8, no border.
- If `minWidth` is set, wrap in a horizontal `SingleChildScrollView` with the content width `max(minWidth, available width)`.
- `AppTableText` must not truncate: allow wrapping, `softWrap: true`.
- **Stacked mode (narrow):** `AppTableColumn` has `mobile: AppTableMobile` (`normal` default, `primary`, `trailing`, `action`, `hidden`) and `AppTable` has `stackBelow` (default `AppSpacing.mobileBreakpoint`, 600). When the available width (`LayoutBuilder`) is below `stackBelow`, drop the header and horizontal scroll and render each row as a block with the same row decoration (`highlight`, `background`, bottom border):
  - Main line: the first `primary` column (column 0 if none), expanded, plus any `trailing` cells on the right.
  - One `title` (caption, 96px wide) + value line for each `normal` column that has a title; `hidden` columns and untitled `normal` columns are skipped.
  - A `Wrap` of the `action` cells at the bottom, without labels.
  - `AppTableText` with `maxLines` wraps instead of truncating in this mode.

## Gallery additions (`component_gallery.dart`)

Add a "Display" heading after the inputs, with:
1. An `AppCard` containing a `SectionHeader('Recent entries', actionLabel: 'View all')`.
2. Four `TypeBadge`s in a `Wrap`, then `AmountText` for income 45000, expense 32000, investment 20000, savings 0.
3. Five `KpiTile`s inside `ResponsiveWrap(minItemWidth: 170)`.
4. Two `KeyValueRow`s inside an `AppCard`, one with a green value.
5. A success and a warning `StatusPill`.
6. Three `CategoryBarRow`s with fractions 1.0, 0.47, 0.28.
7. A `TwoPane` demo with two `AppCard`s of different heights.
8. An `AppTable` with columns Date (width 64), Description (flex 1), Type (width 104), Amount (width 110, right) and 3 sample rows plus one highlighted "Total" row.

## Do not

Read any repository or Cubit. These are pure widgets.

## Verify

- [x] Cards are white with a thin warm-grey border and rounded corners.
- [x] Badges show four distinct tints; `AmountText` shows `+₹45,000` in green, `−₹32,000` in dark text, `₹0` unsigned.
- [x] The five KPI tiles wrap to fewer columns as you narrow the window and never overflow.
- [x] Bars are teal on a light track; widths follow the fractions.
- [x] `TwoPane` shows side by side when wide and stacks when narrow.
- [x] The table has a thin line under each row, right-aligned amounts, and a shaded totals row. `flutter analyze` is clean.
