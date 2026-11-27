# S02: Schema

**Goal:** the five tables the app stores data in.

**Prerequisites:** S01 done.

## Run

SQL Editor, paste `supabase-sql/01-schema.sql`, Run. It only creates, so run it **once** on an empty project. If it fails halfway, a re-run will complain that tables exist; in that case run `drop table if exists public.bank_balances, public.entry_templates, public.transactions, public.categories, public.sources cascade;` first, then the script again.

## What it creates

| Table | Holds | Notes |
|-------|-------|-------|
| `sources` | Salary, Side hustle, each rental property | `kind` is Employment, Freelance, Rental or Other; `opening_balance` on `opening_date`; `is_active` false means archived |
| `categories` | Housing, Groceries, Mutual funds, ... | `kind` is expense, investment or savings |
| `transactions` | Every entry | `type` is income, expense, investment or savings; `amount` always positive |
| `entry_templates` | Recurring entry templates | `amount` may be empty; `quick_add` marks the Dashboard chips; `sort_order` orders them |
| `bank_balances` | Bank statement balances | one row per date; the latest is the current one |

Rules enforced by the database (the app does not have to re-check them, but should show friendly messages later):

- Names are not blank and are unique per user.
- `amount` is above zero.
- Income entries have no category; every other type has one, and its kind must equal the entry type.
- A source or category with entries cannot be deleted (archive it instead). Deleting a template is fine.

## Verify

- [x] **Table Editor** lists the five tables. They show a warning that RLS is not enabled; S03 fixes that.
- [x] Run this query; it returns 5 rows:
  ```sql
  select table_name from information_schema.tables
  where table_schema = 'public' order by 1;
  ```
- [x] In **Table Editor**, `transactions` has the columns `id, user_id, tx_date, type, source_id, category_id, amount, description, created_at`.
