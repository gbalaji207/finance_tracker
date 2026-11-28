-- 09-loan-source-kind.sql
-- Allow the "Loan" source kind. Safe to re-run.
alter table public.sources drop constraint if exists sources_kind_check;
alter table public.sources add  constraint sources_kind_check
  check (kind in ('Employment', 'Freelance', 'Rental', 'Loan', 'Other'));
