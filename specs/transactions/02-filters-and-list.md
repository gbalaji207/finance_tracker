# Transactions 02: Filters and list

**Goal:** the left card with the filter row, the ten-entry table and the footer.

**Prerequisites:** Transactions 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/transactions/widgets/transactions_list_card.dart` | `TransactionsListCard` |
| `lib/features/transactions/view/transactions_page.dart` | change: replace the `primary` placeholder |

## TransactionsListCard

```dart
TransactionsListCard({
  required TransactionPage page,
  required List<Source> sources,
  required DateTime month,
  required String? sourceFilter,
  required TxType? typeFilter,
  required String Function(String sourceId) sourceName,
  required String Function(String? categoryId) categoryName,
  required ValueChanged<DateTime> onMonthChanged,
  required ValueChanged<String?> onSourceChanged,
  required ValueChanged<TxType?> onTypeChanged,
  required ValueChanged<String> onQueryChanged,
})
```

An `AppCard` (padding 20) with a `Column(crossAxisAlignment: stretch)`:

**1. Filter row**, 16px below it. Use a `LayoutBuilder`: when the width is at least 636 show a `Row` (12px gaps) of `Expanded` children with flex 1 / 1 / 1 / 2; otherwise a `Column(spacing: 12)` with each field full width.
   - `AppDropdown<String>` "Month": single item `AppDates.monthYear(month)`; selecting calls `onMonthChanged(month)`.
   - `AppDropdown<String>` "Source": items `All sources` (value `'all'`) plus each source (value = source id). The current value is `sourceFilter ?? 'all'`; map `'all'` back to `null` before calling `onSourceChanged`. (A sentinel is used because a dropdown item with a null value does not display as selected.)
   - `AppDropdown<String>` "Type": items `All types` (value `'all'`) plus the four `TxType` labels (value = `type.name`). Current value `typeFilter?.name ?? 'all'`; map back to `TxType?` before calling `onTypeChanged`.
   - `AppTextField` "Search description", hint `e.g. EMI`, calls `onQueryChanged`.

**2. Table**: `AppTable` with columns:

| Column | Width | Align |
|--------|-------|-------|
| Date | 56 | left |
| Description | flex 1 | left |
| Source | 104 | left |
| Category | 112 | left |
| Type | 100 | left |
| Amount | 100 | right |

Cells: date `AppDates.dayMonth` (secondary), description, source name, category name (secondary; `—` for none), `TypeBadge`, `AmountText`.

**3. Footer**, 16px above: `Row` space-between in `subtitle` style: `Showing ${items.length} of ${total} entries` and `Page ${page} of ${pageCount}`.

Because filters are visual only, changing them does not change the rows.

## Expected content (sample data)

Ten rows, in this order: Home EMI, Groceries, SIP: index fund, Rent received (Aqua 105), Rent received (VR), Electricity bill, Client payout, Recurring deposit, Plumbing repair, Salary credited. Footer: `Showing 10 of 38 entries` and `Page 1 of 4`. Income rows show `—` as category.

## Do not

Implement real filtering, search or pagination. Do not add row actions.

## Verify

- [ ] Filter row shows Month, Source, Type and Search; dropdowns open with the listed options.
- [ ] Table shows the 10 rows with badges and signed amounts (income green, others dark).
- [ ] Footer reads "Showing 10 of 38 entries" and "Page 1 of 4".
- [ ] The "New entry panel" placeholder is still present on the right. `flutter analyze` is clean.
