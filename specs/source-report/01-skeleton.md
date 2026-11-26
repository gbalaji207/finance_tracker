# Source report 01: Skeleton

**Goal:** the real page structure for the Source-wise report with Cubit, header (with source and period pickers) and one placeholder per section.

**Prerequisites:** specs 00 to 06 done.

## Files

| File | Contents |
|------|----------|
| `lib/features/source_report/cubit/source_report_state.dart` | `SourceReportState` |
| `lib/features/source_report/cubit/source_report_cubit.dart` | `SourceReportCubit` |
| `lib/features/source_report/view/source_report_page.dart` | change: real page |

## State (`Equatable`, README pattern)

| Field | Type | Initial |
|-------|------|---------|
| `status` | `LoadStatus` | `loading` |
| `selectedSourceId` | `String` | `aqua-105` |
| `report` | `SourceReport?` | `null` |

## Cubit

- `load()`: `sourceReport(state.selectedSourceId)` then emit `loaded`.
- No other methods in this phase. The mock always returns the Aqua 105 report.

## Page

`SourceReportPage` creates the Cubit (`..load()`); loading shows a centered `CircularProgressIndicator`; otherwise `Column(crossAxisAlignment: start, spacing: 24)`:
1. `PageHeader(title: 'Source-wise report', subtitle: 'Sample data · one source over time', crossAlignment: WrapCrossAlignment.end, actions: [...])` where the actions are two dropdowns:
   - `SizedBox(width: 180, child: AppDropdown<String>(label: 'Source', items: [AppDropdownItem('aqua-105', 'Aqua 105')], value: 'aqua-105'))`
   - `SizedBox(width: 160, child: AppDropdown<String>(label: 'Period', items: [AppDropdownItem('6m', 'Last 6 months')], value: '6m'))`

   Each has a single option, as in the wireframe; `onChanged` does nothing.
2. `SectionPlaceholder(name: 'Summary', height: 90)`
3. `SectionPlaceholder(name: 'Income vs spend chart', height: 300)`
4. `SectionPlaceholder(name: 'Month by month', height: 320)`

## Do not

Build the sections or add more sources to the dropdown.

## Verify

- [x] `/reports/source` shows the header with two labelled dropdowns aligned to the bottom of the title block.
- [x] Three placeholder boxes below. `flutter analyze` is clean.
