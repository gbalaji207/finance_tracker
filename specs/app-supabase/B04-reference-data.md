# B04: Real repository, part 1: sources, categories, templates

**Goal:** create `SupabaseFinanceRepository`, switch the app to it in Supabase mode, and implement the reference-data methods. Settings and the Templates list then show real data. Other pages show the error card until their spec.

**Prerequisites:** B03 done.

## Files

| File | Change |
|------|--------|
| `lib/core/data/supabase/supabase_finance_repository.dart` | new: `SupabaseFinanceRepository` |
| `lib/core/data/supabase/row_mappers.dart` | new: row to model functions |
| `lib/core/models/source.dart` | add `DateTime? openingDate` |
| `lib/core/data/finance_repository.dart` | add `Future<List<Category>> allCategories();` |
| `lib/core/data/mock_finance_repository.dart` | implement `allCategories()` (same 7, all active); fill `openingDate` as null |
| `lib/app/app.dart` | choose the repository by mode |
| `test/core/row_mappers_test.dart` | new tests |

## Wiring

```dart
RepositoryProvider<FinanceRepository>(
  create: (_) => AppConfig.useSupabase
      ? SupabaseFinanceRepository(Supabase.instance.client)
      : MockFinanceRepository(),
  ...
```

## SupabaseFinanceRepository

`SupabaseFinanceRepository(SupabaseClient client)` implements `FinanceRepository`. Methods not covered yet **throw `UnimplementedError('Bxx')`** naming the spec that implements them (the pages show the error card meanwhile).

Implement now:

| Method | Query |
|--------|-------|
| `sources()` | `sources` where `is_active = true`, order `created_at` |
| `allSources()` | `sources`, order `created_at` |
| `categories()` | `categories` where `is_active = true`, order `created_at` |
| `allCategories()` | `categories`, order `created_at` |
| `categoryUsage()` | rpc `category_usage` |
| `sourceBalance(id)` | rpc `source_balance` with `p_source: id`; the result is a number (treat null as 0) |
| `templates()` | `entry_templates`, order `sort_order`, then `created_at` |
| `quickAddTemplates()` | same, filtered `quick_add = true` |
| `previousMonthEntries(month)` | `transactions` dated from the first day of `month` up to (not including) the first day of the next month; order `tx_date`, then `created_at`. The argument is the month to read (the Templates cubit already passes "this month minus one") |

## Mappers (`row_mappers.dart`, pure functions over `Map<String, dynamic>`)

```dart
double toDouble(Object? v) => v is num ? v.toDouble() : double.parse('$v');
Source sourceFromRow(Map<String, dynamic> r);            // id, name, kind, opening_balance, is_active, opening_date
Category categoryFromRow(Map<String, dynamic> r);        // kind via TxType.values.byName(r['kind'])
CategoryUsage categoryUsageFromRow(Map<String, dynamic> r); // category_id, name, kind, is_active, entry_count
EntryTemplate templateFromRow(Map<String, dynamic> r);   // category_id and amount may be null
Transaction transactionFromRow(Map<String, dynamic> r);  // id, tx_date, type, source_id, category_id, amount, description
```
Dates (`opening_date`) are parsed with `DateTime.parse` on the `yyyy-MM-dd` string. `entry_count` may arrive as int or string.

## Names of archived items

Lists of entries must show names of archived sources and categories too. Change these cubits to load the **full** lists and keep two views of them:
- Dashboard, Transactions and Templates cubits: load `allSources()` (instead of `sources()`) and, where categories are used, `allCategories()` (instead of `categories()`). Store them in the existing `sources` / `categories` fields so `sourceName` and `categoryName` also resolve archived ones.
- Add getters on those states: `List<Source> get activeSources => sources.where((s) => s.isActive).toList()` and `activeCategories` likewise.
- Everything that offers a choice for **new** data must use the active lists: the entry panel and its cubit (`AddEntryCubit` constructor arguments), the new-template card, and the Transactions source filter may use the full list.

Sample mode is unaffected (everything there is active).

## Tests (`row_mappers_test.dart`)

Feed one sample row per mapper (including a transaction row with `category_id` null) (numbers as both `int`/`double` and as a string such as `"32000.00"`) and assert the model fields, including a template with null amount and an income template with null category.

## Do not

Implement other repository methods. Change any widget's look.

## Verify (Supabase mode, signed in)

- [x] Settings shows 5 sources: Salary ₹2,000, Side hustle ₹3,000, Aqua 105 ₹6,000, VR ₹2,100 (all Active) and Old freelance ₹0 (Archived).
- [x] Settings categories show counts: Housing 2, Groceries 7, Utilities 6, Property upkeep 8, Other 7, Mutual funds 4, Fixed deposit 10.
- [x] Templates page: the list shows the six templates (Internet bill with no default amount). The "Copy from October 2026" card is not final yet: it lists the 17 entries of October, all ticked, and is completed in B09.
- [x] Dashboard, Transactions and reports show the error card for now ("Something went wrong").
- [x] Sample mode still works on every page. `flutter analyze` and `flutter test` pass.
