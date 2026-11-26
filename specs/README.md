# Money Tracker: Flutter specs for Claude Code

Desktop-first Flutter web app with hardcoded data and Cubit for state. Each file in this folder is one self-contained task. Run one, check it in the browser, commit, then move to the next.

## How to run a spec

1. Copy this `specs/` folder into the project root (spec 00 creates the project).
2. Open Claude Code in the project and paste:
   > Read specs/README.md, then implement specs/<file>.md exactly. Do nothing beyond that file. When done, run `flutter analyze` (and `flutter test` if the spec adds tests) and tell me what to check in the browser.
3. Run `flutter run -d chrome --web-port=5000` and tick the **Verify** list at the bottom of the spec.
4. Commit (`git commit -am "spec 03: inputs"`), then go to the next file.

If a Verify item fails, fix it before moving on. Later specs assume earlier ones are exactly as written.

## Order

| # | File | What you will see afterwards |
|---|------|------------------------------|
| 00 | `00-setup.md` | Blank app showing "Money Tracker", folders and packages in place |
| 01 | `01-design-system.md` | A preview page with colors, text styles, badges, money formats |
| 02 | `02-components-layout.md` | Sidebar + page shell + page header + month selector |
| 03 | `03-components-inputs.md` | Component gallery: buttons, fields, dropdowns, selector, checkbox |
| 04 | `04-components-display.md` | Gallery additions: cards, badges, KPI tiles, table, bars, layouts |
| 05 | `05-models-and-mock-data.md` | Models, repository interface, mock data, unit tests passing |
| 06 | `06-routing-placeholders.md` | Real navigation between six placeholder pages |
| | `dashboard/01…05` | Dashboard page, skeleton first, then one section per file |
| | `transactions/01…03` | Transactions page: skeleton, list with filters, add-entry panel |
| | `monthly-report/01…04` | Monthly report: skeleton, KPIs, by-source table, categories |
| | `source-report/01…04` | Source report: skeleton, summary, bar chart, month table |
| | `templates/01…04` | Templates page: skeleton, list, new-template form, copy last month |

## Conventions (apply to every spec)

- Flutter 3.27 or newer (uses `Column(spacing:)`), Dart 3.
- Packages are only: `flutter_bloc`, `equatable`, `go_router`, `google_fonts`, `intl`, `flutter_web_plugins` (sdk), `flutter_lints`. Do not add others.
- State is Cubit with Equatable states, following the pattern below.
- No colors, font sizes or spacings written inline in widgets. Use `AppColors`, `AppTextStyles` and `AppSpacing` (created in spec 01).
- Data comes only through `FinanceRepository`. Widgets never import mock data directly.
- Section widgets are presentational: they take data and callbacks as constructor parameters. Pages read the Cubit and pass values down.
- One public widget per file; file name is the snake_case of the class name.
- Use package imports (`package:finance_tracker/...`), not relative imports.
- Do not run ahead and do not refactor files from earlier specs unless the current spec says so.
- Hardcoded phase limits: no persistence, no validation, filters and pagination are visual only, and the month selector changes its label while the data stays the same.
- Buttons that have no behavior yet show a SnackBar: `Not wired yet (sample data)`.

## Cubit pattern

```dart
enum LoadStatus { loading, loaded }

class DashboardState extends Equatable {
  const DashboardState({this.status = LoadStatus.loading /* , data fields */});
  final LoadStatus status;
  DashboardState copyWith({LoadStatus? status /* , ... */}) =>
      DashboardState(status: status ?? this.status);
  @override
  List<Object?> get props => [status];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repo) : super(const DashboardState());
  final FinanceRepository _repo;

  Future<void> load() async {
    final data = await _repo.something();
    emit(state.copyWith(status: LoadStatus.loaded /* , ... */));
  }
}
```

Pages create their Cubit with `BlocProvider(create: (c) => XCubit(c.read<FinanceRepository>())..load(), child: ...)`.

## Visual reference

The wireframes are at https://claude.ai/artifact/28BqECf288uLAcZP4rzLBR. Every spec contains the measurements it needs, so the canvas is only for side-by-side comparison. Where a spec and the canvas differ, the spec wins.

## Out of scope for now

Supabase, auth, the Settings screen content, real filtering, search and pagination, and polish below about 900px width (just avoid ugly overflow).
