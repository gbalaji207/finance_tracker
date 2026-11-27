# B01: Supabase setup and the sample/real switch

**Goal:** add the Supabase package, read the URL and key at run time, switch the app between sample and real data with one flag, and add a dev page that shows the connection state. No real data is read yet.

**Prerequisites:** Phase A done; Part 2 done.

## Steps

1. `flutter pub add supabase_flutter`.
2. Create `env/dev.example.json` (committed):
   ```json
   {
     "USE_SUPABASE": true,
     "SUPABASE_URL": "https://YOUR-PROJECT.supabase.co",
     "SUPABASE_ANON_KEY": "your-publishable-key"
   }
   ```
   Copy it to `env/dev.json` and fill in your real values from S01. Add these lines to `.gitignore`: `env/*.json` and `!env/*.example.json`.

## Files

| File | Change |
|------|--------|
| `lib/core/config/app_config.dart` | new: `AppConfig` |
| `lib/core/data/app_clock.dart` | new: `appToday()`, `appMonth()` |
| `lib/core/utils/sql_date.dart` | new: `sqlDate()` |
| `lib/dev/supabase_check_page.dart` | new: `SupabaseCheckPage` |
| `lib/main.dart` | initialise Supabase when enabled |
| `lib/app/router.dart` | debug route `/dev/supabase` |
| pages and cubits that use `mockToday` or `mockMonth` | use the clock helpers |
| the six page subtitles | real subtitles in Supabase mode |

## AppConfig

```dart
abstract final class AppConfig {
  static const useSupabase = bool.fromEnvironment('USE_SUPABASE');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Adds the sample-mode suffix to a confirmation message.
  static String note(String message) =>
      useSupabase ? message : '$message (sample data, nothing is stored yet)';
}
```

## main.dart

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  if (AppConfig.useSupabase) {
    if (!AppConfig.isConfigured) {
      runApp(const _MissingConfigApp());   // plain MaterialApp with a centered message
      return;
    }
    await Supabase.initialize(url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonKey);
  }
  runApp(const App());
}
```
`_MissingConfigApp` shows: `Supabase is switched on but SUPABASE_URL or SUPABASE_ANON_KEY is missing. Run with --dart-define-from-file=env/dev.json.`

## Clock and date helpers

`app_clock.dart`:
```dart
DateTime appToday() {                       // date only, no time part
  if (!AppConfig.useSupabase) return mockToday;
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}
DateTime appMonth() { final t = appToday(); return DateTime(t.year, t.month); }
```
`sql_date.dart`: `String sqlDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);`

Search `lib/` for `mockToday` and `mockMonth` and replace every use **outside** `mock_clock.dart` and `mock_finance_repository.dart` with `appToday()` / `appMonth()` (dashboard state and subtitle, transactions state, monthly report state, add-entry cubit default date, templates cubit).

## Subtitles

Where a page subtitle starts with "Sample data", show this instead when `AppConfig.useSupabase`:

| Page | Supabase-mode subtitle |
|------|------------------------|
| Dashboard | `Balances as on ${AppDates.dayMonthYear(appToday())}` |
| Transactions | `Your entries` |
| Monthly report | `All sources together, then split by source` |
| Source report | `One source over time` |
| Templates | `Nothing is created automatically; these only pre-fill the entry form` |
| Settings | `Sources, categories and your account` |

## Dev check page (debug only)

Route `/dev/supabase` next to the other dev routes (outside the shell, `kDebugMode` only). `SupabaseCheckPage` shows lines of text:
- `Mode: Supabase` or `Mode: Sample data`.
- When Supabase is on: `URL host: ${Uri.parse(AppConfig.supabaseUrl).host}` and `Session: ${email or 'none'}` from `Supabase.instance.client.auth.currentSession?.user.email`.

## Do not

Read or write any table. Add a login screen change (B02). Print the key anywhere.

## Verify

- [x] `flutter analyze` is clean; `flutter run -d chrome --web-port=5000` (no defines) behaves exactly as before.
- [x] With `--dart-define-from-file=env/dev.json`, `/dev/supabase` shows `Mode: Supabase`, your project host and `Session: none`.
- [x] Running with `--dart-define=USE_SUPABASE=true` alone shows the missing-config message.
- [x] `git status` does not list `env/dev.json`.
