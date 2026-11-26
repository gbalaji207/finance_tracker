# Monthly report 01: Skeleton

**Goal:** the real page structure for the Monthly report with Cubit, header and one placeholder per section.

**Prerequisites:** specs 00 to 06 done.

## Files

| File | Contents |
|------|----------|
| `lib/features/monthly_report/cubit/monthly_report_state.dart` | `MonthlyReportState` |
| `lib/features/monthly_report/cubit/monthly_report_cubit.dart` | `MonthlyReportCubit` |
| `lib/features/monthly_report/view/monthly_report_page.dart` | change: real page |

## State (`Equatable`, README pattern)

| Field | Type | Initial |
|-------|------|---------|
| `status` | `LoadStatus` | `loading` |
| `month` | `DateTime` | `mockMonth` |
| `report` | `MonthlyReport?` | `null` |

## Cubit

- `load()`: `monthlyReport(state.month)` then emit `loaded`.
- `changeMonth(DateTime)`: updates `month` only (data stays the same in this phase).

## Page

`MonthlyReportPage` creates the Cubit (`..load()`); loading shows a centered `CircularProgressIndicator`; otherwise `Column(crossAxisAlignment: start, spacing: 24)`:
1. `PageHeader(title: 'Monthly report', subtitle: 'Sample data · all sources together, then split by source', actions: [MonthSelector(...), AppButton(label: 'Export CSV', variant: secondary, onPressed: show SnackBar 'Not wired yet (sample data)')])`.
2. `SectionPlaceholder(name: 'Totals', height: 90)`
3. `SectionPlaceholder(name: 'By source', height: 300)`
4. `SectionPlaceholder(name: 'Expenses by category', height: 260)`

## Do not

Build the sections.

## Verify

- [x] `/reports/monthly` shows the header, month selector (changes the label) and an "Export CSV" button (SnackBar on click).
- [x] Three placeholder boxes below. `flutter analyze` is clean.
