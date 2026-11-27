# Transactions 04: Edit entry

**Goal:** an Edit link on every list row, a selected-row highlight, and the right-hand panel switching to an "Edit entry" mode with Save changes, Cancel and Delete entry.

**Prerequisites:** Part 1 done (Transactions 01 to 03) and specs 07 and 08 done.

## Files to change

| File | Change |
|------|--------|
| `lib/features/transactions/cubit/transactions_state.dart` | add `selectedId` (`String?`, initial `null`) and a getter `Transaction? get selected` |
| `lib/features/transactions/cubit/transactions_cubit.dart` | add `select(String? id)` |
| `lib/features/transactions/cubit/add_entry_state.dart` | add `editingId` (`String?`, initial `null`) |
| `lib/features/transactions/cubit/add_entry_cubit.dart` | add `startEdit(Transaction t)`; `reset()` also clears `editingId` |
| `lib/features/transactions/widgets/transactions_list_card.dart` | add the Actions column and selection |
| `lib/features/transactions/widgets/add_entry_panel.dart` | rename the class to `EntryPanel` and the file to `entry_panel.dart`; add edit mode |
| `lib/features/transactions/view/transactions_page.dart` | wire everything |

## List changes (`TransactionsListCard`)

New parameters: `String? selectedId`, `ValueChanged<Transaction> onEdit`.

- Add a seventh column to the table: header blank, width **56**, right-aligned. (Columns are then Date 56, Description flex 1, Source 104, Category 112, Type 100, Amount 100, Actions 56.)
- Body cell: `AppTextLink('Edit')` calling `onEdit(entry)`. For the selected row show instead the text `Editing` in 13px / 600 / `primaryDark`, no underline, not clickable.
- The selected row uses `AppTableRow(background: AppColors.rowSelected)`.

## Cubit changes

- `TransactionsCubit.select(id)` sets `selectedId` (`null` clears it).
- `AddEntryCubit.startEdit(t)`: sets `type`, `sourceId`, `categoryId` (`null` for income), `date` and `editingId` from the entry.

## Panel (`EntryPanel`)

New parameter `Transaction? editing`. The page passes `state.selected` and gives the panel `key: ValueKey(editing?.id ?? 'new')` so its text controllers are initialised from `editing` (amount as a whole number such as `32000`, description as is).

- **No `editing` (add mode):** exactly as in Transactions 03.
- **Edit mode:**
  - Header: `Edit entry` in `sectionTitle`; 4px below it `"${description} · ${AppDates.dayMonthYear(date)}"` in `caption`.
  - No "Fill from template" dropdown and no keyboard hint line.
  - Fields in the same order, prefilled: Type, Source, Category (hidden for income), Amount and Date, Description. The type and category rules from spec 03 still apply.
  - Buttons: `AppButton('Save changes', primary, large, expand)` shows the SnackBar `Changes saved (sample data, nothing is stored yet)` then leaves edit mode; `AppButton('Cancel', secondary, large, expand)` leaves edit mode.
  - Below the buttons, a 1px `divider` line with 14px padding above its content, then `AppButton('Delete entry', dangerOutline, medium, expand)`. Until spec 05 exists it shows the SnackBar `Not wired yet (sample data)`.

"Leaving edit mode" means `TransactionsCubit.select(null)` and `AddEntryCubit.reset()`.

## Page wiring

`onEdit(t)` calls `TransactionsCubit.select(t.id)` and `AddEntryCubit.startEdit(t)`. Clicking Edit on a different row switches the selection and refills the panel.

## Do not

Persist changes or change the list contents. Do not build the delete dialog (spec 05).

## Verify

- [ ] Every row has an underlined "Edit" link in a new narrow column; the header cell for it is empty.
- [ ] Clicking Edit on "Home EMI" highlights that row in pale teal, shows "Editing" in its last cell, and turns the right panel into "Edit entry" with subtitle "Home EMI · 25 Nov 2026" and the fields prefilled (Expense, Salary, Housing, 32000, 25 Nov 2026, Home EMI).
- [ ] Clicking Edit on "Rent received" (Aqua 105) refills the panel as Income with no Category field.
- [ ] Cancel and Save changes return the panel to "New entry" and clear the highlight.
- [ ] "Delete entry" appears as a red-outline button under a divider. `flutter analyze` is clean.
