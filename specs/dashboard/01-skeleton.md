# Dashboard 01: Skeleton

**Goal:** replace the placeholder Dashboard with the real page structure: Cubit loading data, page header, and one placeholder per section. Sections arrive in specs 02 to 05.

**Prerequisites:** specs 00 to 06 done.

## Files

| File | Contents |
|------|----------|
| `lib/features/dashboard/cubit/dashboard_state.dart` | `DashboardState` |
| `lib/features/dashboard/cubit/dashboard_cubit.dart` | `DashboardCubit` |
| `lib/features/dashboard/view/dashboard_page.dart` | change: real page |

## State (`Equatable`, follows the README Cubit pattern)

| Field | Type | Initial |
|-------|------|---------|
| `status` | `LoadStatus` | `loading` |
| `month` | `DateTime` | `mockMonth` |
| `sources` | `List<Source>` | `[]` |
| `reconciliation` | `BankReconciliation?` | `null` |
| `summaries` | `List<SourceSummary>` | `[]` |
| `recent` | `List<Transaction>` | `[]` |
| `quickAdd` | `List<EntryTemplate>` | `[]` |

Add a helper `String sourceName(String id)` on the state (returns the source name, or the id if missing).

## Cubit

- `load()`: fetches `sources()`, `reconciliation()`, `sourceSummaries(state.month)`, `recentTransactions()`, `quickAddTemplates()` (use `Future.wait` or sequential awaits), then emits `loaded` with all fields.
- `changeMonth(DateTime month)`: emits the new `month` only. Data does not change in this phase.

## Page

`DashboardPage` creates the Cubit with `BlocProvider` (`..load()`), and a private view uses `BlocBuilder`:
- While `status == loading`: centered `CircularProgressIndicator`.
- When loaded: `Column(crossAxisAlignment: start, spacing: 24)` with:
  1. `PageHeader(title: 'Dashboard', subtitle: 'Sample data · balances as on 26 Nov 2026', actions: [MonthSelector(month, onChanged: cubit.changeMonth), AppButton(label: '+ New entry', size: medium, onPressed: () => context.go(AppRoutes.transactions))])`. Build the date in the subtitle from `mockToday` with `AppDates.dayMonthYear`.
  2. `SectionPlaceholder(name: 'Bank reconciliation', height: 80)`
  3. `SectionPlaceholder(name: 'Source balance cards', height: 300)`
  4. `TwoPane(primary: SectionPlaceholder(name: 'Recent entries', height: 360), secondary: SectionPlaceholder(name: 'Quick add', height: 360))` with defaults (flex 2:1, mins 520 and 280).

## Do not

Build any of the sections. Do not hardcode data in the page.

## Verify

- [x] `/dashboard` shows the header with the subtitle "Sample data · balances as on 26 Nov 2026", the month selector and a teal "+ New entry" button.
- [x] Below it: four placeholder boxes (the last two side by side when the window is wide, stacked when narrow).
- [x] "+ New entry" goes to `/transactions`; the month arrows change the label.
- [x] `flutter analyze` is clean.
