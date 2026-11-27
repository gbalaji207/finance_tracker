-- 99-reset-dev-data.sql
-- DEV ONLY. Deletes all rows from the five tables (keeps the tables, policies, functions and your login user).
-- Use it before re-running 04-seed.sql. Do not run this on your real project once it holds real data.

truncate table public.transactions, public.entry_templates, public.bank_balances,
               public.categories, public.sources;
