# Transactions 05: Delete entry dialog

**Goal:** the confirmation dialog opened by "Delete entry", showing the entry and its effect on the source balance.

**Prerequisites:** Transactions 04 and specs 07 and 08 done.

## Files

| File | Contents |
|------|----------|
| `lib/features/transactions/widgets/delete_entry_dialog.dart` | `DeleteEntryDialog` and `showDeleteEntryDialog` |
| `lib/features/transactions/widgets/entry_panel.dart` | change: wire the Delete entry button |
| `lib/features/transactions/view/transactions_page.dart` | change: pass what the panel needs |

## DeleteEntryDialog

```dart
Future<bool?> showDeleteEntryDialog(BuildContext context, {
  required Transaction entry,
  required String sourceName,
  required String categoryName,   // "—" when there is none
  required double balanceBefore,
})
```
Opens through `showAppDialog`; the dialog widget returns an `AppDialog` with:

- **Title:** `Delete this entry?`
- **Content** (`Column(spacing: 16)`):
  1. A filled `InfoBox` containing a `Row` (space-between, centered): left `Column(start)` with the description in `bodyStrong` and below it (2px) `"${AppDates.dayMonthYear(date)} · $sourceName · $categoryName"` in `caption`; right `AmountText(entry.amount, entry.type)`.
  2. A paragraph `Deleting this entry changes the $sourceName balance. This cannot be undone.` in `bodySecondary`.
  3. A bordered `InfoBox` containing a `Row` (space-between, centered): `"$sourceName balance"` in `rowLabel` and `"${Money.plain(balanceBefore)} → ${Money.plain(BalanceMath.afterDeleting(entry, balanceBefore))}"` in `rowValue`.
- **Actions:** `AppButton('Cancel', secondary, large)` pops `false`; `AppButton('Delete entry', danger, large)` pops `true`.

## Wiring

In the panel's edit mode, the "Delete entry" button (replacing the placeholder SnackBar):
1. Gets `balanceBefore` from `FinanceRepository.sourceBalance(editing.sourceId)` (read it through `context.read<FinanceRepository>()` in the page and pass a callback down, or pass an `onDelete` callback into the panel; keep the panel itself free of repository access).
2. Calls `showDeleteEntryDialog` with the entry, the source name, the category name and the balance.
3. If the result is `true`: SnackBar `Entry deleted (sample data, nothing is stored yet)` and leave edit mode (`TransactionsCubit.select(null)`, `AddEntryCubit.reset()`). The list does not change.

## Expected content (sample data)

For "Home EMI" (25 Nov 2026, Salary, Housing, −₹32,000): `Salary balance` `₹53,200 → ₹85,200`.

## Do not

Remove the entry from the list or persist anything.

## Verify

- [ ] Edit "Home EMI", click "Delete entry": a centered dialog shows "Delete this entry?", the entry summary with `−₹32,000`, the paragraph, and the bordered line `Salary balance ₹53,200 → ₹85,200`.
- [ ] Cancel closes it and keeps edit mode; Delete entry closes it, shows the SnackBar and returns the panel to "New entry".
- [ ] For an income entry such as "Rent received" (Aqua 105, +₹45,000) the line reads `Aqua 105 balance ₹31,000 → −₹14,000` (the balance goes down, and a negative result shows a minus sign).
- [ ] The dialog scrolls instead of overflowing on a short window; Esc closes it. `flutter analyze` is clean.
