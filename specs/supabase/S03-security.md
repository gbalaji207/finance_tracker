# S03: Security (Row Level Security)

**Goal:** only the signed-in owner can read or change data; anonymous requests get nothing.

**Prerequisites:** S02 done.

## Run

SQL Editor, paste `supabase-sql/02-rls.sql`, Run. It is safe to re-run except for the `create policy` lines, which fail with "already exists" the second time (harmless).

## What it does

- Turns on Row Level Security for all five tables.
- One policy per table: signed-in users (`authenticated`) may select, insert, update and delete **only rows whose `user_id` equals their own id**. Inserts from the app fill `user_id` automatically (it defaults to the signed-in user's id).
- Removes all table access from `anon` (requests without a login) and grants it explicitly to `authenticated`.

## Important: the SQL Editor ignores these rules

The SQL Editor runs as an admin role that bypasses RLS, so "I can see my data in the editor" proves nothing about security. The checks below simulate the real roles. The true end-to-end test is in Phase B, when the app signs in.

## Verify

- [x] **Table Editor**: all five tables now show RLS enabled, with one policy each.
- [x] Anonymous access is blocked. Run this; it must **fail** with "permission denied for table transactions":
  ```sql
  begin;
  set local role anon;
  select count(*) from public.transactions;
  rollback;
  ```
  If the editor leaves the transaction open after the error, run `rollback;` on its own.
- [x] Signed-in access works (and returns 0 rows for now). Replace the id with yours from S01:
  ```sql
  begin;
  set local role authenticated;
  select set_config('request.jwt.claims', '{"sub":"YOUR-USER-ID"}', true);
  select count(*) from public.transactions;
  rollback;
  ```
  Expected: `0`, no error.
