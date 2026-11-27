-- 02-rls.sql
-- Row Level Security: a signed-in user sees and changes only rows where user_id is their own id.
-- Anonymous (not signed in) requests get nothing.

alter table public.sources         enable row level security;
alter table public.categories      enable row level security;
alter table public.transactions    enable row level security;
alter table public.entry_templates enable row level security;
alter table public.bank_balances   enable row level security;

create policy "owner full access" on public.sources
  for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "owner full access" on public.categories
  for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "owner full access" on public.transactions
  for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "owner full access" on public.entry_templates
  for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "owner full access" on public.bank_balances
  for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- Table privileges: explicit, so it works whatever the project's default grants are.
revoke all on public.sources, public.categories, public.transactions,
              public.entry_templates, public.bank_balances from anon;
grant select, insert, update, delete on public.sources, public.categories, public.transactions,
              public.entry_templates, public.bank_balances to authenticated;
