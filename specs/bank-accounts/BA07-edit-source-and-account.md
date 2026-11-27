# BA07: Edit a source and rename a bank account

**Goal:** the Edit links on Settings work. Editing a source can change its name, kind, bank account and opening balance (and opening date, if your new-source form has it). Editing a bank account renames it.

**Prerequisites:** BA06 done (works in both sample and Supabase mode). No database change is needed: the existing security rule already allows updates.

## Files

| File | Change |
|------|--------|
| `lib/core/data/finance_repository.dart` | `updateSource`, `renameBankAccount` |
| `lib/core/data/mock_finance_repository.dart` | in-memory versions |
| `lib/core/data/supabase/supabase_finance_repository.dart` | real versions |
| `lib/features/settings/cubit/settings_state.dart`, `settings_cubit.dart` | editing state and methods |
| `lib/features/settings/widgets/new_source_card.dart` | becomes `SourceFormCard` (add and edit) |
| `lib/features/settings/widgets/new_bank_account_card.dart` | becomes `BankAccountFormCard` (add and edit) |
| `lib/features/settings/widgets/sources_card.dart`, `bank_accounts_card.dart` | Edit links call back |
| `lib/features/settings/view/settings_page.dart` | wiring |
| `test/core/mock_finance_repository_test.dart` | tests |

## Repository

```dart
Future<void> updateSource(String id, SourceInput input);   // same fields as when creating
Future<void> renameBankAccount(String id, String name);
```
- **Mock:** replace the matching in-memory source (keep its id; set `bankAccountId` and `bankAccountName` from the chosen account). Only sources created in memory, **and** the seeded mock sources, can be edited, and balances on the Dashboard stay as the fixed mock figures except where the source was added in memory (the existing B10 rule). `renameBankAccount` updates the account name and the `bankAccountName` of its sources.
- **Supabase:** `update` on `sources` with `{name: input.name.trim(), kind, bank_account_id, opening_balance, opening_date}` (use the same column names and `sqlDate()` as `addSource`), `.eq('id', id).select('id')`; throw `StateError('Not found')` when no row comes back. `renameBankAccount`: update `name` on `bank_accounts` the same way. A duplicate name gives error code 23505, shown as `That name is already used.` by `friendlyError`.

## Editing behaviour (Settings)

`SettingsState` gets `String? editingSourceId` and `String? editingBankAccountId` (null = adding). `SettingsCubit`: `startEditSource(id)`, `startEditBankAccount(id)`, `cancelEdit()` (clears both), `updateSource(id, input)` and `renameBankAccount(id, name)`; the two update methods return `Future<String?>` (message or null), reload the lists on success and clear the editing id.

**Source form (right pane of the Sources row).** `SourceFormCard` gets `Source? editing`. When `editing` is set:
- Title `Edit source`; fields prefilled (name, kind, bank account, opening balance as a whole number, opening date).
- Primary button `Save changes`, plus a secondary `Cancel` button below it (calls `cancelEdit`).
- The Bank account dropdown lists the active accounts **plus the source's current account** (even if archived).
- Under the Bank account dropdown, a `caption` note shown only when the chosen account differs from the current one: `All of this source's past entries move to the new account, so both accounts' totals change.`
- Under the opening balance, a `caption` note: `Changing this changes the source's balance for every month.`
- Success: `AppSnack.info(AppConfig.note('Source updated'))`; the form returns to "New source" with cleared fields. Failure: `AppSnack.error`.
- When `editing` changes (another Edit link clicked), the form refills; use a `ValueKey` on the id.

**Bank account form.** `BankAccountFormCard` gets `BankAccount? editing`: title `Rename bank account`, the Name field prefilled, buttons `Save changes` and `Cancel`; same success and failure handling (`Bank account renamed`).

**Rows.** In `SourcesCard`, `Edit` calls `onEdit(source)`; the row being edited gets the `surface2` background. In `BankAccountsCard`, `Edit` calls `onEdit(account)`; the same highlight. Editing a source cancels any bank account edit and the other way round. Remove the "Not wired yet" SnackBar from both. (Categories' Edit link stays "not wired".)

## Do not

Allow changing a source's opening balance to a value that breaks the database rules; use the same validation as creating. Add editing for categories, or moving money between accounts.

## Verify (run in Supabase mode, then repeat the first three in sample mode)

- [ ] Clicking Edit on a source highlights its row and the right pane shows `Edit source` with the current values and bank account.
- [ ] Rename the source and save: the table, the Dashboard source card, Transactions' source filter and the reports show the new name. A name already used by another source gives `That name is already used.`
- [ ] Change a source's bank account to another one and save: the Dashboard's per-account rows change (the first account's `Sources` total drops by the source's balance, the second's rises by it) and the grand totals stay the same. The caption note appeared before saving.
- [ ] Change the opening balance by 500 and save: the source's balance and the totals change by 500 (in Supabase mode this is the database's answer; in sample mode only for sources added in memory).
- [ ] Edit an archived source's bank account: it works and the dropdown still shows the archived current account.
- [ ] Cancel returns the form to `New source` without saving. Clicking Edit on a second source refills the form.
- [ ] Edit a bank account: `Rename bank account` form; saving updates the Bank accounts table, the Dashboard row, the source column and the bank balance dialog dropdown. A duplicate name is refused.
- [ ] `flutter analyze` and `flutter test` pass.
