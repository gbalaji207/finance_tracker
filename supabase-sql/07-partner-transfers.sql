-- 07-partner-transfers.sql
-- Adds the "partner" entry type and category kind (money sent to your partner for day-to-day expenses).
-- Run once, after 01 to 03 and 05 (and 04/06 if you loaded the sample data).
-- A partner entry reduces the source balance like any outgoing entry, but it is not an expense.

-- 1. Allow the new value. The foreign key (category_id, type) -> categories (id, kind) is untouched,
--    so a partner entry can only use a partner category, and only income has no category.
alter table public.categories      drop constraint if exists categories_kind_check;
alter table public.categories      add  constraint categories_kind_check
  check (kind in ('expense', 'investment', 'savings', 'partner'));

alter table public.transactions    drop constraint if exists transactions_type_check;
alter table public.transactions    add  constraint transactions_type_check
  check (type in ('income', 'expense', 'investment', 'savings', 'partner'));

alter table public.entry_templates drop constraint if exists entry_templates_type_check;
alter table public.entry_templates add  constraint entry_templates_type_check
  check (type in ('income', 'expense', 'investment', 'savings', 'partner'));

-- 2. Functions that change shape (a function cannot change its columns in place).
drop function if exists public.source_summaries(date);
drop function if exists public.source_month_rows(uuid, date, int);

-- Per-source figures for one month (Dashboard, Monthly report): 05 version plus partner.
create function public.source_summaries(p_month date)
returns table (
  source_id uuid, name text, kind text, opening_balance numeric, is_active boolean,
  month_opening numeric, income numeric, expense numeric, invested numeric, saved numeric,
  closing numeric, invested_saved_to_date numeric,
  bank_account_id uuid, bank_account_name text,
  partner numeric
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
      coalesce(sum(t.amount) filter (where t.type = 'partner'    and t.tx_date >= m.ms), 0) as partner,
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
         opening_balance + before_net + income - expense - invested - saved - partner,
         to_date, bank_account_id, bank_account_name,
         partner
  from agg
  where is_active or income <> 0 or expense <> 0 or invested <> 0 or saved <> 0 or partner <> 0
        or (opening_balance + before_net) <> 0
  order by created_at, name;
$$;

-- Month-by-month history for one source, newest first (Source report): 03 version plus partner.
create function public.source_month_rows(
  p_source uuid, p_end_month date default current_date, p_months int default 6)
returns table (month date, income numeric, expense numeric, invested_saved numeric,
               partner numeric, closing numeric)
language sql stable set search_path = public as $$
  with s as (select * from public.sources where id = p_source),
  months as (
    select generate_series(
      date_trunc('month', p_end_month)::date - ((p_months - 1) * interval '1 month'),
      date_trunc('month', p_end_month)::date,
      interval '1 month')::date as ms
  )
  select m.ms,
    coalesce(sum(t.amount) filter (where t.type = 'income'  and t.tx_date >= m.ms), 0),
    coalesce(sum(t.amount) filter (where t.type = 'expense' and t.tx_date >= m.ms), 0),
    coalesce(sum(t.amount) filter (where t.type in ('investment', 'savings') and t.tx_date >= m.ms), 0),
    coalesce(sum(t.amount) filter (where t.type = 'partner' and t.tx_date >= m.ms), 0),
    s.opening_balance + coalesce(sum(case when t.type = 'income' then t.amount else -t.amount end), 0)
  from months m
  cross join s
  left join public.transactions t
    on t.source_id = s.id and t.tx_date >= s.opening_date
   and t.tx_date < (m.ms + interval '1 month')::date
  where s.opening_date < (m.ms + interval '1 month')::date
  group by m.ms, s.opening_balance
  order by m.ms desc;
$$;

revoke execute on function
  public.source_summaries(date), public.source_month_rows(uuid, date, int)
from public, anon;
grant execute on function
  public.source_summaries(date), public.source_month_rows(uuid, date, int)
to authenticated;
