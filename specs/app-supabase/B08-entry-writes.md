# B08: Add, edit and delete entries

**Goal:** the New entry panel saves for real, edit mode updates an entry, and the delete dialog removes it. The list refreshes after each change.

**Prerequisites:** B07 done.

## Files

| File | Change |
|------|--------|
| `lib/core/models/entry_input.dart` | new: `EntryInput` |
| `lib/core/utils/entry_validation.dart` | new: `validateEntry`, `parseAmount` |
| `lib/core/data/finance_repository.dart` | add `addEntry`, `updateEntry`, `deleteEntry` |
| `lib/core/data/mock_finance_repository.dart` | the three methods do nothing |
| `lib/core/data/supabase/supabase_finance_repository.dart` | implement them |
| `lib/features/transactions/cubit/transactions_state.dart`, `transactions_cubit.dart` | `saving`, write methods |
| `lib/features/transactions/widgets/entry_panel.dart` | validation, errors, saving state |
| `lib/features/transactions/widgets/delete_entry_dialog.dart` call site, `view/transactions_page.dart` | wiring |
| `test/core/entry_validation_test.dart` | new tests |

## Models and helpers

```dart
class EntryInput extends Equatable {
  const EntryInput({required this.date, required this.type, required this.sourceId,
      this.categoryId, required this.amount, this.description = ''});
  final DateTime date; final TxType type; final String sourceId;
  final String? categoryId;   // null for income
  final double amount;        // above zero
  final String description;
}
```

`entry_validation.dart`:
- `double? parseAmount(String text)`: remove commas, spaces and a leading `₹`; `double.tryParse`; null when empty or invalid; round to 2 decimals.
- `String? validateEntry({required String amountText, required String sourceId, required TxType type, required String? categoryId})` returns the first problem or null: `Choose a source.` (empty source), `Choose a category.` (type is not income and no category), `Enter an amount above zero.` (unparseable or not above zero).

## Repository

```dart
Future<void> addEntry(EntryInput input);
Future<void> updateEntry(String id, EntryInput input);
Future<void> deleteEntry(String id);
```
Supabase: a row map `{tx_date: sqlDate(date), type: type.name, source_id, category_id, amount, description}` (description trimmed). `addEntry` inserts it (`user_id` is filled by the database default). `updateEntry` updates by id and **selects the id back**; if no row comes back throw `StateError('Entry not found')` (a row you cannot see is treated as missing). `deleteEntry` deletes by id with the same check.

## Cubit

`TransactionsState` gets `bool saving` (initially false). `TransactionsCubit` adds:
```dart
Future<String?> addEntry(EntryInput input);          // returns an error message, or null on success
Future<String?> updateEntry(String id, EntryInput input);
Future<String?> deleteEntry(String id);
```
Each sets `saving: true`, calls the repository, and on success calls `reloadList()` (page 1 for add, current page for update and delete) and sets `saving: false`; on failure sets `saving: false` and returns `friendlyError(e)`.

## Panel behaviour

- Both buttons (and Save changes, Cancel, Delete) are disabled while `saving`.
- On Save: run `validateEntry`; if it fails show the message under the buttons in 13px / 600 / `AppColors.danger` (live region) and stop; clear the message on any field change. Otherwise build the `EntryInput` (description trimmed) and call the cubit.
- On an error message returned by the cubit: `AppSnack.error`, keep every field as typed.
- On success: `AppSnack.info(AppConfig.note('Entry saved'))` and then
  - **Save entry:** reset to the defaults of B07 and clear amount and description;
  - **Save and add another:** keep type, source, category and date, clear amount and description, and move focus to the amount field (a `FocusNode`).
- Edit mode: **Save changes** validates the same way, calls `updateEntry(editingId)`, shows `AppConfig.note('Changes saved')` and leaves edit mode (select null, reset). **Cancel** unchanged.
- Delete: the "Delete entry" button opens the existing delete dialog with `balanceBefore` from `sourceBalance(entry.sourceId)` (loading it just before opening; on failure `AppSnack.error` and no dialog). When the dialog returns true call `deleteEntry`, then `AppSnack.info(AppConfig.note('Entry deleted'))` and leave edit mode.
- Entry rows and the panel use the **active** sources and categories for choices; an entry that uses an archived source or category still edits fine (add the archived one to the dropdown list while editing that entry).

## Tests (`entry_validation_test.dart`)

`parseAmount`: `"32000"`, `"32,000.50"`, `"₹ 1,200"`, `" 45 "` parse; `""`, `"abc"`, `"-5"` do not parse or fail validation. `validateEntry` returns each of the three messages in the right priority and null for a valid expense and a valid income (no category).

## Do not

Add undo, bulk delete or a trash. Change the dialog's look.

## Verify (Supabase mode)

- [x] Add an expense: type Expense, Source Salary, Category Groceries, Amount 500, today's date, description "Test coffee", Save entry. The SnackBar says "Entry saved", the form resets, and the list (month = current) shows the new row at the top; footer total goes from 27 to 28.
- [x] Open the Dashboard: Salary's balance dropped by ₹500 and Expense by ₹500; the Monthly report's Groceries and the total expense moved by ₹500. (Check the database too: **Table Editor, transactions** has the row with your `user_id`.)
- [x] "Save and add another" keeps the type and source, clears the amount and puts the cursor in Amount.
- [x] Empty amount, then Save: "Enter an amount above zero." shows and nothing is saved. Income with no category saves fine.
- [x] Edit your test entry: change the amount to 800, Save changes; the row shows ₹800, the panel returns to "New entry".
- [x] Delete it: the dialog shows `Salary balance ₹…` before and after (before minus/plus 800 as appropriate); confirming removes the row and the totals return to the original (27 entries, Salary ₹53,200).
- [x] Try saving with the network off: a red SnackBar "Could not reach the server..." and the form keeps its values.
- [x] Sample mode: saving shows "Entry saved (sample data, nothing is stored yet)" and nothing changes in the list.
- [x] `flutter analyze` and `flutter test` pass.
