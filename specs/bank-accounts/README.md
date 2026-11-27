# Part 3: bank accounts

New requirement: there can be several bank accounts, and every source belongs to exactly one of them. Bank balances are then entered per account, and the Dashboard compares each account's statement balance with the sources that live in it.

Wireframes: the Dashboard, Settings and Update bank balance boards on the canvas were updated (https://claude.ai/artifact/28BqECf288uLAcZP4rzLBR).

## Prerequisites

Phase B finished (B01 to B10 pass), and Part 1 and 2 before it. Do this **before** you wipe the sample data and enter real figures.

## Order

| # | File | What you will see afterwards |
|---|------|------------------------------|
| BA01 | `BA01-models-and-mock.md` | Bank account models, repository changes, mock data with two accounts, tests |
| BA02 | `BA02-dashboard.md` | Dashboard reconciliation shows a total and a per-account list; source cards show their account |
| BA03 | `BA03-bank-balance-dialog.md` | The dialog asks for the account |
| BA04 | `BA04-settings.md` | Bank accounts card, form, and an account on every source |
| BA05 | `BA05-database.md` | Database migration run in the console (sample data split over two accounts) |
| BA06 | `BA06-supabase-repository.md` | The real repository supports accounts; everything works against Supabase |

Do BA01 to BA04 in **sample mode** (plain `flutter run`). While you do them, Supabase mode shows the error card on the Dashboard and Settings, because the real repository does not know about accounts yet. Do BA05 and BA06 together in one sitting: as soon as the migration has run, the old Dashboard code can no longer read the database.

## How it works

- A **bank account** has a name and can be archived. Archiving hides it from new sources; it is only allowed while it has no active sources.
- Each **source** names one bank account when it is created. Entries need no account of their own: their source decides it.
- **Bank balances** are recorded per account and date. The latest one per account is the current one.
- The Dashboard strip shows the sum of all sources against the sum of the bank balances, and a list underneath with one row per account.
- **Not in this change:** moving a source to another account (editing sources is still "not wired"), moving money between accounts, and account filters on Transactions and the reports.

## Database files in this bundle (`supabase-sql/`)

- `05-bank-accounts.sql` (new): the migration. Existing data moves into one account called "Main account".
- `06-sample-bank-accounts.sql` (new, dev only): splits the sample data into "HDFC Salary" and "SBI Rentals".
- `04-seed.sql` and `99-reset-dev-data.sql` (replace your copies): updated for the new schema. Do not re-run an old 04.

Conventions are the same as in `specs/README.md` and `specs/app-supabase/README.md`.
