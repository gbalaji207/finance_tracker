# 06: Routing and placeholder pages

**Goal:** real navigation between the six pages (each a placeholder), the app root with the repository provided, and a reusable section placeholder used by later page skeletons.

**Prerequisites:** specs 01 to 05 done.

## Files to create or change

| File | Contents |
|------|----------|
| `lib/core/widgets/section_placeholder.dart` | `SectionPlaceholder` |
| `lib/features/dashboard/view/dashboard_page.dart` | `DashboardPage` (placeholder) |
| `lib/features/transactions/view/transactions_page.dart` | `TransactionsPage` (placeholder) |
| `lib/features/monthly_report/view/monthly_report_page.dart` | `MonthlyReportPage` (placeholder) |
| `lib/features/source_report/view/source_report_page.dart` | `SourceReportPage` (placeholder) |
| `lib/features/templates/view/templates_page.dart` | `TemplatesPage` (placeholder) |
| `lib/features/settings/view/settings_page.dart` | `SettingsPage` (stays a placeholder after this spec) |
| `lib/app/router.dart` | `createRouter()` |
| `lib/app/app.dart` | `App` |
| `lib/main.dart` | change: call `usePathUrlStrategy()` then `runApp(const App())` |
| `lib/dev/shell_demo.dart` | delete (no longer needed) |

Keep `design_system_preview.dart` and `component_gallery.dart`; they become debug-only routes.

## SectionPlaceholder

`SectionPlaceholder({required String name, double height = 120})`: a box with height `height`, full width, background `surface`, 1px border `inputBorder`, radius 12, text `"$name (placeholder)"` centered in `bodySecondary`.

## Placeholder pages

Each page is a `StatelessWidget` returning a `Column(crossAxisAlignment: start, spacing: 24)` with a `PageHeader` and one `SectionPlaceholder(name: 'Page content')`.

| Page | Title | Subtitle |
|------|-------|----------|
| `DashboardPage` | Dashboard | Sample data |
| `TransactionsPage` | Transactions | Sample data |
| `MonthlyReportPage` | Monthly report | Sample data |
| `SourceReportPage` | Source-wise report | Sample data |
| `TemplatesPage` | Templates and copy last month | Sample data |
| `SettingsPage` | Settings | Not designed yet |

## Router (`createRouter()` returns a `GoRouter`)

- `initialLocation: AppRoutes.dashboard`; a redirect sends `/` to `/dashboard`.
- A `ShellRoute` whose builder returns `AppShell(location: state.uri.path, onNavigate: (path) => context.go(path), child: child)`. Inside it, one `GoRoute` per `AppRoutes` path, using `NoTransitionPage` so switching pages does not animate.
- Outside the shell, only when `kDebugMode`: `/dev/design-system` (`DesignSystemPreview`) and `/dev/gallery` (`ComponentGallery`), each wrapped in a `Scaffold`.
- `errorBuilder`: a centered text "Page not found" with an `AppTextLink('Go to dashboard')`.

## App (`lib/app/app.dart`)

```dart
class App extends StatefulWidget ...   // create the router once, in initState
// build:
RepositoryProvider<FinanceRepository>(
  create: (_) => MockFinanceRepository(),
  child: MaterialApp.router(
    title: 'Money Tracker',
    theme: AppTheme.light(),
    routerConfig: _router,
    debugShowCheckedModeBanner: false,
  ),
)
```

`main.dart` imports `package:flutter_web_plugins/url_strategy.dart` and calls `usePathUrlStrategy()` before `runApp` so URLs have no `#`.

## Do not

Build any real page content or Cubits yet.

## Verify

- [x] App opens on `/dashboard` with the sidebar; clicking each item changes the URL (e.g. `/reports/monthly`) and the highlighted item.
- [x] Reloading the browser on `/templates` stays on Templates.
- [x] Each page shows its title, subtitle and one placeholder box.
- [x] `/dev/gallery` and `/dev/design-system` open without the sidebar (debug mode).
- [x] The browser back button works between pages. `flutter analyze` is clean.
