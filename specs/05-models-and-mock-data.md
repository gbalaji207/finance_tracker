# 05: Models, repository and mock data

**Goal:** domain models, the `FinanceRepository` interface, a hardcoded `MockFinanceRepository` with all sample data from the wireframes, and tests that check the numbers.

**Prerequisites:** specs 01 to 04 done (`TxType` already exists).

## Files to create (all in `lib/core/`)

| File | Contents |
|------|----------|
| `models/load_status.dart` | `enum LoadStatus { loading, loaded }` |
| `models/source.dart` | `Source` |
| `models/category.dart` | `Category` |
| `models/transaction.dart` | `Transaction` |
| `models/entry_template.dart` | `EntryTemplate` |
| `models/bank_reconciliation.dart` | `BankReconciliation` |
| `models/source_summary.dart` | `SourceSummary` |
| `models/monthly_report.dart` | `MonthlyReport`, `CategoryTotal` |
| `models/source_report.dart` | `SourceReport`, `SourceMonthRow` |
| `models/transaction_page.dart` | `TransactionPage` |
| `data/finance_repository.dart` | `FinanceRepository` |
| `data/mock_clock.dart` | `mockToday`, `mockMonth` |
| `data/mock_finance_repository.dart` | `MockFinanceRepository` |
| `test/core/mock_finance_repository_test.dart` | tests |

All models are immutable, `const` constructors, extend `Equatable`. Amounts are positive `double` rupees (direction comes from `TxType`).

## Models

```
Source               { String id, String name, String kind, double openingBalance }
Category             { String id, String name, TxType kind }          // expense | investment | savings
Transaction          { String id, DateTime date, TxType type, String sourceId,
                       String? categoryId, double amount, String description }
EntryTemplate        { String id, String name, TxType type, String sourceId,
                       String? categoryId, double? amount, String description }
BankReconciliation   { double sourcesTotal, double bankBalance, DateTime asOf;
                       double get difference => sourcesTotal - bankBalance }
SourceSummary        { Source source, double income, expense, invested, saved,
                       closing, investedSavedToDate;  double get opening => source.openingBalance }
CategoryTotal        { String name, double amount }
MonthlyReport        { List<SourceSummary> bySource, List<CategoryTotal> expenseByCategory;
                       getters: opening, income, expense, invested, saved, closing (sums over bySource);
                       double get savingsRate => (invested + saved) / income }
SourceMonthRow       { DateTime month, double income, expense, investedSaved, closing }
SourceReport         { Source source, double balanceToday, incomeThisMonth,
                       expenseThisMonth, investedSavedToDate, List<SourceMonthRow> months }  // newest first
TransactionPage      { List<Transaction> items, int total, int page, int pageCount }
```

## Repository interface

```dart
abstract interface class FinanceRepository {
  Future<List<Source>> sources();
  Future<List<Category>> categories();
  Future<BankReconciliation> reconciliation();
  Future<List<SourceSummary>> sourceSummaries(DateTime month);
  Future<List<Transaction>> recentTransactions();
  Future<TransactionPage> transactions({int page = 1});
  Future<List<EntryTemplate>> templates();
  Future<List<EntryTemplate>> quickAddTemplates();
  Future<List<Transaction>> previousMonthEntries(DateTime month);
  Future<MonthlyReport> monthlyReport(DateTime month);
  Future<SourceReport> sourceReport(String sourceId);
}
```

`MockFinanceRepository` implements it with the data below. It **ignores** the `month`, `page` and `sourceId` arguments and always returns this fixed data (documented in a comment). Methods return immediately (`async` with no delay).

`mock_clock.dart`: `final mockToday = DateTime(2026, 11, 26);` and `final mockMonth = DateTime(2026, 11);`.

## Mock data

**Sources** (id, name, kind, opening balance)

| id | name | kind | opening |
|----|------|------|---------|
| `salary` | Salary | Employment | 15000 |
| `side-hustle` | Side hustle | Freelance | 6000 |
| `aqua-105` | Aqua 105 | Rental | 8000 |
| `vr` | VR | Rental | 4000 |

**Categories** (id, name, kind)

| id | name | kind |
|----|------|------|
| `housing` | Housing | expense |
| `groceries` | Groceries | expense |
| `utilities` | Utilities | expense |
| `property-upkeep` | Property upkeep | expense |
| `other` | Other | expense |
| `mutual-funds` | Mutual funds | investment |
| `fixed-deposit` | Fixed deposit | savings |

**Source summaries, November 2026** (return in this order)

| source | income | expense | invested | saved | closing | to date |
|--------|-------:|--------:|---------:|------:|--------:|--------:|
| Salary | 120000 | 55800 | 20000 | 6000 | 53200 | 410000 |
| Side hustle | 35000 | 8600 | 10000 | 0 | 22400 | 60000 |
| Aqua 105 | 45000 | 12000 | 0 | 10000 | 31000 | 180000 |
| VR | 28000 | 6200 | 0 | 0 | 25800 | 0 |

These are hardcoded. Do **not** compute them from the transaction lists, which are samples and do not add up to these totals.

**Reconciliation:** sourcesTotal 132400, bankBalance 132400, asOf `mockToday`.

**Transactions** (ids `t1` to `t10`; this is page 1 of `total: 38`, `pageCount: 4`)

| id | date | description | source | category | type | amount |
|----|------|-------------|--------|----------|------|-------:|
| t1 | 2026-11-25 | Home EMI | salary | housing | expense | 32000 |
| t2 | 2026-11-25 | Groceries | salary | groceries | expense | 4200 |
| t3 | 2026-11-24 | SIP: index fund | salary | mutual-funds | investment | 20000 |
| t4 | 2026-11-22 | Rent received | aqua-105 | none | income | 45000 |
| t5 | 2026-11-22 | Rent received | vr | none | income | 28000 |
| t6 | 2026-11-20 | Electricity bill | vr | utilities | expense | 2400 |
| t7 | 2026-11-18 | Client payout | side-hustle | none | income | 35000 |
| t8 | 2026-11-15 | Recurring deposit | aqua-105 | fixed-deposit | savings | 10000 |
| t9 | 2026-11-12 | Plumbing repair | aqua-105 | property-upkeep | expense | 3600 |
| t10 | 2026-11-05 | Salary credited | salary | none | income | 120000 |

`recentTransactions()` returns exactly `t1, t3, t4, t6, t7, t8` in that order.

**Templates** (ids `tp1` to `tp6`)

| id | name | type | source | category | amount |
|----|------|------|--------|----------|-------:|
| tp1 | Home EMI | expense | salary | housing | 32000 |
| tp2 | SIP: index fund | investment | salary | mutual-funds | 20000 |
| tp3 | Rent received | income | aqua-105 | none | 45000 |
| tp4 | Rent received | income | vr | none | 28000 |
| tp5 | Internet bill | expense | vr | utilities | none (null) |
| tp6 | Recurring deposit | savings | aqua-105 | fixed-deposit | 10000 |

Descriptions: empty string for all. `quickAddTemplates()` returns `tp1, tp2, tp3, tp5` in that order.

**Previous month entries** (October 2026, ids `o1` to `o6`)

| id | date | description | source | type | amount |
|----|------|-------------|--------|------|-------:|
| o1 | 2026-10-05 | Home EMI | salary | expense | 32000 |
| o2 | 2026-10-05 | SIP: index fund | salary | investment | 20000 |
| o3 | 2026-10-22 | Rent received | aqua-105 | income | 45000 |
| o4 | 2026-10-22 | Rent received | vr | income | 28000 |
| o5 | 2026-10-20 | Electricity bill | vr | expense | 2100 |
| o6 | 2026-10-15 | Recurring deposit | aqua-105 | savings | 10000 |

**Monthly report:** `bySource` is the four source summaries above. `expenseByCategory` (descending): Housing 32000, Groceries 15000, Property upkeep 14600, Other 12000, Utilities 9000. Totals should come out as income 228000, expense 82600, invested 30000, saved 16000, opening 33000, closing 132400, savingsRate about 0.20.

**Source report for Aqua 105:** source = Aqua 105; balanceToday 31000; incomeThisMonth 45000; expenseThisMonth 12000; investedSavedToDate 180000; `months` newest first:

| month | income | expense | investedSaved | closing |
|-------|-------:|--------:|--------------:|--------:|
| 2026-11 | 45000 | 12000 | 10000 | 31000 |
| 2026-10 | 45000 | 10500 | 40000 | 8000 |
| 2026-09 | 45000 | 11000 | 30000 | 13500 |
| 2026-08 | 45000 | 8500 | 35000 | 9500 |
| 2026-07 | 45000 | 14000 | 25000 | 8000 |
| 2026-06 | 45000 | 9000 | 40000 | 2000 |

## Tests (`mock_finance_repository_test.dart`)

- For every source summary: `closing == opening + income - expense - invested - saved`.
- Sum of `closing` over the summaries equals 132400 and equals `reconciliation().sourcesTotal`; `difference` is 0.
- `monthlyReport` totals: income 228000, expense 82600, invested 30000, saved 16000; `expenseByCategory` amounts sum to 82600.
- `transactions()` returns 10 items with `total` 38; `recentTransactions()` ids are `t1, t3, t4, t6, t7, t8`.
- `sourceReport('aqua-105').months` has 6 rows, first is November 2026.

## Do not

Add Cubits, pages or widgets. Do not wire anything into `main.dart`.

## Verify

- [x] `flutter analyze` is clean and `flutter test` passes (money tests and these).
- [x] No file under `lib/` other than `mock_finance_repository.dart` contains the sample numbers.
