# Templates 03: New template form

**Goal:** the 340px "New template" card on the right of the templates list.

**Prerequisites:** Templates 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/templates/widgets/new_template_card.dart` | `NewTemplateCard` |
| `lib/features/templates/view/templates_page.dart` | change: replace the `secondary` placeholder |

## NewTemplateCard

`NewTemplateCard({required List<Source> sources, required List<Category> categories, required VoidCallback onSave})`, a stateful widget keeping local state for the dropdown selections and two text controllers (no Cubit needed).

An `AppCard` (padding 20) with `Column(crossAxisAlignment: stretch, spacing: 14)`:
1. Title `New template` in `sectionTitle`.
2. `AppTextField` "Template name", hint `e.g. Internet bill`.
3. `Row` (12px gap) of two `Expanded`: `AppDropdown` "Type" (the four `TxType` labels, default **Expense**) and `AppDropdown` "Source" (all sources, default **VR**).
4. `Row` (12px gap) of two `Expanded`: `AppDropdown` "Category" (categories whose `kind` matches the selected type, default **Utilities**; hidden/replaced by an empty `SizedBox` when type is Income so the row keeps its layout) and `AppTextField` "Default amount (optional)", hint `Ask each time`, decimal keyboard.
5. `AppTextField` "Description", hint `Pre-filled description`.
6. `AppButton('Save template', primary, large, expand)` calling `onSave`.

Changing the type resets the category to the first matching category (or none for Income). In the page, `onSave` shows the SnackBar `Not wired yet (sample data)`.

## Do not

Validate, persist, or add the new template to the list.

## Verify

- [x] The card shows the fields in the order above with defaults Expense, VR, Utilities.
- [x] Changing Type to Investment changes the Category options to Mutual funds only; Income hides the category dropdown.
- [x] "Save template" shows the SnackBar. `flutter analyze` is clean.
