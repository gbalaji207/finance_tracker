-- 05-bank-accounts.sql
-- Adds bank accounts. Every source belongs to one bank account, and bank balances are kept per account.
-- Run once, after 01 to 03 (and 04 if you loaded the sample data). Existing data is moved into one
-- account called "Main account", so nothing is lost; rename or split it later in the app.

-- 1. The new table, with the same security rule as the others.
create table public.bank_accounts (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name       text not null check (length(trim(name)) > 0),
  is_active  boolean not null default true,        -- false = archived
  created_at timestamptz not null default now(),
  unique (user_id, name)
);

alter table public.bank_accounts enable row level security;

create policy "owner full access" on public.bank_accounts
  for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

revoke all on public.bank_accounts from anon;
grant select, insert, update, delete on public.bank_accounts to authenticated;

-- 2. Link sources and bank balances to an account (nullable until the backfill below has run).
alter table public.sources
  add column bank_account_id uuid references public.bank_accounts (id) on delete restrict;
alter table public.bank_balances
  add column bank_account_id uuid references public.bank_accounts (id) on delete restrict;

-- 3. Backfill: one "Main account" per user that already has sources or bank balances.
insert into public.bank_accounts (user_id, name)
select u.user_id, 'Main account'
from (select user_id from public.sources
      union
      select user_id from public.bank_balances) u;

update public.sources s
set bank_account_id = (select a.id from public.bank_accounts a
                       where a.user_id = s.user_id and a.name = 'Main account');
update public.bank_balances b
set bank_account_id = (select a.id from public.bank_accounts a
                       where a.user_id = b.user_id and a.name = 'Main account');

-- 4. From now on every source and every bank balance must name an account.
alter table public.sources       alter column bank_account_id set not null;
alter table public.bank_balances alter column bank_account_id set not null;

-- One balance per account per date (was: one per user per date).
alter table public.bank_balances drop constraint if exists bank_balances_user_id_as_of_key;
alter table public.bank_balances add constraint bank_balances_account_as_of_key unique (bank_account_id, as_of);
create index sources_bank_account_idx on public.sources (bank_account_id);

-- 5. Functions that change shape. Dropped and re-created (a function cannot change its columns in place).
drop function if exists public.source_summaries(date);
drop function if exists public.current_reconciliation();

-- Same as before, plus the bank account of each source.
create function public.source_summaries(p_month date)
returns table (
  source_id uuid, name text, kind text, opening_balance numeric, is_active boolean,
  month_opening numeric, income numeric, expense numeric, invested numeric, saved numeric,
  closing numeric, invested_saved_to_date numeric,
  bank_account_id uuid, bank_account_name text
)
language sql stable set search_path = public as $$
  with m as (
    select date_trunc('month', p_month)::date as ms,
           (date_trunc('month', p_month) + interval '1 month')::date as me
  ),
  agg as (
    select s.id, s.name, s.kind, s.opening_balance, s.is_active, s.created_at,
      s.bank_account_id, ba.name as bank_account_name,
      coalesce(sum(case when t.type = 'income' then t.amount else -t.amount end)
               filter (where t.tx_date < m.ms), 0)                         as before_net,
      coalesce(sum(t.amount) filter (where t.type = 'income'     and t.tx_date >= m.ms), 0) as income,
      coalesce(sum(t.amount) filter (where t.type = 'expense'    and t.tx_date >= m.ms), 0) as expense,
      coalesce(sum(t.amount) filter (where t.type = 'investment' and t.tx_date >= m.ms), 0) as invested,
      coalesce(sum(t.amount) filter (where t.type = 'savings'    and t.tx_date >= m.ms), 0) as saved,
      coalesce(sum(t.amount) filter (where t.type in ('investment', 'savings')), 0)         as to_date
    from public.sources s
    cross join m
    join public.bank_accounts ba on ba.id = s.bank_account_id
    left join public.transactions t
      on t.source_id = s.id and t.tx_date >= s.opening_date and t.tx_date < m.me
    where s.opening_date < m.me
    group by s.id, ba.id, m.ms, m.me
  )
  select id, name, kind, opening_balance, is_active,
         opening_balance + before_net,
         income, expense, invested, saved,
         opening_balance + before_net + income - expense - invested - saved,
         to_date, bank_account_id, bank_account_name
  from agg
  where is_active or income <> 0 or expense <> 0 or invested <> 0 or saved <> 0
        or (opening_balance + before_net) <> 0
  order by created_at, name;
$$;

-- One row per bank account: the sum of its sources' balances next to its latest statement balance.
-- bank_balance and as_of are null when no balance has been entered for that account.
-- Archived accounts are listed only while their sources still hold money.
create function public.current_reconciliation()
returns table (bank_account_id uuid, name text, is_active boolean,
               sources_total numeric, bank_balance numeric, as_of date)
language sql stable set search_path = public as $$
  select ba.id, ba.name, ba.is_active,
         coalesce(sum(public.source_balance(s.id)), 0) as sources_total,
         b.balance, b.as_of
  from public.bank_accounts ba
  left join public.sources s on s.bank_account_id = ba.id
  left join lateral (
    select bb.balance, bb.as_of from public.bank_balances bb
    where bb.bank_account_id = ba.id order by bb.as_of desc limit 1
  ) b on true
  group by ba.id, b.balance, b.as_of
  having ba.is_active or coalesce(sum(public.source_balance(s.id)), 0) <> 0
  order by ba.created_at, ba.name;
$$;

-- Bank accounts with how many active sources each has (Settings).
create function public.bank_account_usage()
returns table (bank_account_id uuid, name text, is_active boolean, active_source_count bigint)
language sql stable set search_path = public as $$
  select ba.id, ba.name, ba.is_active, count(s.id) filter (where s.is_active)
  from public.bank_accounts ba
  left join public.sources s on s.bank_account_id = ba.id
  group by ba.id
  order by ba.created_at, ba.name;
$$;

revoke execute on function
  public.source_summaries(date), public.current_reconciliation(), public.bank_account_usage()
from public, anon;
grant execute on function
  public.source_summaries(date), public.current_reconciliation(), public.bank_account_usage()
to authenticated;
