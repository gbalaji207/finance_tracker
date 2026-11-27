# BA06: Real repository for bank accounts

**Goal:** `SupabaseFinanceRepository` supports bank accounts, so the Dashboard, the dialog and Settings work against the migrated database.

**Prerequisites:** BA05 done (the migration has run).

## Files

| File | Change |
|------|--------|
| `lib/core/data/supabase/row_mappers.dart` | new mappers; source mappers read the account |
| `lib/core/data/supabase/supabase_finance_repository.dart` | implement the BA01 methods; update source queries |
| `test/core/row_mappers_test.dart` | new tests |

## Source queries and mappers

- `sources()` and `allSources()`: select `*, bank_accounts(name)` (the embedded account) instead of `*`. `sourceFromRow` also reads `bank_account_id` and `r['bank_accounts']?['name']` into `bankAccountId` / `bankAccountName`.
- `sourceSummaryFromRow` (the `source_summaries` rpc) builds its `Source` with `bank_account_id` and `bank_account_name` from the row.
- The single-source lookup used by `sourceReport` must carry the same fields.

New mappers:
```dart
BankAccount bankAccountFromRow(Map<String, dynamic> r);                    // id, name, is_active
BankAccountUsage bankAccountUsageFromRow(Map<String, dynamic> r);          // bank_account_id, name, is_active, active_source_count (int or string)
BankAccountReconciliation bankAccountReconciliationFromRow(Map<String, dynamic> r);
// bank_account_id, name, is_active, sources_total, bank_balance (nullable), as_of (nullable yyyy-MM-dd)
```

## Repository methods

| Method | Implementation |
|--------|----------------|
| `bankAccounts()` | `bank_accounts` where `is_active = true`, order `created_at` |
| `allBankAccounts()` | `bank_accounts`, order `created_at` |
| `bankAccountUsage()` | rpc `bank_account_usage` |
| `reconciliation()` | rpc `current_reconciliation`; `BankReconciliation(rows.map(bankAccountReconciliationFromRow))` |
| `setBankBalance(accountId, balance, asOf)` | upsert into `bank_balances` `{user_id: client.auth.currentUser!.id, bank_account_id, as_of: sqlDate(asOf), balance}` with `onConflict: 'bank_account_id,as_of'` (saving again for the same account and date replaces it) |
| `addBankAccount(name)` | insert `{name: name.trim()}` |
| `setBankAccountActive(id, active)` | update `is_active` by id, select the id back, throw `StateError('Not found')` when no row returns |
| `addSource(input)` | the B10 insert plus `bank_account_id: input.bankAccountId` |

Duplicate account names surface as `That name is already used.` through `friendlyError` (error code 23505), as for sources.

## Tests

Add to `row_mappers_test.dart`: an account row; a usage row with the count as a string; a reconciliation row with a null bank balance and null `as_of` (`isSet` false); a source row with an embedded `bank_accounts` map and one without it; a `source_summaries` row with the two new fields.

## Do not

Add an account filter to Transactions or the reports.

## Verify (Supabase mode, signed in, after BA05 and 06)

- [x] Dashboard strip: `Sum of source balances ₹1,32,400`, `Bank balances, all accounts ₹1,32,400`, green `Matches · difference ₹0`; the list shows HDFC Salary (₹75,600 / ₹75,600 · 26 Nov) and SBI Rentals (₹56,800 / ₹56,800 · 26 Nov). Source cards carry their account names. All other card numbers are as in B05.
- [x] Update the HDFC Salary row to `75200` as on today: its row reads `Off by ₹400`, SBI Rentals still matches, the top pill reads `Off by ₹400 in 1 account`. Reload: it persists. In **Table Editor, bank_balances** there are now two rows for HDFC Salary (26 Nov and today) and one for SBI Rentals. Restore `75600` for today's date.
- [x] Saving a second time for the same account and date replaces the row instead of adding one (the row count stays the same).
- [x] Settings: Bank accounts shows HDFC Salary 2 and SBI Rentals 2; the sources table shows the right account per source.
- [x] Add a bank account "Test account": it appears in Settings and as a Dashboard row (`Sources ₹0`, `Not set`, pill adds `Balance not set for 1 account`). Add a source "Test source" under it with opening balance 1000, then give the account a balance of 1000 in the dialog: the account matches. Adding "Test account" again fails with "That name is already used."
- [x] Archiving HDFC Salary is blocked (it has active sources). Clean up: archive "Test source" then "Test account" (delete the rows in Table Editor if you want them gone).
- [x] Transactions, Monthly report, Source report and templates behave exactly as before (accounts do not change them).
- [x] Sample mode still works. `flutter analyze` and `flutter test` pass.

## After this

The wipe-and-go-live steps are unchanged, with two additions: after wiping, create your real **bank accounts first** (Settings), then sources (each pointing at its account), then categories and entries, then record each account's bank balance last. `99-reset-dev-data.sql` now also clears `bank_accounts`, so run it only once, before real data, and then remove it from the repo.
