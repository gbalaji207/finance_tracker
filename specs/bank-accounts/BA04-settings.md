# BA04: Settings: bank accounts and the account on each source

**Goal:** a Bank accounts card and form on Settings, a Bank account column on the sources table, and a Bank account choice on the new-source form.

**Prerequisites:** BA03 done.

## Files

| File | Change |
|------|--------|
| `lib/features/settings/cubit/settings_state.dart`, `settings_cubit.dart` | bank account data and methods |
| `lib/features/settings/widgets/bank_accounts_card.dart` | new: `BankAccountsCard` |
| `lib/features/settings/widgets/new_bank_account_card.dart` | new: `NewBankAccountCard` |
| `lib/features/settings/widgets/sources_card.dart` | new column |
| `lib/features/settings/widgets/new_source_card.dart` | account dropdown |
| `lib/features/settings/view/settings_page.dart` | new first row; subtitle |

## State and cubit

`SettingsState` gets `List<BankAccountUsage> bankAccounts` (initially empty) and a getter `List<BankAccount> get activeBankAccounts`. `SettingsCubit.load()` also fetches `bankAccountUsage()`. New methods, each returning `Future<String?>` (error message or null, then reload the lists, like the others from B10):
- `addBankAccount(String name)`;
- `toggleBankAccountActive(String id)`: when archiving an account whose `activeSourceCount > 0` return `This account still has active sources. Archive them first.` without calling the repository; otherwise call `setBankAccountActive`.
- `addSource` already takes a `SourceInput` (it now has `bankAccountId`).

## BankAccountsCard

`BankAccountsCard({required List<BankAccountUsage> accounts, required ValueChanged<BankAccount> onEdit, required ValueChanged<BankAccount> onToggleActive})`

An `AppCard` (padding 20) with `Column(crossAxisAlignment: start)`: `Bank accounts` in `sectionTitle`; 4px below, `Each source belongs to one bank account. The dashboard compares each account's statement balance with the balances of its sources.` in `subtitle`; 8px of space; then `AppTable(minWidth: 480)`:

| Column | Width / flex | Align |
|--------|--------------|-------|
| Name | flex 1.2 | left |
| Active sources | 110 | right |
| Status | 96 | left |
| Actions | 130 | right |

Cells: name `bodyStrong`; the count; the same Active / Archived `AppBadge` as on sources; actions `Row(mainAxisSize: min, spacing: 16)` of `AppTextLink('Edit')` (shows the SnackBar `Not wired yet (sample data)`) and `AppTextLink(isActive ? 'Archive' : 'Restore')` (calls `onToggleActive`).

## NewBankAccountCard

`NewBankAccountCard({required Future<String?> Function(String name) onSave})`, stateful. `AppCard` (padding 20), `Column(crossAxisAlignment: stretch, spacing: 14)`: `New bank account` in `sectionTitle`; `AppTextField` `Name`, hint `e.g. HDFC Salary`, helper `Use a name you will recognise from your bank statement.`; `AppButton('Save bank account', primary, large, expand)`. Validation message in the red 13px style: `Enter a name.` On save call `onSave`; a returned message goes to `AppSnack.error`; success shows `AppSnack.info(AppConfig.note('Bank account saved'))` and clears the field. Disabled while saving.

## Sources table and form

- `SourcesCard`: new column **Bank account** after Kind. Columns become Name flex 1.1, Kind 96, Bank account 120, Opening balance 120, Status 96, Actions 130; `minWidth` 700. The cell shows `source.bankAccountName ?? '—'`.
- `NewSourceCard`: gets `List<BankAccount> bankAccounts`. Add `AppDropdown<String>` `Bank account` after Kind (items = active accounts, default the first), helper `The account where this source's money is kept.` With no accounts the dropdown is disabled and saving shows `Add a bank account first.` The `SourceInput` carries `bankAccountId`.

## Page layout

Settings order becomes: **Bank accounts** row (`TwoPane(primaryMin: 560, secondaryWidth: 340)`: `BankAccountsCard` and `NewBankAccountCard`), then the Sources row, the Categories row, the Account card. Page subtitle: sample `Sample data · bank accounts, sources, categories and your account`; Supabase mode `Bank accounts, sources, categories and your account` (update the table in B01 accordingly).

## Expected content (sample data)

| Bank accounts | Active sources | Status |
|---|---:|---|
| HDFC Salary | 2 | Active |
| SBI Rentals | 2 | Active |

Sources: Salary, Side hustle, Old freelance show `HDFC Salary`; Aqua 105 and VR show `SBI Rentals`.

## Do not

Edit an account or a source's account; add an account filter anywhere else.

## Verify (sample mode)

- [x] Settings shows Bank accounts first (two rows as above), the sources table with the new column, and the new-source form with a Bank account dropdown (HDFC Salary selected).
- [x] Add bank account "Test account": it appears with 0 active sources, Active. On the Dashboard strip it appears as a third row (`Sources ₹0`, `Not set`) and the top pill adds `Balance not set for 1 account`.
- [x] Add a source "Test source" under "Test account" with opening balance 1000: the Dashboard row for Test account shows `₹1,000`. Setting its bank balance to 1000 (BA03 dialog) makes it match.
- [x] Archive "HDFC Salary": blocked with the message "This account still has active sources. Archive them first." Archive "Test account" after archiving its source is allowed; the badge turns grey and the link becomes "Restore".
- [x] Archived accounts no longer appear in the new-source dropdown. Reload resets everything. `flutter analyze` and `flutter test` pass.
