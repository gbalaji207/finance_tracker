# AR03: Database migration (Supabase console)

**Goal:** two functions that return the ledger rows with a running Closing, and the opening balance and totals, filtered by bank account, source and type.

**Prerequisites:** AR01 and AR02 done and committed. Put `08-account-ledger.sql` from this bundle's `supabase-sql/` folder into your repo's `supabase-sql/`. The earlier scripts are not changed.

**Heads-up:** the migration only adds functions, so the app as it is keeps working. The Accounts report page shows its error card in Supabase mode until AR04 is done.

## Run

SQL Editor: paste and run `supabase-sql/08-account-ledger.sql`. It is **safe to run again**: it drops the two functions first (including an earlier version that had no bank account filter) and creates them again.

- `account_ledger(p_from, p_to, p_bank_account, p_source, p_type, p_limit, p_offset)`: one page of entries, newest first, each with `closing`. The running total is computed oldest to newest over **all** the entries that match the filters, before the page is cut, so a later page continues correctly.
- `account_ledger_summary(p_from, p_to, p_bank_account, p_source, p_type)`: one row with `opening_balance`, `total_credit`, `total_debit` and `entry_count`.

`p_bank_account` limits the report to the sources of that bank account; `p_source` then picks one of them. A source outside the chosen account matches nothing.

`opening_balance` is the sum, over the chosen sources opened by the end of the range, of the source's opening balance plus every entry dated from its opening date up to the day before `p_from`. It does not depend on `p_type`. It follows the same rule as the Monthly report's month opening.

## Verify

- [ ] With the sample data, this returns Opening 33000 for November 2026 and the credit and debit totals of that month's entries (the totals equal the Monthly report's income, and expense + invested + saved + Jillu):
  ```sql
  select * from public.account_ledger_summary('2026-11-01', '2026-11-30');
  ```
- [ ] Each bank account on its own, and the two add up to the whole (their opening balances, credits and debits sum to the figures above):
  ```sql
  select a.name, s.*
  from public.bank_accounts a
  cross join lateral public.account_ledger_summary('2026-11-01', '2026-11-30', a.id) s
  order by a.created_at;
  ```
  With the sample data: HDFC Salary opening 21000, SBI Rentals 12000.
- [ ] The last (newest) row's `closing` equals the summary's `opening_balance + total_credit - total_debit`:
  ```sql
  select entry_date, description, entry_type, amount, closing
  from public.account_ledger('2026-11-01', '2026-11-30', null, null, null, 5, 0);
  ```
- [ ] A later page continues the running total:
  ```sql
  select entry_date, description, amount, closing
  from public.account_ledger('2026-11-01', '2026-11-30', null, null, null, 5, 5);
  ```
- [ ] Filtering by type changes the running total but not the opening balance:
  ```sql
  select * from public.account_ledger_summary('2026-11-01', '2026-11-30', null, null, 'income');
  ```
- [ ] A source that is not in the chosen account matches nothing (0 entries and an opening balance of 0):
  ```sql
  select * from public.account_ledger_summary(
    '2026-11-01', '2026-11-30',
    (select bank_account_id from public.sources order by created_at limit 1),
    (select id from public.sources s2
       where s2.bank_account_id <> (select bank_account_id from public.sources order by created_at limit 1)
       limit 1));
  ```
- [ ] Anonymous access is blocked (must fail with "permission denied"):
  ```sql
  begin; set local role anon; select * from public.account_ledger_summary('2026-11-01', '2026-11-30'); rollback;
  ```

## If something goes wrong

Tell me the message before running anything else. The script only touches these two functions.
