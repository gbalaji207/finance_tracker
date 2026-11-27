# S05: Sample data

**Goal:** development data that makes the real reports show the same numbers as the wireframes.

**Prerequisites:** S01 (your user exists) to S04 done. **Dev project only.**

## Run

SQL Editor, paste `supabase-sql/04-seed.sql`, Run. It refuses to run if no user exists or if data is already present, so a second run does nothing harmful. To start over: run `99-reset-dev-data.sql` (empties the five tables, keeps your user and all functions), then `04-seed.sql` again.

## What it inserts

- 5 sources: Salary, Side hustle, Aqua 105, VR, and an archived Old freelance.
- 7 categories: Housing, Groceries, Utilities, Property upkeep, Other, Mutual funds, Fixed deposit.
- 56 entries: Aqua 105 from June 2026, everything else from October 2026 (17 in October, 27 in November, so the Transactions list has 3 pages and "copy last month" has real entries).
- 6 templates (4 marked quick-add) and a bank balance of ₹1,32,400 as on 26 Nov 2026.

## Verify

The SQL Editor runs as admin, so these see all data.

- [ ] Monthly figures:
  ```sql
  select name, month_opening, income, expense, invested, saved, closing
  from public.source_summaries('2026-11-01');
  ```
  | name | month_opening | income | expense | invested | saved | closing |
  |------|--------------:|-------:|--------:|---------:|------:|--------:|
  | Salary | 15000 | 120000 | 55800 | 20000 | 6000 | 53200 |
  | Side hustle | 6000 | 35000 | 8600 | 10000 | 0 | 22400 |
  | Aqua 105 | 8000 | 45000 | 12000 | 0 | 10000 | 31000 |
  | VR | 4000 | 28000 | 6200 | 0 | 0 | 25800 |

  Column sums: income 228000, expense 82600, invested 30000, saved 16000, closing 132400.
- [ ] Categories: `select * from public.expense_by_category('2026-11-01');` returns Housing 32000, Groceries 15000, Property upkeep 14600, Other 12000, Utilities 9000.
- [ ] Reconciliation: `select * from public.current_reconciliation();` returns 132400, 132400, 2026-11-26.
- [ ] Aqua 105 history:
  ```sql
  select * from public.source_month_rows(
    (select id from public.sources where name = 'Aqua 105'), '2026-11-26', 6);
  ```
  Closing, newest first: 31000, 8000, 13500, 9500, 8000, 2000 (November back to June); incomes all 45000.
- [ ] `select count(*) from public.transactions;` is 56.
- [ ] Row Level Security with data. Replace the id with yours; it must return **56** for you and **0** for a made-up id:
  ```sql
  begin;
  set local role authenticated;
  select set_config('request.jwt.claims', '{"sub":"YOUR-USER-ID"}', true);
  select count(*) from public.transactions;
  rollback;

  begin;
  set local role authenticated;
  select set_config('request.jwt.claims', '{"sub":"22222222-2222-2222-2222-222222222222"}', true);
  select count(*) from public.transactions;
  rollback;
  ```
- [ ] Rules reject bad data. This must fail with a check-constraint error (an expense without a category):
  ```sql
  insert into public.transactions (user_id, tx_date, type, source_id, amount)
  select id, '2026-11-01', 'expense', (select id from public.sources limit 1), 5
  from auth.users limit 1;
  ```

## Known differences from the mock data

Same as in the README: Salary, Side hustle and VR "to date" invested/saved are 76000, 30000 and 24000 (Aqua 105 is 180000), the November list has 27 entries, and Aqua 105's opening balance is ₹6,000 on 1 Jun 2026. Everything on the Dashboard, Monthly report and Source report that the wireframes show for November matches.
