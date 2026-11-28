# AR01: Ledger models, repository and mock data

**Goal:** the data layer for the Accounts report in sample mode: models, one repository method, a mock implementation that filters and computes the running balance, and tests. No UI yet.

**Prerequisites:** PT04 done.

## Files

| File | Change |
|------|--------|
| `lib/core/models/account_ledger.dart` | new: `LedgerRow`, `AccountLedger` |
| `lib/core/data/finance_repository.dart` | `kLedgerPageSize`, `accountLedger` |
| `lib/core/data/mock_finance_repository.dart` | the mock method |
| `lib/core/data/supabase/supabase_finance_repository.dart` | keep compiling (see below) |
| `test/core/account_ledger_test.dart` | new tests |

## Models

```dart
class LedgerRow extends Equatable {
  const LedgerRow({required this.id, required this.date, required this.description,
      required this.type, required this.sourceId, required this.amount, required this.closing});
  final String id; final DateTime date; final String description;
  final TxType type; final String sourceId;
  final double amount;     // always positive
  final double closing;    // running balance after this row
  double get credit => type == TxType.income ? amount : 0;
  double get debit => type == TxType.income ? 0 : amount;
}

class AccountLedger extends Equatable {
  const AccountLedger({required this.rows, required this.total, required this.page, required this.pageCount,
      required this.opening, required this.totalCredit, required this.totalDebit});
  final List<LedgerRow> rows;    // one page, newest first
  final int total;               // rows in the whole filtered range
  final int page; final int pageCount;
  final double opening;          // balance of the chosen sources just before the From date
  final double totalCredit; final double totalDebit;   // over the whole filtered range
  double get closing => opening + totalCredit - totalDebit;
}
```
(`Equatable` props: all fields.)

## Repository

```dart
const kLedgerPageSize = 25;

Future<AccountLedger> accountLedger({
  required DateTime from,      // inclusive
  required DateTime to,        // inclusive
  String? bankAccountId,       // null = all bank accounts
  String? sourceId,            // null = all sources (of the chosen bank account)
  TxType? type,                // null = all types
  int page = 1,
});
```

## Mock behaviour

The mock ledger is built from the sample transactions `t1` to `t10` (all dated November 2026) and the current in-memory sources:

1. The sources in scope are the current in-memory sources (archived included) whose `bankAccountId` matches when `bankAccountId` is given and whose id matches when `sourceId` is given (both must hold, so a source outside the chosen account gives nothing). Keep the entries of those sources whose date is between `from` and `to` (compare dates only, both ends inclusive) and whose type matches when given.
2. `opening` = the sum of `openingBalance` of the sources in scope. It does **not** change with the date range or the type filter.
3. Sort oldest first (date, then id) and compute `closing` as `opening` plus a running `credit − debit` over the kept entries.
4. `totalCredit` and `totalDebit` sum the kept entries. `total` is their count; `pageCount = max(1, ceil(total / kLedgerPageSize))`.
5. Return the requested `page` of the list **newest first** (reverse of step 3), with `page` clamped to `1..pageCount`.

The sample entries do not add up to the fixed Dashboard figures; that is expected (same as the Transactions list).

## Keep the rest compiling

`SupabaseFinanceRepository.accountLedger` throws `UnimplementedError('AR04')` for now.

## Tests (`account_ledger_test.dart`)

Use `MockFinanceRepository` and the range 1 to 30 Nov 2026:
- All sources, all types: `total` 10, `rows` has 10, the newest row is `t1` or `t2` (25 Nov), the oldest is `t10` (5 Nov); `opening` 33000; `totalCredit` 45000 + 28000 + 35000 + 120000 = 228000; `totalDebit` 32000 + 4200 + 20000 + 2400 + 10000 + 3600 = 72200; `closing` = 33000 + 228000 − 72200 = 188800 and equals the newest row's `closing`.
- Closing runs oldest to newest: the oldest row (`t10`, salary credited 120000) has closing 153000.
- Source `salary` only: `opening` 15000 and only salary entries (`t1`, `t2`, `t3`, `t10`).
- Bank account `hdfc-salary`: `opening` 21000 (Salary, Side hustle, Old freelance), entries `t1`, `t2`, `t3`, `t7`, `t10`, credit 155000, debit 56200, closing 119800. Bank account `sbi-rentals`: `opening` 12000, entries `t4`, `t5`, `t6`, `t8`, `t9`, credit 73000, debit 16000, closing 69000. The two closings add up to 188800. Bank account `sbi-rentals` with source `salary`: no rows and `opening` 0.
- Type `income`: only credits (`totalDebit` 0); rows have `debit` 0; the running closing starts from `opening` and adds only the shown rows (oldest row closing 33000 + 120000).
- Range 1 to 10 Nov: only `t10`; range in October: no rows, `total` 0, `pageCount` 1, `opening` 33000, `closing` 33000.
- A row's `credit` / `debit` split follows the type (income → credit, expense and Jillu → debit).

## Do not

Add a Cubit, page or route (AR02), touch SQL (AR03).

## Verify

- [ ] `flutter analyze` is clean and `flutter test` passes.
- [ ] The app still runs in sample mode and every page behaves as before.
