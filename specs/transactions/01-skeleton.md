# Transactions 01: Skeleton

**Goal:** replace the placeholder Transactions page with the real structure: Cubit loading data, header, and placeholders for the list and the add-entry panel.

**Prerequisites:** specs 00 to 06 done. The Dashboard specs are not required.

## Files

| File | Contents |
|------|----------|
| `lib/features/transactions/cubit/transactions_state.dart` | `TransactionsState` |
| `lib/features/transactions/cubit/transactions_cubit.dart` | `TransactionsCubit` |
| `lib/features/transactions/view/transactions_page.dart` | change: real page |

## State (`Equatable`, README pattern)

| Field | Type | Initial |
|-------|------|---------|
| `status` | `LoadStatus` | `loading` |
| `page` | `TransactionPage?` | `null` |
| `sources` | `List<Source>` | `[]` |
| `categories` | `List<Category>` | `[]` |
| `templates` | `List<EntryTemplate>` | `[]` |
| `month` | `DateTime` | `mockMonth` |
| `sourceFilter` | `String?` (source id, null = all) | `null` |
| `typeFilter` | `TxType?` (null = all) | `null` |
| `query` | `String` | `''` |

Helpers on the state: `String sourceName(String id)` and `String categoryName(String? id)` (returns `—` when `id` is null or unknown).

## Cubit

- `load()`: fetches `sources()`, `categories()`, `templates()`, `transactions()` and emits `loaded`.
- `setMonth`, `setSourceFilter`, `setTypeFilter`, `setQuery`: update the filter fields only. Filtering is **visual only** in this phase, so the list does not change.

## Page

`TransactionsPage` creates the Cubit (`..load()`); the view shows a centered `CircularProgressIndicator` while loading, otherwise a `Column(crossAxisAlignment: start, spacing: 20)`:
1. `PageHeader(title: 'Transactions', subtitle: 'Sample data', actions: [AppButton(label: 'Copy from last month', variant: secondary, onPressed: () => context.go(AppRoutes.templates))])`.
2. `TwoPane(primaryMin: 560, secondaryWidth: 340, primary: SectionPlaceholder(name: 'Filters and list', height: 560), secondary: SectionPlaceholder(name: 'New entry panel', height: 560))`.

## Do not

Build the list or the panel. Do not implement filtering.

## Verify

- [x] `/transactions` shows the header with a secondary "Copy from last month" button (goes to `/templates`).
- [x] Two placeholders: a wide one on the left and a 340px one on the right; stacked on a narrow window.
- [x] `flutter analyze` is clean.
