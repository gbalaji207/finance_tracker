# Templates 05: New template in a side drawer

**Goal:** the Templates page no longer shows the New template form beside the list. A **New template** button in the page header opens the form in a side drawer, like the Transactions and Settings pages. The list uses the full width.

**Prerequisites:** Templates 01 to 04, B09, the shared `SideDrawer` (Transactions redesign) and `06-no-default-selection` (transactions).

## Files

| File | Change |
|------|--------|
| `lib/features/templates/widgets/new_template_card.dart` | becomes `template_form.dart`, class `TemplateForm` |
| `lib/features/templates/view/templates_page.dart` | button, drawer, list at full width (no `TwoPane`) |
| `lib/features/templates/widgets/templates_list_card.dart` | wider columns, single-line cells |

## Behaviour

- `PageHeader` gets one action: `AppButton('New template')` (primary). It opens `showSideDrawer` with `SideDrawer(child: TemplateForm(...))`. The page reads `TemplatesCubit.state` when the button is pressed and passes `activeSources`, `activeCategories`, `nextSortOrder` and `cubit.addTemplate`.
- `TemplateForm` is the old form without the `AppCard`, in one column: title `New template` (with `SideDrawer.titleGap` on the right), Template name, `TypeSelector` (the same five type buttons as the entry form), Source (`Select`), Category (`Select`, hidden for income), Default amount (optional), Description, the quick-add checkbox, then **Save template** and **Cancel**.
- `onClose` closes the drawer: after a successful save (after the `Template saved` message) and on Cancel. A failed save keeps the drawer open with the values and shows the error SnackBar.
- Validation and the empty Source and Category follow `06-no-default-selection`.
- The templates table uses the full width: columns Name (flex), Type 112, Source 140, Category 150, Default amount 130, Actions 120, `minWidth: 760`; Name, Source, Category and Default amount are one line with an ellipsis. The `Edit` link is still "not wired".
- `CopyLastMonthCard` is unchanged.

## Do not

Wire the template Edit link, change the Copy last month card, or change what a template contains.

## Verify

- [ ] Templates shows the list at full width with a **New template** button at the top right; there is no form beside the list.
- [ ] The button opens a drawer from the right with Source and Category on `Select`; Esc, the X, the backdrop and Cancel close it without saving.
- [ ] Save with only a name: `Select a source.`; then `Select a category.`; a complete template saves, the drawer closes and the template appears in the list (and in Dashboard quick add when ticked).
- [ ] `flutter analyze` and `flutter test` pass.
