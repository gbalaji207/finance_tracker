# Transactions 06: No default Source or Category

**Goal:** the entry form no longer preselects the first source and the first category. A preselected first item led to entries on the wrong source or category, so the user must choose them, and saving is blocked until they have.

**Prerequisites:** the entry drawer (Transactions redesign) and B08 (validation).

## Files

| File | Change |
|------|--------|
| `lib/features/transactions/cubit/add_entry_cubit.dart` | no defaults |
| `lib/features/transactions/widgets/entry_panel.dart` | the dropdowns show `Select` |
| `lib/core/utils/entry_validation.dart` | messages |
| `test/core/entry_validation_test.dart`, `test/features/transactions/add_entry_cubit_test.dart` | tests |

## Behaviour

- A new form (and the form after `reset()`) has type Expense, today's date, **no source** (`sourceId` is `''`) and **no category** (`categoryId` is null).
- The Source and Category dropdowns show the hint `Select` while nothing is chosen. The dropdown value is null when `sourceId` is empty.
- Changing the Type clears the Category (categories belong to one kind), and the user chooses again. Income has no Category field.
- A template fills Type, Source and the template's Category; a template without a category leaves it empty. Nothing is guessed.
- Editing an entry fills the form from that entry as before.
- "Save and add another" keeps Type, Source, Category and Date, as before.
- `validateEntry` runs on Save and Save changes and returns, in this order: `Select a source.`, `Select a category.` (type is not income and no category), `Enter an amount above zero.`. The message shows under the buttons (red, 13px) and nothing is saved.

## Do not

Change the template form, the Settings forms, or the Transactions filters.

## Verify

- [ ] Open New entry: Source and Category read `Select`; type Expense is selected.
- [ ] Choose Investment: Category resets to `Select`; choose Income: the Category field is hidden.
- [ ] Save with nothing chosen: `Select a source.`; after choosing a source: `Select a category.`; after a category: `Enter an amount above zero.`. Nothing is saved in any of these cases.
- [ ] A complete entry saves; "Save and add another" keeps the choices.
- [ ] Using a template (from the Dashboard chips or the Templates page) fills its source and category; editing an existing entry shows its values.
- [ ] `flutter analyze` and `flutter test` pass.

## Also applies to the New template form

`lib/features/templates/widgets/template_form.dart` (formerly `new_template_card.dart`, now shown in a drawer: see `specs/templates/05-new-template-drawer.md`) follows the same rule:

- A new form (and the form after a save) has no source and no category chosen; both dropdowns show `Select`.
- Changing the Type clears the Category (income has no Category field).
- Saving checks, in this order: `Enter a template name.`, `Select a source.`, `Select a category.` (non-income), then the default amount rule (`Default amount must be above zero.` when it is filled but invalid).

Verify: open Templates, the New template form shows `Select` for Source and Category; Save with a name only gives `Select a source.`, then `Select a category.` after a source is chosen; a complete template saves and the form returns to `Select`.
