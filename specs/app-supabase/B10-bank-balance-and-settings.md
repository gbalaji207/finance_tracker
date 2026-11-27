# B10: Bank balance, sources and categories

**Goal:** the bank balance dialog saves for real; Settings can add sources and categories and archive or restore them. This completes the app's data features.

**Prerequisites:** B09 done.

## Files

| File | Change |
|------|--------|
| `lib/core/models/source_input.dart`, `category_input.dart` | new |
| `lib/core/data/finance_repository.dart` | add the write methods below |
| `lib/core/data/mock_finance_repository.dart` | in-memory implementations for these five |
| `lib/core/data/supabase/supabase_finance_repository.dart` | implement them |
| `lib/features/dashboard/cubit/dashboard_cubit.dart` | `updateBankBalance` saves |
| `lib/features/settings/cubit/settings_cubit.dart` | write methods, reload |
| `lib/features/settings/widgets/new_source_card.dart`, `new_category_card.dart`, `categories_card.dart`, `sources_card.dart` | real behaviour |
| `lib/features/settings/view/settings_page.dart` | wiring |

## Repository

```dart
Future<void> setBankBalance(double balance, DateTime asOf);
Future<void> addSource(SourceInput input);                 // name, kind, openingBalance, openingDate
Future<void> setSourceActive(String id, bool active);
Future<void> addCategory(CategoryInput input);             // name, kind (TxType, never income)
Future<void> setCategoryActive(String id, bool active);
```
Supabase:
- `setBankBalance`: upsert into `bank_balances` `{user_id: client.auth.currentUser!.id, as_of: sqlDate(asOf), balance}` with `onConflict: 'user_id,as_of'` (one balance per date; saving again for the same date replaces it).
- `addSource`: insert `{name (trimmed), kind, opening_balance, opening_date: sqlDate(...)}`.
- `setSourceActive` / `setCategoryActive`: update `is_active` by id and select the id back; throw `StateError('Not found')` when nothing comes back.
- `addCategory`: insert `{name (trimmed), kind: kind.name}`.

Mock: keep in-memory state inside `MockFinanceRepository`: a bank balance and date (initially 132400 on `mockToday`), and sets of archived source ids and category ids. `reconciliation()`, `sources()`, `allSources()`, `categories()`, `allCategories()` and `categoryUsage()` honour them, `addSource` / `addCategory` append to the in-memory lists (new id `new-N`), so sample mode keeps working end to end. Everything resets on reload.

## Dashboard bank balance

`DashboardCubit.updateBankBalance(balance, asOf)`: call `setBankBalance`, then re-fetch `reconciliation()` and emit it (replaces the in-memory-only update from Dashboard 06). On failure return the message so the dialog flow shows `AppSnack.error` and keeps the old value. Show `AppSnack.info(AppConfig.note('Bank balance saved'))` on success. The dialog's amount parsing stays as is.

## Settings

- `SettingsCubit`: `addSource(SourceInput)`, `addCategory(CategoryInput)`, `toggleSourceActive(id)` and `toggleCategoryActive(id)` call the repository and then reload sources and usage; each returns `Future<String?>` (error message or null). Replace the in-memory toggle from Settings 01.
- **New source form:** add an `AppDateField` "Opening date" (default today, helper `Entries before this date are not counted.`) between Opening balance and the button. Validation under the button in the red 13px style: `Enter a name.`, `Opening balance must be a number (use 0 if none).`. An empty opening balance means 0. On success: `AppSnack.info(AppConfig.note('Source saved'))` and clear the form.
- **New category form:** validation `Enter a name.`; success `AppConfig.note('Category saved')`.
- Both forms: disable the button while saving; errors (such as a duplicate name, `That name is already used.`) show as `AppSnack.error` and keep the form.
- **Categories table:** add a Status column (96 wide) with the same `Active` / `Archived` `AppBadge` as sources (the table's `minWidth` becomes 576), and make the action link `Archive` or `Restore` depending on `isActive`; it calls `toggleCategoryActive`.
- Sources table: the Archive / Restore link calls `toggleSourceActive`. "Edit" links stay "Not wired yet".
- Archiving only hides the item from new entries and forms (B04 lists); history and reports still show it.

## Do not

Allow deleting a source or category, or editing their names. Let the category kind be Income.

## Verify (Supabase mode)

- [x] Dashboard, Update bank balance: enter 132000 as on today, Save. The strip shows `₹1,32,000` and "Off by ₹400". Reload: it persists. Enter 132400 again to restore "Matches". (A second save on the same date replaces the first; check **Table Editor, bank_balances** has one row per date.)
- [x] Settings, add source: "Test source", Rental, opening balance 1000, opening date today. It appears in the table as Active, shows on the Dashboard as a card with ₹1,000, and appears in the entry form's Source list.
- [x] Archive "Test source": its badge turns grey, the link becomes "Restore", and it no longer appears in the entry form's Source list. Its Dashboard card stays while it still has a balance (₹1,000) and disappears once the balance is ₹0 and the month has no activity. Restore brings it back to the form.
- [x] Add category "Insurance" as Expense: it appears with 0 entries, then in the entry form's category list for Expense. Adding "Housing" again fails with "That name is already used."
- [x] Archive "Insurance": status Archived and it disappears from the entry form.
- [x] Clean up: archive the test source and category (names cannot be deleted from the app; delete the rows in **Table Editor** if you want them gone).
- [x] Sample mode: the same flows work in memory and reset on reload. `flutter analyze` and `flutter test` pass.

## After B10

The app is functionally complete for one user. Remaining decisions are deployment (where to host the Flutter web build) and creating the real, empty Supabase project: run Phase A files 01 to 03 there, create your user, and point `env/prod.json` at it.
