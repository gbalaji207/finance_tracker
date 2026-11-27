# Supabase, Phase B: connect the Flutter app

Phase A built the database. Phase B makes the app read and write it, one small spec at a time, same working style as before: give Claude Code one file, run it, tick the Verify list, commit.

## Prerequisites

- Phase A done: S01 to S05 all pass, your dev project holds the sample data.
- Part 2 of the UI specs done (07, 08, login, settings, edit entry, delete dialog, bank balance dialog). Phase B edits those files.
- Your Supabase URL and publishable key from S01.

## Order

| # | File | What you will see afterwards |
|---|------|------------------------------|
| B01 | `B01-setup.md` | Supabase package, run-time config, a switch between sample and real data, a dev check page |
| B02 | `B02-auth.md` | Real login: sign in, stay signed in on reload, sign out |
| B03 | `B03-error-states.md` | Every page shows a "Try again" card instead of hanging when loading fails |
| B04 | `B04-reference-data.md` | Settings lists (real sources, categories, usage counts) and the Templates list come from the database |
| B05 | `B05-dashboard.md` | Dashboard from the database, real month selector |
| B06 | `B06-reports.md` | Monthly report and Source report from the database |
| B07 | `B07-transactions-list.md` | Real filters, search and paging on Transactions |
| B08 | `B08-entry-writes.md` | Add, edit and delete entries for real |
| B09 | `B09-templates-and-copy.md` | New templates, "Use" fills the form, copy last month really copies |
| B10 | `B10-bank-balance-and-settings.md` | Update bank balance, add and archive sources and categories |

Hosting the finished app (a place to open it from any browser) is a separate step after B10.

## How the two modes work

- **Sample mode (default):** `flutter run -d chrome --web-port=5000` exactly as before. Mock data, no login, nothing stored.
- **Supabase mode:** `flutter run -d chrome --web-port=5000 --dart-define-from-file=env/dev.json`. Login required, real data.

Every spec must keep sample mode working. After each spec, tick the Verify list in Supabase mode and glance at the same page in sample mode to be sure nothing broke.

## Conventions (in addition to the main README)

- The only new package is `supabase_flutter` (B01). Do not add others (no mocking packages: write small hand-made fakes in tests).
- Widgets and cubits still talk only to `FinanceRepository` (and `AuthRepository` in B02). Only files under `lib/core/data/supabase/` may import `supabase_flutter`, with two exceptions: `main.dart` (initialisation) and `lib/core/utils/error_message.dart` (error types).
- Dates sent to the database are `yyyy-MM-dd` strings built with `sqlDate()`. Never use `toIso8601String()` for a date (time zones shift it).
- Money from the database arrives as a JSON number or string; always convert with the shared helper, then keep it as `double`.
- Messages that confirm a save use `AppConfig.note('...')`, which adds "(sample data, nothing is stored yet)" in sample mode.
- Never commit `env/dev.json`, keys or passwords.

## Still "Not wired yet" after Phase B

Editing a source, category or template, Change password, Forgot password, Export CSV, and the Period dropdown on the Source report. They stay as they are, and each shows the usual SnackBar.

## Ids

Sample data uses readable ids (`salary`, `aqua-105`); the database uses uuids. No code may rely on a specific id value. Where a spec says "first source" it means the first active one in list order.

## Not tested against a live project

The SQL behind this (Phase A) was tested on a local Postgres. These Flutter specs depend on the exact API of the `supabase_flutter` version you install. Where a spec names a method (for example the row-count option), Claude Code should check the installed package and adapt if the signature differs, without changing the behaviour described.
