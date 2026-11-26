# 01: Design system

**Goal:** design tokens (colors, text styles, spacing), the app theme, the `TxType` enum, money/date formatters, and a preview page to check them.

**Prerequisites:** spec 00 done.

## Files to create

| File | Contents |
|------|----------|
| `lib/core/theme/app_colors.dart` | `AppColors` constants (below) |
| `lib/core/theme/app_text_styles.dart` | `AppTextStyles` (table below) |
| `lib/core/theme/app_spacing.dart` | `AppSpacing` constants (below) |
| `lib/core/theme/app_theme.dart` | `AppTheme.light()` |
| `lib/core/models/tx_type.dart` | `TxType` enum with label and badge colors |
| `lib/core/utils/money.dart` | `Money` formatter |
| `lib/core/utils/app_dates.dart` | `AppDates` formatter |
| `lib/dev/design_system_preview.dart` | `DesignSystemPreview` page |
| `test/core/money_test.dart` | formatter tests |
| `lib/main.dart` | change: show the preview page with `AppTheme.light()` |

## AppColors

```dart
abstract final class AppColors {
  // Surfaces and lines
  static const pageBg = Color(0xFFF6F6F3);
  static const surface = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE4E4DF);
  static const divider = Color(0xFFEEEEE9);
  static const inputBorder = Color(0xFFC4C4BC);
  static const controlBorder = Color(0xFFD8D8D2);
  static const track = Color(0xFFE9E9E3);
  static const navHover = Color(0xFFEDEDE8);
  // Text
  static const textPrimary = Color(0xFF1F2328);
  static const textSecondary = Color(0xFF5B6168);
  // Brand
  static const primary = Color(0xFF0F766E);
  static const primaryDark = Color(0xFF0B4F49);   // text on tinted backgrounds, links
  static const primaryTint = Color(0xFFE2EFEC);   // selected nav item, selected segment
  // Money and type colors
  static const income = Color(0xFF14532D);        // income amounts, "matches" text
  static const incomeBg = Color(0xFFE3F1E8);
  static const expenseFg = Color(0xFF7A271A);
  static const expenseBg = Color(0xFFF6E6E2);
  static const investmentFg = Color(0xFF1E3A8A);
  static const investmentBg = Color(0xFFE3EBFA);
  static const savingsFg = Color(0xFF6B3F06);
  static const savingsBg = Color(0xFFFAEFD9);
  // Chart
  static const chartIncome = primary;
  static const chartExpense = Color(0xFFE8B04A);
}
```

## AppSpacing

```dart
abstract final class AppSpacing {
  static const double s4 = 4, s6 = 6, s8 = 8, s12 = 12, s14 = 14, s16 = 16,
      s20 = 20, s24 = 24, s32 = 32, s40 = 40;
  static const double radiusCard = 12;     // cards, panels
  static const double radiusControl = 8;   // buttons, inputs, nav items
  static const double radiusBadge = 6;
  static const double sidebarWidth = 232;
  static const double controlHeight = 44;  // inputs, medium buttons
  static const double buttonSmall = 40;
  static const double buttonLarge = 48;
  static const double pageV = 32;          // page padding top/bottom
  static const double pageH = 40;          // page padding left/right
  static const double cardPadding = 20;
}
```

## AppTextStyles

Font is **Inter** through `google_fonts` (`GoogleFonts.inter(...)`). Do not set `height`. Each style is a `static final TextStyle`.

| Name | Size | Weight | Color | Used for |
|------|------|--------|-------|----------|
| `pageTitle` | 26 | 700 | textPrimary | page h1 |
| `brand` | 17 | 700 | textPrimary | sidebar "Money Tracker" |
| `sectionTitle` | 16 | 700 | textPrimary | card headings |
| `cardTitle` | 16 | 600 | textPrimary | source name on cards |
| `body` | 14 | 400 | textPrimary | table cells, inputs |
| `bodyStrong` | 14 | 600 | textPrimary | emphasized cells |
| `bodySecondary` | 14 | 400 | textSecondary | dates, categories |
| `subtitle` | 13 | 400 | textSecondary | page subtitle, footers |
| `rowLabel` | 13 | 400 | textPrimary | key-value labels on cards |
| `rowValue` | 13 | 600 | textPrimary | key-value values |
| `caption` | 12 | 400 | textSecondary | small captions |
| `label` | 12 | 600 | textSecondary | field labels, table headers |
| `captionBold` | 12 | 700 | textPrimary | to-date amount |
| `kpiValue` | 24 | 700 | textPrimary | KPI tiles |
| `balanceValue` | 28 | 700 | textPrimary | source balance |
| `summaryValue` | 20 | 700 | textPrimary | reconciliation values |
| `button` | 14 | 600 | (set by button) | medium/large buttons |
| `buttonSmall` | 13 | 600 | (set by button) | small buttons |
| `link` | 13 | 600 | primaryDark, underline | text links |
| `badge` | 12 | 600 | (set by badge) | type badges |
| `navItem` | 14 | 400 | textPrimary | sidebar inactive |
| `navItemActive` | 14 | 600 | primaryDark | sidebar active |

## AppTheme

`AppTheme.light()` returns `ThemeData`:
- `useMaterial3: true`, `colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(primary: AppColors.primary, surface: AppColors.surface, onSurface: AppColors.textPrimary)`.
- `scaffoldBackgroundColor: AppColors.pageBg`.
- `textTheme: GoogleFonts.interTextTheme().apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary)`.
- `dividerColor: AppColors.divider`.
- `checkboxTheme`: selected fill `AppColors.primary`, check color white, shape rounded 4, unselected side `BorderSide(color: AppColors.inputBorder, width: 1.5)`.
- `snackBarTheme`: `behavior: SnackBarBehavior.floating`.

## TxType (`lib/core/models/tx_type.dart`)

```dart
enum TxType {
  income, expense, investment, savings;

  String get label => switch (this) {
        income => 'Income', expense => 'Expense',
        investment => 'Investment', savings => 'Savings' };
  Color get badgeBg => switch (this) { /* incomeBg, expenseBg, investmentBg, savingsBg */ };
  Color get badgeFg => switch (this) { /* income, expenseFg, investmentFg, savingsFg */ };
}
```
Write the switch bodies using the `AppColors` pairs named above.

## Money (`lib/core/utils/money.dart`)

Indian digit grouping, no decimals, `₹` prefix, real minus sign U+2212.

```dart
abstract final class Money {
  static final NumberFormat _fmt = NumberFormat('#,##,##0', 'en_IN');
  static String _abs(double v) => '₹${_fmt.format(v)}';

  /// ₹1,32,400. Negative: −₹1,000.
  static String plain(double v) => v < 0 ? '−${_abs(-v)}' : _abs(v);

  /// Direction from entry type: income "+₹", others "−₹", zero "₹0".
  static String signed(double v, TxType type) {
    if (v == 0) return _abs(0);
    return type == TxType.income ? '+${_abs(v)}' : '−${_abs(v)}';
  }
}
```

## AppDates (`lib/core/utils/app_dates.dart`)

| Method | Pattern | Example |
|--------|---------|---------|
| `dayMonth(d)` | `dd MMM` | 05 Nov |
| `dayMonthYear(d)` | `d MMM yyyy` | 26 Nov 2026 |
| `monthYear(d)` | `MMMM yyyy` | November 2026 |
| `monthYearShort(d)` | `MMM yyyy` | Nov 2026 |
| `monthShort(d)` | `MMM` | Nov |
| `monthName(d)` | `MMMM` | November |

## Tests (`test/core/money_test.dart`)

- `Money.plain(132400)` is `₹1,32,400`; `Money.plain(15000)` is `₹15,000`; `Money.plain(0)` is `₹0`; `Money.plain(-1000)` is `−₹1,000`.
- `Money.signed(45000, TxType.income)` is `+₹45,000`; `Money.signed(32000, TxType.expense)` is `−₹32,000`; `Money.signed(0, TxType.savings)` is `₹0`.

## Preview page (`DesignSystemPreview`)

A scrollable page (padding 32) with four labelled sections:
1. **Colors:** a `Wrap` of swatches (120×72, radius 8, 1px `cardBorder`) with the constant name and hex under each.
2. **Typography:** every `AppTextStyles` entry rendered with its own name as the sample text.
3. **Type badges:** four chips (one per `TxType`) with padding 4×8, radius `radiusBadge`, `badge` style, `badgeFg` text on `badgeBg`.
4. **Money:** rows showing `Money.plain(132400)`, `Money.signed(45000, TxType.income)`, `Money.signed(32000, TxType.expense)`, `Money.plain(0)`.

`main.dart`: `MaterialApp(theme: AppTheme.light(), home: const DesignSystemPreview(), debugShowCheckedModeBanner: false, title: 'Money Tracker')`.

## Do not

Create any reusable widgets, routes or Cubits yet.

## Verify

- [ ] `flutter analyze` is clean; `flutter test` passes.
- [ ] The page background is warm light grey (#F6F6F3) and text is Inter.
- [ ] All swatches, 22 text styles, 4 badges and the money rows show; `₹1,32,400` uses Indian grouping.
