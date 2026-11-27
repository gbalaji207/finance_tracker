# BA05: Database migration (Supabase console)

**Goal:** add bank accounts to the database and move the existing data into them.

**Prerequisites:** BA01 to BA04 done and committed. Put the files from this bundle's `supabase-sql/` folder into your repo's `supabase-sql/`, **replacing** your copies of `04-seed.sql` and `99-reset-dev-data.sql`.

**Heads-up:** as soon as `05` has run, the app in Supabase mode cannot read reconciliation until BA06 is done. Do BA06 right after this step.

## Run

SQL Editor, in this order:

1. `supabase-sql/05-bank-accounts.sql`. It creates the `bank_accounts` table (with the same security rule as the others), adds `bank_account_id` to `sources` and `bank_balances`, moves everything into one account called **Main account**, makes the new column mandatory, makes the unique rule "one balance per account per date", and replaces three report functions (`source_summaries`, `current_reconciliation`, and a new `bank_account_usage`). Run it **once**; a second run fails harmlessly with "already exists".
2. **Only if you loaded the sample data (04):** `supabase-sql/06-sample-bank-accounts.sql`. It renames Main account to **HDFC Salary**, adds **SBI Rentals**, moves Aqua 105 and VR to it, and splits the one sample bank balance into 75,600 and 56,800. Do not run it on real data. It stops with a message if the data is not in the expected shape.

If you already wiped the sample data and have real rows instead, skip 06 and rename "Main account" to the real account's name directly in **Table Editor, bank_accounts**, then add further accounts in the app.

## Verify

- [ ] **Table Editor** lists `bank_accounts` with RLS enabled and one policy.
- [ ] After 05 (and 06 for sample data), this returns the rows listed (sources total and bank balance; dates are 26 Nov 2026):
  ```sql
  select name, is_active, sources_total, bank_balance, as_of from public.current_reconciliation();
  ```
  After 05 only: `Main account`, 132400, 132400.
  After 06: `HDFC Salary` 75600 / 75600 and `SBI Rentals` 56800 / 56800.
- [ ] `select name, active_source_count from public.bank_account_usage();` gives HDFC Salary 2 and SBI Rentals 2 (after 06).
- [ ] Monthly figures are unchanged. This must still return income 228000, expense 82600, invested 30000, saved 16000, closing 132400, and each row now has a `bank_account_name`:
  ```sql
  select name, bank_account_name, closing from public.source_summaries('2026-11-01');
  ```
- [ ] The database refuses a source without an account. This must fail with a not-null error:
  ```sql
  insert into public.sources (user_id, name, kind)
  select id, 'x', 'Other' from auth.users limit 1;
  ```
- [ ] Anonymous access is blocked (must fail with "permission denied"):
  ```sql
  begin; set local role anon; select * from public.bank_accounts; rollback;
  ```

## If something goes wrong

`05` is one script: if it stops with an error partway, tell me the message before re-running anything, because some steps may already have applied. Do not run the old `04-seed.sql` after this migration.
