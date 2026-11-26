# Transactions 03: Add-entry panel

**Goal:** the always-open "New entry" panel on the right with a small amount of real behavior: type changes the category list, templates fill the form, and Save shows a message. This completes the Transactions page.

**Prerequisites:** Transactions 01 done (02 is independent).

## Files

| File | Contents |
|------|----------|
| `lib/features/transactions/cubit/add_entry_state.dart` | `AddEntryState` |
| `lib/features/transactions/cubit/add_entry_cubit.dart` | `AddEntryCubit` |
| `lib/features/transactions/widgets/add_entry_panel.dart` | `AddEntryPanel` |
| `lib/features/transactions/view/transactions_page.dart` | change: replace the `secondary` placeholder |

## AddEntryCubit

State fields: `type` (`TxType`, default `expense`), `sourceId` (default `salary`), `categoryId` (`String?`, default `groceries`), `date` (default `mockToday`). The cubit receives the full list of `Category`s and `Source`s in its constructor.

Methods:
- `selectType(TxType)`: sets `type`; `categoryId` becomes `null` for income, otherwise the first category whose `kind == type`.
- `selectSource(String)`, `selectCategory(String?)`, `selectDate(DateTime)`.
- `applyTemplate(EntryTemplate)`: sets `type`, `sourceId`, `categoryId` (the template's, or first matching, or null for income) and returns the template so the widget can fill the amount and description fields.
- `reset()`: back to defaults.

Create it in the page with `BlocProvider(create: (_) => AddEntryCubit(categories: ..., sources: ...))` using the data already loaded by `TransactionsCubit`.

## AddEntryPanel

`AddEntryPanel({required List<EntryTemplate> templates, required String Function(String sourceId) sourceName, required List<Source> sources, required List<Category> categories})`, a stateful widget that owns two `TextEditingController`s (amount, description) and reads `AddEntryCubit` with `BlocBuilder`.

An `AppCard(padding 20, borderColor: AppColors.primary)` with `Column(crossAxisAlignment: stretch, spacing: 14)`:

1. Title `New entry` in `sectionTitle`.
2. `TypeSelector(label: 'Type')`.
3. `AppDropdown` "Fill from template (optional)", hint `Choose a template…`, items labelled `"${name} · ${sourceName}"`. Choosing one calls `applyTemplate`, then sets the amount controller text to the template amount (empty if null; integer, no decimals) and the description controller to the template description.
4. `AppDropdown` "Source" (value `sourceId`).
5. **Category** (hidden completely when `type == income`): `AppDropdown` "Category" listing categories whose `kind == type`, with helper text `Hidden for income entries.`
6. A `Row` (12px gap) of two `Expanded`: `AppTextField` "Amount (₹)" (hint `0`, decimal keyboard) and `AppDateField` "Date".
7. `AppTextField` "Description", hint `Where it went, e.g. SBI FD`.
8. `Column(spacing: 8)`: `AppButton('Save entry', primary, large, expand)` and `AppButton('Save and add another', secondary, large, expand)`.
9. A line `Keyboard: N new entry · Enter save · Esc close` in `caption` (display only, no shortcuts).

Both save buttons: show SnackBar `Saved (sample data, nothing is stored yet)`, then `reset()` the cubit and clear both text controllers.

In the page, `secondary: AddEntryPanel(...)` (the `TwoPane` already gives it width 340).

## Do not

Validate fields, store anything, or add keyboard shortcuts.

## Verify

- [ ] Panel has a teal border and the fields in the order above.
- [ ] Picking Income hides the Category field; picking Expense/Investment/Savings shows it with only matching categories (Investment shows just Mutual funds; Savings just Fixed deposit).
- [ ] Choosing the template "Home EMI · Salary" sets Type Expense, Source Salary, Category Housing, Amount 32000.
- [ ] Both save buttons show the SnackBar and clear the form.
- [ ] The full Transactions page matches the wireframe; no placeholders remain. `flutter analyze` is clean.
