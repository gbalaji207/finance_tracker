# BA01: Bank account models, repository and mock data

**Goal:** the data layer for bank accounts in sample mode: models, repository methods, mock data with two accounts, and tests. The Dashboard and Settings get only the minimum change needed to compile; their real UI comes in BA02 to BA04.

**Prerequisites:** B10 done.

## Files

| File | Change |
|------|--------|
| `lib/core/models/bank_account.dart` | new: `BankAccount`, `BankAccountUsage` |
| `lib/core/models/bank_reconciliation.dart` | rewrite: `BankAccountReconciliation`, `BankReconciliation` |
| `lib/core/models/source.dart` | add `bankAccountId`, `bankAccountName` |
| `lib/core/models/source_input.dart` | add `bankAccountId` |
| `lib/core/data/finance_repository.dart` | new and changed methods |
| `lib/core/data/mock_finance_repository.dart` | mock data and in-memory state |
| `lib/core/data/supabase/supabase_finance_repository.dart` | keep compiling (see below) |
| `lib/features/dashboard/widgets/reconciliation_strip.dart`, `dashboard_page.dart`, `dashboard_cubit.dart` | temporary minimal adaptation |
| `test/core/mock_finance_repository_test.dart`, `test/core/bank_reconciliation_test.dart` | tests |

## Models

```dart
class BankAccount extends Equatable {
  const BankAccount({required this.id, required this.name, this.isActive = true});
  final String id; final String name; final bool isActive;
}

class BankAccountUsage extends Equatable {       // Settings list
  const BankAccountUsage({required this.account, required this.activeSourceCount});
  final BankAccount account; final int activeSourceCount;
}

class BankAccountReconciliation extends Equatable {
  const BankAccountReconciliation({required this.account, required this.sourcesTotal, this.bankBalance, this.asOf});
  final BankAccount account;
  final double sourcesTotal;      // sum of the balances of this account's sources
  final double? bankBalance;      // latest statement balance; null = never entered
  final DateTime? asOf;
  bool get isSet => bankBalance != null;
  double? get difference => bankBalance == null ? null : sourcesTotal - bankBalance!;
  bool get matches => difference != null && difference!.abs() < 0.005;
}

class BankReconciliation extends Equatable {
  const BankReconciliation(this.accounts);
  final List<BankAccountReconciliation> accounts;
  double get sourcesTotal => accounts.fold(0, (a, e) => a + e.sourcesTotal);
  double get bankTotal => accounts.where((e) => e.isSet).fold(0, (a, e) => a + e.bankBalance!);
  int get missingCount => accounts.where((e) => !e.isSet).length;
  int get offCount => accounts.where((e) => e.isSet && !e.matches).length;
  double get offAmount => accounts.where((e) => e.isSet && !e.matches).fold(0, (a, e) => a + e.difference!.abs());
  bool get allMatch => accounts.isNotEmpty && missingCount == 0 && offCount == 0;
}
```
(`Equatable` props: all fields.) The old `BankReconciliation(sourcesTotal, bankBalance, asOf)` is removed; fix every reference.

`Source` gets `String? bankAccountId` and `String? bankAccountName` (defaults null; part of `copyWith` and `props`). `SourceInput` gets a required `String bankAccountId`.

## Repository

```dart
Future<List<BankAccount>> bankAccounts();            // active only: for forms
Future<List<BankAccount>> allBankAccounts();         // active and archived
Future<List<BankAccountUsage>> bankAccountUsage();   // all accounts with active source counts: Settings
Future<BankReconciliation> reconciliation();         // CHANGED: one entry per account
Future<void> setBankBalance(String bankAccountId, double balance, DateTime asOf);  // CHANGED: account added
Future<void> addBankAccount(String name);
Future<void> setBankAccountActive(String id, bool active);
```

## Mock data and behaviour

Accounts, in this order (all active): `hdfc-salary` "HDFC Salary" and `sbi-rentals` "SBI Rentals".

Mock sources get these accounts: Salary and Side hustle and Old freelance: `hdfc-salary` (name "HDFC Salary"); Aqua 105 and VR: `sbi-rentals` (name "SBI Rentals"). The same account fields appear on the `Source` inside every `SourceSummary` and `SourceReport`.

In-memory state inside `MockFinanceRepository`: the list of accounts (so `addBankAccount` can append `new-N` accounts), a set of archived account ids, and a map accountId to `(balance, asOf)` starting as `hdfc-salary: 75600` and `sbi-rentals: 56800`, both dated `mockToday`.

- `bankAccounts()` = accounts not archived; `allBankAccounts()` = all; `bankAccountUsage()` = every account with the number of **active** sources linked to it (HDFC Salary 2, SBI Rentals 2).
- `reconciliation()`: one `BankAccountReconciliation` per account that is active or has a non-zero `sourcesTotal`. `sourcesTotal` is the sum of the closing balances of its sources in the mock summaries (HDFC Salary 75600 = 53200 + 22400 + 0; SBI Rentals 56800 = 31000 + 25800), plus the opening balance of any source added in memory (B10). `bankBalance` and `asOf` come from the map.
- `setBankBalance` stores into the map; `addBankAccount` appends; `setBankAccountActive` updates the archived set.
- The mock `addSource` (B10) stores `bankAccountId` and the account's name on the new source.

## Keep the rest compiling

- `SupabaseFinanceRepository`: add the new methods throwing `UnimplementedError('BA06')`; change the two changed signatures to match. (The old real `reconciliation()` is dropped; Supabase mode stays broken until BA06, as the README says.)
- Dashboard, minimal adaptation (BA02 and BA03 replace it): the strip shows `Sum of source balances` = `data.sourcesTotal`, `Bank balances, all accounts` = `data.bankTotal`, the pill `Matches · difference ₹0` when `allMatch`, otherwise a warning pill `Check bank accounts`, and keeps one "Update bank balance" link that opens the existing dialog for the **first** account (its `sourcesTotal`, `bankBalance ?? sourcesTotal`, `asOf ?? appToday()`) and calls `DashboardCubit.updateBankBalance(firstAccountId, balance, asOf)`. The cubit's method gets the extra `accountId` argument and passes it on.

## Tests

`bank_reconciliation_test.dart`: two accounts where both match: `allMatch` true, `bankTotal` = sum; one account off by 400 (sources 75600, bank 75200): `offCount` 1, `offAmount` 400, `allMatch` false; one account with `bankBalance` null: `missingCount` 1, `allMatch` false, `bankTotal` excludes it; no accounts: `allMatch` false. `mock_finance_repository_test.dart`: `bankAccounts()` has 2; `reconciliation()` has HDFC Salary 75600/75600 and SBI Rentals 56800/56800 with `sourcesTotal` 132400 overall; after `setBankBalance('hdfc-salary', 75200, date)` HDFC's difference is 400; after `setBankAccountActive('sbi-rentals', false)` `bankAccounts()` has 1 while the reconciliation still lists SBI Rentals (it holds money).

## Do not

Change layouts beyond the minimal Dashboard adaptation.

## Verify

- [ ] `flutter analyze` is clean and `flutter test` passes.
- [ ] Sample mode: the Dashboard still loads; the strip shows ₹1,32,400 and ₹1,32,400 with the green "Matches" pill; "Update bank balance" still opens the dialog (for HDFC Salary, so it shows 75600).
- [ ] Every other page behaves as before.
