# Supabase, Phase A: database (console only)

Everything here is done in the **Supabase web console**: no CLI, no Docker. You paste each SQL file into the **SQL Editor**, run it, and check the result. The Flutter app is not touched in this phase.

## Order

| Step | File | Result |
|------|------|--------|
| S01 | `S01-project-setup.md` | A Supabase project, sign-ups off, your one login user, the URL and key noted down |
| S02 | `S02-schema.md` + `supabase-sql/01-schema.sql` | Five tables with the integrity rules |
| S03 | `S03-security.md` + `supabase-sql/02-rls.sql` | Row Level Security on, anonymous access blocked |
| S04 | `S04-reports.md` + `supabase-sql/03-reports.sql` | Report functions the app will call |
| S05 | `S05-seed-data.md` + `supabase-sql/04-seed.sql` | Sample data that reproduces the wireframe numbers |

Keep the `supabase-sql/` folder in your repo. The scripts are your database history. If you change the database later, add a new numbered file instead of editing an old one.

Do the steps on a **dev project** first. `99-reset-dev-data.sql` wipes the data, so never run it on the project that will hold your real figures. Make a second project for real use later and run 01 to 03 there (not 04).

## How to run a script

1. Dashboard, **SQL Editor**, **New query**.
2. Paste the whole file, click **Run**.
3. A green "Success. No rows returned" is normal for these scripts. A red error stops that script; fix the cause and re-run only if the script is safe to re-run (see each step).

## Decisions behind the design

- **One user, still `user_id` on every row.** It costs nothing and makes the security rule simple and strict: you only ever see rows with your own id. Sign-ups are switched off, so nobody else can create an account.
- **Money is `numeric(14,2)`** in the database; the Dart models keep `double`.
- **Entry rules live in the database:** amount above zero; income has no category; other types must have a category whose kind matches the type (an expense cannot use "Mutual funds").
- **Reports are SQL functions** (`source_summaries`, `expense_by_category`, `source_month_rows`, `source_balance`, `current_reconciliation`, `category_usage`). The app asks for finished numbers instead of adding up thousands of rows itself.
- **`opening_date` on each source.** A source's balance is `opening_balance` plus its entries dated on or after `opening_date`. This lets you start tracking mid-year without back-filling history.
- **Archiving, not deleting:** `is_active = false` hides a source or category from new entries; its history stays. Foreign keys block deleting anything that has entries.
- Listing entries (filters, search, paging) is plain table queries from the app, not functions. That comes in Phase B.

## What the app will need to change later (Phase B, not now)

- `Source` gets an `openingDate`, and the dashboard "opening" figure becomes the **month opening** returned by `source_summaries` (in the mock they were the same number).
- Seed values differ from the mock in two places: the "to date" invested/saved figures (Salary 76,000, Side hustle 30,000, VR 24,000; Aqua 105 stays 180,000) and the November entry count (27 entries, 3 pages, instead of 38).
- Aqua 105's opening balance in the seed is ₹6,000 on 1 Jun 2026 (its November opening is still ₹8,000). That is the only way its six-month history adds up.

## Tested how

The four scripts were run in order against a local Postgres with Supabase's `auth.uid()` and roles stubbed. Every figure below came out as listed, and the constraint, anonymous-access and other-user checks behaved as described. They have not yet been run on a real Supabase project, so S01 to S05 each end with a check you run there.
