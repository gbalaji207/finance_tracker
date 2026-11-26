# Dashboard 04: Recent entries

**Goal:** the "Recent entries" card (a table of the six latest entries) on the left of the bottom row.

**Prerequisites:** Dashboard 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/dashboard/widgets/recent_entries_card.dart` | `RecentEntriesCard` |
| `lib/features/dashboard/view/dashboard_page.dart` | change: replace the `primary` placeholder inside the `TwoPane` |

## RecentEntriesCard

`RecentEntriesCard({required List<Transaction> entries, required String Function(String sourceId) sourceName, required VoidCallback onViewAll})`

An `AppCard` (padding 20) containing:
1. `SectionHeader(title: 'Recent entries', actionLabel: 'View all', onAction: onViewAll)`.
2. An `AppTable` with columns:

| Column | Width | Align |
|--------|-------|-------|
| Date | 64 | left |
| Description | flex 1 | left |
| Source | 110 | left |
| Type | 104 | left |
| Amount | 110 | right |

Row cells: date `AppDates.dayMonth(date)` as `AppTableText(secondary: true)`; description `AppTableText`; source `AppTableText(sourceName(sourceId))`; `TypeBadge(type)`; `AmountText(amount, type)`.

In the page, `onViewAll` is `() => context.go(AppRoutes.transactions)` and `sourceName` is `state.sourceName`.

## Expected content (sample data)

| Date | Description | Source | Type | Amount |
|------|-------------|--------|------|-------:|
| 25 Nov | Home EMI | Salary | Expense | −₹32,000 |
| 24 Nov | SIP: index fund | Salary | Investment | −₹20,000 |
| 22 Nov | Rent received | Aqua 105 | Income | +₹45,000 |
| 20 Nov | Electricity bill | VR | Expense | −₹2,400 |
| 18 Nov | Client payout | Side hustle | Income | +₹35,000 |
| 15 Nov | Recurring deposit | Aqua 105 | Savings | −₹10,000 |

## Do not

Add row click behavior, sorting or pagination.

## Verify

- [x] The card shows the six rows above with colored type badges; income amounts are green.
- [x] "View all" goes to `/transactions`.
- [x] Next to it the "Quick add" placeholder is still there (wide window), stacked below when narrow. `flutter analyze` is clean.
