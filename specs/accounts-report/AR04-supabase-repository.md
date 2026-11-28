# AR04: Real repository for the Accounts report

**Goal:** `SupabaseFinanceRepository.accountLedger` calls the new functions, so the page works against the migrated database.

**Prerequisites:** AR03 done (the functions exist).

## Files

| File | Change |
|------|--------|
| `lib/core/data/supabase/row_mappers.dart` | `ledgerRowFromRow` |
| `lib/core/data/supabase/supabase_finance_repository.dart` | implement `accountLedger` |
| `test/core/row_mappers_test.dart` | new tests |

## Mapper

```dart
LedgerRow ledgerRowFromRow(Map<String, dynamic> r);
// entry_id, entry_date (yyyy-MM-dd), description, entry_type (by name), source_id, amount, closing (numbers or strings via toDouble)
```

## Repository

```dart
Future<AccountLedger> accountLedger({required from, required to, bankAccountId, sourceId, type, page = 1}) async
```
Run both rpcs together (`Future.wait`):
- `account_ledger` with `{p_from: sqlDate(from), p_to: sqlDate(to), p_bank_account: bankAccountId, p_source: sourceId, p_type: type?.name, p_limit: kLedgerPageSize, p_offset: (page - 1) * kLedgerPageSize}`.
- `account_ledger_summary` with the first five parameters (everything except the limit and offset).

Build `AccountLedger` from them: `rows` from the first, `opening`, `totalCredit`, `totalDebit` from the single summary row (`opening_balance`, `total_credit`, `total_debit` via `toDouble`), `total` = `entry_count` (int or string), `pageCount = max(1, ceil(total / kLedgerPageSize))`, `page` as requested. Dates go to the database with `sqlDate()`, never `toIso8601String()`.

## Tests

In `row_mappers_test.dart`: a ledger row with the amounts as strings (`"45000.00"`) and one with numbers; an income row has `credit` = amount and `debit` 0; a Jillu (`partner`) row has `debit` = amount.

## Do not

Change SQL (a database change goes in a new numbered file), or add other filters.

## Verify (Supabase mode, signed in, after AR03)

- [ ] The Accounts report loads for the current month. The summary tiles match `select * from account_ledger_summary(...)` for the same range, and Closing equals the Opening plus Credit minus Debit.
- [ ] With all sources and no type, the newest row's Closing equals the Dashboard's sum of source balances when the To date is today (and no entries are dated later).
- [ ] Choose a Bank account: the Source dropdown then lists only that account's sources, Opening is that account's balance at the start of the range and Closing at the end of the range matches the account's sources on the Dashboard (to compare with the bank statement). With "All accounts" the closings of the separate accounts add up to the total.
- [ ] Choose a Source: Opening is only that source's balance at the start of the range, and the rows are only its entries.
- [ ] Choose Type = Expense: only debits show, Opening is unchanged and Closing falls by each expense; the note about the shown rows appears.
- [ ] A range with more than 25 entries pages correctly and the Closing continues across pages.
- [ ] Adding an entry on the Transactions page shows it here after a reload or a filter change.
- [ ] Sample mode still works. `flutter analyze` and `flutter test` pass.
