# 02: Layout components

**Goal:** the app shell (sidebar + scrolling content area), page header and month selector.

**Prerequisites:** spec 01 done (tokens, `AppDates`).

## Files to create

| File | Class |
|------|-------|
| `lib/app/routes.dart` | `AppRoutes` |
| `lib/core/widgets/app_sidebar.dart` | `AppSidebar` |
| `lib/core/widgets/app_shell.dart` | `AppShell` |
| `lib/core/widgets/page_header.dart` | `PageHeader` |
| `lib/core/widgets/month_selector.dart` | `MonthSelector` |
| `lib/dev/shell_demo.dart` | `ShellDemo` (temporary) |
| `lib/main.dart` | change: home becomes `ShellDemo` |

## AppRoutes

```dart
abstract final class AppRoutes {
  static const dashboard = '/dashboard';
  static const transactions = '/transactions';
  static const monthlyReport = '/reports/monthly';
  static const sourceReport = '/reports/source';
  static const templates = '/templates';
  static const settings = '/settings';
}
```

## AppSidebar

`AppSidebar({required String location, required ValueChanged<String> onNavigate})`. It must not depend on go_router.

- Width `AppSpacing.sidebarWidth` (232), background `AppColors.surface`, a 1px right border `AppColors.cardBorder`, padding 24 vertical and 16 horizontal, full height.
- Top: text "Money Tracker" in `AppTextStyles.brand`, padding `0 12 20 12`.
- Nav items in this order, 4px apart: **Dashboard**, **Transactions**, **Monthly report**, **Source report**, **Accounts report**, **Templates**, **Settings** (routes from `AppRoutes`), each with a 20px outlined icon before the label.
- Optional `collapsed` and `onToggleCollapsed`: a chevron button beside the brand flips between expanded and a `AppSpacing.sidebarRailWidth` (72) icon rail (icons only, `Tooltip` with the label, brand hidden). Width animates over 180ms.
- Below `AppSpacing.mobileBreakpoint` (600) there is no sidebar: `AppShell` shows an `AppBar` (brand title, hamburger) and `AppNavDrawer`, the same items with labels; tapping one closes the drawer then navigates.
- Item: min height 44, padding 12 all round, radius 8, text `navItem`.
  - Active (when `location.startsWith(route)`): background `primaryTint`, text `navItemActive`.
  - Hover (inactive): background `navHover`.
  - Whole row is clickable (`InkWell`), pointer cursor, `Semantics(selected: active, button: true)`.

## AppShell

`AppShell({required String location, required ValueChanged<String> onNavigate, required Widget child})`.

`AppShell` is stateful: it loads and saves the collapsed flag in `SharedPreferences` under `sidebar_collapsed` (default expanded; storage errors are ignored). `PageBody` uses padding `20/16` instead of `32/40` below the breakpoint.

`Scaffold(backgroundColor: pageBg)` with a `Row`: `AppSidebar` on the left (stretch height) and `Expanded` content on the right. The content is a `SingleChildScrollView` with padding `vertical 32, horizontal 40` whose child is `SizedBox(width: double.infinity, child: child)`.

## PageHeader

`PageHeader({required String title, String? subtitle, List<Widget> actions = const [], WrapCrossAlignment crossAlignment = WrapCrossAlignment.center})`.

A `Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: crossAlignment, spacing: 16, runSpacing: 16)` with two children:
- Left: `Column` (start aligned): title as `pageTitle` (wrapped in `Semantics(header: true)`), and if present subtitle as `subtitle` with 4px above.
- Right (only if `actions` is not empty): `Row(spacing: 12)` of the actions.

## MonthSelector

`MonthSelector({required DateTime month, required ValueChanged<DateTime> onChanged})`.

A container with background `surface`, 1px border `controlBorder`, radius 8, horizontal padding 4, containing a `Row` (no extra gap):
- Previous button: 44×44 `IconButton`, `Icons.chevron_left` size 22, tooltip "Previous month", color textPrimary.
- Label `AppDates.monthYear(month)` in `bodyStrong`, horizontal padding 8.
- Next button: same with `Icons.chevron_right`, tooltip "Next month".
- `onChanged` is called with `DateTime(month.year, month.month - 1)` / `DateTime(month.year, month.month + 1)`.

## ShellDemo (temporary)

A private-state demo that renders `AppShell(location: AppRoutes.dashboard, onNavigate: ...)`. `onNavigate` just stores the tapped route in state so the active highlight moves. The child is a `PageHeader(title: 'Dashboard', subtitle: 'Sample data', actions: [MonthSelector(...)])` where the month is kept in state starting at November 2026.

## Do not

Use go_router yet, or add buttons (they arrive in spec 03).

## Verify

- [x] Left sidebar 232px wide with the six items; clicking an item moves the teal-tinted highlight to it; hovering an inactive item shows a grey background.
- [x] Content area has the page background, title "Dashboard" (26px bold), subtitle "Sample data" in grey.
- [x] The month selector shows "November 2026"; the arrows change the label month by month (and roll over years).
- [x] Resizing the window below ~900px wraps the header actions under the title instead of overflowing.
- [x] `flutter analyze` is clean.
