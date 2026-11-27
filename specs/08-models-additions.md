# 08: Model and repository additions

**Goal:** the data the new screens need: archived sources, category usage counts, a per-source balance lookup and the balance-after-delete helper, with tests.

**Prerequisites:** Part 1 done (especially spec 05). Spec 07 is not required.

## Files

| File | Change |
|------|--------|
| `lib/core/models/source.dart` | add `bool isActive` (default `true`) and `copyWith({bool? isActive})` |
| `lib/core/models/category.dart` | add `bool isActive` (default `true`) |
| `lib/core/models/category_usage.dart` | new: `CategoryUsage { Category category, int entryCount }` |
| `lib/core/utils/balance_math.dart` | new: `BalanceMath` |
| `lib/core/data/finance_repository.dart` | add three methods; change one behavior |
| `lib/core/data/mock_finance_repository.dart` | implement them with the data below |
| `test/core/mock_finance_repository_test.dart` | add tests |
| `test/core/balance_math_test.dart` | new tests |

Existing code that constructs `Source` and `Category` must keep compiling (the new field has a default).

## Repository changes

```dart
Future<List<Source>> sources();                 // CHANGED: active sources only
Future<List<Source>> allSources();              // NEW: active and archived
Future<List<CategoryUsage>> categoryUsage();    // NEW
Future<double> sourceBalance(String sourceId);  // NEW: current closing balance
```

Dropdowns and forms that already call `sources()` keep working and now list only active sources, which is what new entries should use.

## BalanceMath

```dart
abstract final class BalanceMath {
  /// Balance of a source after the given entry is deleted.
  /// Income was added to the balance, so deleting it subtracts; every other type
  /// (expense, investment, savings) was subtracted, so deleting it adds.
  static double afterDeleting(Transaction entry, double balance) =>
      entry.type == TxType.income ? balance - entry.amount : balance + entry.amount;
}
```

## Mock data

**Sources:** add a fifth source after VR: `old-freelance`, "Old freelance", kind Freelance, opening balance 0, `isActive: false`. `sources()` returns the first four (all active); `allSources()` returns all five in this order: Salary, Side hustle, Aqua 105, VR, Old freelance.

**Category usage** (all categories active; return in this order):

| Category | entryCount |
|----------|-----------:|
| Housing | 12 |
| Groceries | 28 |
| Utilities | 14 |
| Property upkeep | 6 |
| Other | 9 |
| Mutual funds | 11 |
| Fixed deposit | 5 |

**sourceBalance:** returns the `closing` value from the source summaries: Salary 53200, Side hustle 22400, Aqua 105 31000, VR 25800; any other id (including `old-freelance`) returns 0.

## Tests

`mock_finance_repository_test.dart` (add):
- `sources()` has 4 items, all active; `allSources()` has 5 and the last has `isActive == false`.
- `categoryUsage()` has 7 items and the counts sum to 85.
- `sourceBalance('salary')` is 53200; `sourceBalance('old-freelance')` is 0.

`balance_math_test.dart`:
- Expense 32000 from balance 53200 gives 85200.
- Investment 20000 from balance 53200 gives 73200.
- Income 45000 from balance 31000 gives -14000.

## Do not

Change any UI. Do not add repository methods other than those listed.

## Verify

- [x] `flutter analyze` is clean and `flutter test` passes.
- [x] The five existing pages still look and behave exactly as before.
