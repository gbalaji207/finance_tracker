-- 03-reports.sql
-- Report functions, called from Flutter with supabase.rpc('name', params: {...}).
-- They run as the caller (SECURITY INVOKER, the default), so RLS applies and each user only sees their own data.
-- Balance of a source = opening_balance + income - expense - investment - savings,
-- counting only entries dated on or after the source's opening_date.

-- Per-source figures for one month (Dashboard, Monthly report).
create or replace function public.source_summaries(p_month date)
returns table (
  source_id uuid, name text, kind text, opening_balance numeric, is_active boolean,
  month_opening numeric, income numeric, expense numeric, invested numeric, saved numeric,
  closing numeric, invested_saved_to_date numeric
)
language sql stable set search_path = public as $$
  with m as (
    select date_trunc('month', p_month)::date as ms,
           (date_trunc('month', p_month) + interval '1 month')::date as me
  ),
  agg as (
    select s.id, s.name, s.kind, s.opening_balance, s.is_active, s.created_at,
      coalesce(sum(case when t.type = 'income' then t.amount else -t.amount end)
               filter (where t.tx_date < m.ms), 0)                         as before_net,
      coalesce(sum(t.amount) filter (where t.type = 'income'     and t.tx_date >= m.ms), 0) as income,
      coalesce(sum(t.amount) filter (where t.type = 'expense'    and t.tx_date >= m.ms), 0) as expense,
      coalesce(sum(t.amount) filter (where t.type = 'investment' and t.tx_date >= m.ms), 0) as invested,
      coalesce(sum(t.amount) filter (where t.type = 'savings'    and t.tx_date >= m.ms), 0) as saved,
      coalesce(sum(t.amount) filter (where t.type in ('investment', 'savings')), 0)         as to_date
    from public.sources s
    cross join m
    left join public.transactions t
      on t.source_id = s.id and t.tx_date >= s.opening_date and t.tx_date < m.me
    where s.opening_date < m.me
    group by s.id, m.ms, m.me
  )
  select id, name, kind, opening_balance, is_active,
         opening_balance + before_net,
         income, expense, invested, saved,
         opening_balance + before_net + income - expense - invested - saved,
         to_date
  from agg
  where is_active or income <> 0 or expense <> 0 or invested <> 0 or saved <> 0
        or (opening_balance + before_net) <> 0
  order by created_at, name;
$$;

-- Expense totals per category for one month, largest first (Monthly report).
create or replace function public.expense_by_category(p_month date)
returns table (category text, amount numeric)
language sql stable set search_path = public as $$
  select c.name, sum(t.amount)
  from public.transactions t
  join public.categories c on c.id = t.category_id
  join public.sources s on s.id = t.source_id
  where t.type = 'expense'
    and t.tx_date >= s.opening_date
    and t.tx_date >= date_trunc('month', p_month)::date
    and t.tx_date <  (date_trunc('month', p_month) + interval '1 month')::date
  group by c.name
  order by sum(t.amount) desc, c.name;
$$;

-- Month-by-month history for one source, newest first (Source report).
create or replace function public.source_month_rows(
  p_source uuid, p_end_month date default current_date, p_months int default 6)
returns table (month date, income numeric, expense numeric, invested_saved numeric, closing numeric)
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

-- Current balance of one source (delete dialog, source report header).
create or replace function public.source_balance(p_source uuid)
returns numeric
language sql stable set search_path = public as $$
  select s.opening_balance + coalesce(sum(case when t.type = 'income' then t.amount else -t.amount end), 0)
  from public.sources s
  left join public.transactions t on t.source_id = s.id and t.tx_date >= s.opening_date
  where s.id = p_source
  group by s.id;
$$;

-- Sum of all source balances next to the latest bank balance (Dashboard strip).
create or replace function public.current_reconciliation()
returns table (sources_total numeric, bank_balance numeric, as_of date)
language sql stable set search_path = public as $$
  select
    (select coalesce(sum(public.source_balance(s.id)), 0) from public.sources s),
    b.balance,
    b.as_of
  from (select 1) one
  left join lateral (
    select balance, as_of from public.bank_balances order by as_of desc limit 1
  ) b on true;
$$;

-- Categories with how many entries use each (Settings).
create or replace function public.category_usage()
returns table (category_id uuid, name text, kind text, is_active boolean, entry_count bigint)
language sql stable set search_path = public as $$
  select c.id, c.name, c.kind, c.is_active, count(t.id)
  from public.categories c
  left join public.transactions t on t.category_id = c.id
  group by c.id
  order by c.created_at, c.name;
$$;

-- Only signed-in users may call these.
revoke execute on function
  public.source_summaries(date), public.expense_by_category(date),
  public.source_month_rows(uuid, date, int), public.source_balance(uuid),
  public.current_reconciliation(), public.category_usage()
from public, anon;
grant execute on function
  public.source_summaries(date), public.expense_by_category(date),
  public.source_month_rows(uuid, date, int), public.source_balance(uuid),
  public.current_reconciliation(), public.category_usage()
to authenticated;
