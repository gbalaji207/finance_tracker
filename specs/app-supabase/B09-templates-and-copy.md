# B09: Templates and copy last month

**Goal:** save new templates, "Use" opens the entry form pre-filled, quick add works the same way, and "Copy last month" really creates the ticked entries.

**Prerequisites:** B08 done.

## Files

| File | Change |
|------|--------|
| `lib/core/models/template_input.dart` | new: `TemplateInput` |
| `lib/core/data/finance_repository.dart` | add `addTemplate`, `addEntries` |
| `lib/core/data/mock_finance_repository.dart` | both do nothing |
| `lib/core/data/supabase/supabase_finance_repository.dart` | implement both |
| `lib/features/templates/cubit/*`, `view/templates_page.dart` | saving, copying, preselection |
| `lib/features/templates/widgets/new_template_card.dart` | real save, quick-add checkbox |
| `lib/features/templates/widgets/copy_last_month_card.dart`, `templates_list_card.dart` call sites | dynamic texts, Use links |
| `lib/app/router.dart`, `lib/features/transactions/view/transactions_page.dart`, `widgets/entry_panel.dart` | accept a template id |
| `lib/features/dashboard/view/dashboard_page.dart` | quick add Use |
| `test/features/templates/preselect_test.dart` | new test |

## Models and repository

```dart
class TemplateInput extends Equatable {
  const TemplateInput({required this.name, required this.type, required this.sourceId,
      this.categoryId, this.amount, this.description = '', this.quickAdd = false,
      required this.sortOrder});
  // fields as named; amount null = ask each time; sortOrder = (largest existing sort order) + 1
}
Future<void> addTemplate(TemplateInput input);
Future<void> addEntries(List<EntryInput> inputs);   // one request for the whole list
```
Supabase: `addTemplate` inserts `{name, type: type.name, source_id, category_id, amount, description, quick_add, sort_order}`; `addEntries` inserts the list of entry rows (same row shape as `addEntry`, one bulk insert, nothing inserted if it fails).

## New template form

`NewTemplateCard.onSave` becomes `ValueChanged<TemplateInput>`. Add a `LabeledCheckbox` "Show in Dashboard quick add" (unchecked) under the description. Validation messages appear in the red 13px style under the button: `Enter a template name.`, `Choose a source.`, `Choose a category.` (non-income), and `Default amount must be above zero.` when the amount is filled but invalid or not above zero (an empty amount is fine). Choices use `activeSources` and `activeCategories`. On success: `AppSnack.info(AppConfig.note('Template saved'))`, clear the form, reload the templates; on failure `AppSnack.error` and keep the form. Disable the button while saving. `sortOrder` is the cubit's `templates` maximum plus one (1 when none).

## "Use" fills the entry form

- Router: `/transactions` may carry `?template=<id>`. The route builder passes `state.uri.queryParameters['template']` to `TransactionsPage(templateId: ...)`.
- `TransactionsPage`: once its first load has finished, if `templateId` is set and a template with that id exists, call `AddEntryCubit.applyTemplate` and fill the panel's amount and description (the panel gets an `initialTemplate` parameter it applies once in its `initState` or a post-frame callback). Apply only once per page instance.
- Dashboard quick add `onUse` and Templates list `onUse` now go to `'${AppRoutes.transactions}?template=${t.id}'` instead of the plain path. "Manage" and "Copy entries from last month" are unchanged. (This also works in sample mode.)

## Copy from last month

- Texts become dynamic: the title `Copy from ${AppDates.monthYear(previousMonth)}`; the subtitle `Tick the entries to re-create in ${AppDates.monthName(thisMonth)}. You can edit amounts after copying.`; the button `Copy ${n} selected to ${AppDates.monthName(thisMonth)}` (use the existing month-name helper, or add `monthName` to `AppDates`: "November"). `previousMonth` is `appMonth()` minus one month.
- Preselection (replaces the hardcoded `o5` rule): an entry starts ticked when a template exists with the same name as the entry's description, the same source and the same type. Put this in a pure function `Set<String> preselectedIds(List<Transaction> entries, List<EntryTemplate> templates)` in `lib/features/templates/cubit/preselect.dart` and use it in `TemplatesCubit.load()`.
- Copy action: `TemplatesCubit.copySelected()` builds one `EntryInput` per ticked entry: same type, source, category, amount and description; date = the same day of the month in the current month, clamped to that month's last day (22 Oct becomes 22 Nov; 31 Oct becomes 30 Nov). It calls `addEntries` once, with `saving` set so the button is disabled meanwhile. On success show `AppSnack.info(AppConfig.note('Copied $n entries to ${monthName}'))` and `context.go(AppRoutes.transactions)` so the new entries are visible. On failure `AppSnack.error`, stay on the page, nothing is created.
- Empty case: when last month has no entries show `EmptyNote('No entries last month.')` in the card.

## Test (`preselect_test.dart`)

With the six sample templates and the six sample October entries, `preselectedIds` returns `{o1, o2, o3, o4, o6}` (not `o5`). A second case: an entry whose source differs from the template's source is not selected.

## Do not

Add editing or deleting of templates. Copy entries into a month other than the current one.

## Verify (Supabase mode, sample data)

- [x] Templates page, copy card: "Copy from October 2026", subtitle mentions November, 17 entries listed, and only the recurring ones ticked: Home EMI, SIP: index fund, Rent received (Aqua 105), Rent received (VR), Recurring deposit (Aqua 105): button `Copy 5 selected to November`.
- [x] Create a template: name "Gym", Expense, Source Salary, Category Other, amount 1500, tick quick add, Save: the list shows it as the seventh row; the Dashboard's Quick add now includes "Gym".
- [x] Click "Use" on "Gym" (Dashboard or Templates): Transactions opens with Type Expense, Source Salary, Category Other, Amount 1500 filled. Using "Internet bill" (no default amount) leaves Amount empty.
- [x] **This writes data:** untick everything except Home EMI and copy. You land on Transactions with a new Home EMI of ₹32,000 dated 5 Nov 2026 (the October one was 5 Oct), and the footer total is 28. Delete that test entry again (Edit, Delete entry) to restore the sample numbers.
- [x] Template name empty: "Enter a template name." and nothing is saved.
- [x] Sample mode: "Use" now fills the form too; copy shows the "(sample data...)" message. `flutter analyze` and `flutter test` pass.
