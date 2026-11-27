# Settings 03: Categories

**Goal:** the Categories list card and the New category form card beside it.

**Prerequisites:** Settings 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/settings/widgets/categories_card.dart` | `CategoriesCard` |
| `lib/features/settings/widgets/new_category_card.dart` | `NewCategoryCard` |
| `lib/features/settings/view/settings_page.dart` | change: replace the "Categories list" and "New category form" placeholders |

## CategoriesCard

`CategoriesCard({required List<CategoryUsage> categories, required ValueChanged<Category> onEdit, required ValueChanged<Category> onArchive})`

An `AppCard` (padding 20) with `Column(crossAxisAlignment: start)`:
1. `Categories` in `sectionTitle`.
2. 4px below: `Used for expense, investment and savings entries. Income entries use sources instead.` in `subtitle`; 8px of space under it.
3. `AppTable(minWidth: 480)`:

| Column | Width / flex | Align |
|--------|--------------|-------|
| Name | flex 1.2 | left |
| Kind | 104 | left |
| Entries | 80 | right |
| Actions | 130 | right |

Cells: name `bodyStrong`; `TypeBadge(category.kind)`; `entryCount` as plain text; actions `Row(mainAxisSize: min, spacing: 16)` of `AppTextLink('Edit')` and `AppTextLink('Archive')`.

In the page both callbacks show the SnackBar `Not wired yet (sample data)`.

## NewCategoryCard

`NewCategoryCard({required VoidCallback onSave})`, stateful.

An `AppCard` (padding 20) with `Column(crossAxisAlignment: stretch, spacing: 14)`:
1. `New category` in `sectionTitle`.
2. `AppTextField` `Name`, hint `e.g. Insurance`.
3. `AppDropdown<TxType>` `Kind`: Expense, Investment, Savings (no Income); default **Expense**.
4. `AppButton('Save category', primary, large, expand)` calling `onSave` (SnackBar `Not wired yet (sample data)` in the page).

## Expected content (sample data)

| Name | Kind | Entries |
|------|------|--------:|
| Housing | Expense | 12 |
| Groceries | Expense | 28 |
| Utilities | Expense | 14 |
| Property upkeep | Expense | 6 |
| Other | Expense | 9 |
| Mutual funds | Investment | 11 |
| Fixed deposit | Savings | 5 |

## Do not

Persist anything or let the kind dropdown offer Income.

## Verify

- [ ] Seven rows as above with colored kind badges; Edit and Archive show the SnackBar.
- [ ] The form has Name and Kind (three options) and a Save category button.
- [ ] Only the Account placeholder remains on the page. `flutter analyze` is clean.
