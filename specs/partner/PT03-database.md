# PT03: Database migration (Supabase console)

**Goal:** let the database store Partner categories and entries, and report the partner amount.

**Prerequisites:** PT01 and PT02 done and committed. Put `07-partner-transfers.sql` from this bundle's `supabase-sql/` folder into your repo's `supabase-sql/`. The earlier scripts are not changed.

**Heads-up:** the migration is safe for the app as it is now (it only adds a column and allows a new value). Do not enter a Partner category or entry in Supabase mode until PT04 is done.

## Run

SQL Editor: paste and run `supabase-sql/07-partner-transfers.sql` **once**. It:

1. Widens the allowed values: `categories.kind`, `transactions.type` and `entry_templates.type` also accept `partner`. The existing rule that an entry's category kind must equal its type, and that only income has no category, applies to Partner unchanged.
2. Replaces `source_summaries(date)`: a new `partner` column, and `closing` now subtracts it. A source also stays listed for a month if it only had a partner entry.
3. Replaces `source_month_rows(uuid, date, int)`: a new `partner` column between `invested_saved` and `closing`, and `closing` subtracts it.
4. Leaves `source_balance`, `current_reconciliation` and `expense_by_category` alone: the first two already subtract every non-income type, and Partner is deliberately not an expense.

A second run fails harmlessly on the constraint step or runs the same replacements again; if it stops partway, tell me the message before re-running.

## Verify

- [ ] Existing figures are unchanged. This still returns income 228000 (sample data) and the same closing per source as before:
  ```sql
  select name, income, expense, invested, saved, partner, closing from public.source_summaries('2026-11-01');
  ```
  `partner` is 0 for every row.
- [ ] A Partner entry works and lowers the balance. Run in one go; the last select must show a `partner` of 1000 and a closing 1000 lower than before, then everything is rolled back:
  ```sql
  begin;
  insert into public.categories (user_id, name, kind)
    select id, 'tmp partner', 'partner' from auth.users limit 1;
  insert into public.transactions (user_id, tx_date, type, source_id, category_id, amount)
    select c.user_id, '2026-11-10', 'partner', (select id from public.sources order by created_at limit 1), c.id, 1000
    from public.categories c where c.name = 'tmp partner';
  select name, expense, partner, closing from public.source_summaries('2026-11-01') order by name;
  rollback;
  ```
- [ ] The category rule still holds: this must fail with a foreign key error (an expense entry cannot use a Partner category):
  ```sql
  begin;
  insert into public.categories (user_id, name, kind) select id, 'tmp partner', 'partner' from auth.users limit 1;
  insert into public.transactions (user_id, tx_date, type, source_id, category_id, amount)
    select c.user_id, '2026-11-10', 'expense', (select id from public.sources limit 1), c.id, 10
    from public.categories c where c.name = 'tmp partner';
  rollback;
  ```
- [ ] `select * from public.source_month_rows((select id from public.sources limit 1)) limit 1;` returns a `partner` column.
- [ ] Anonymous access is still blocked (must fail with "permission denied"):
  ```sql
  begin; set local role anon; select * from public.source_summaries('2026-11-01'); rollback;
  ```

## If something goes wrong

Do not run an older script after this one. If `source_summaries` or `source_month_rows` is left missing, the app's Dashboard and reports fail; tell me the error before re-running.
