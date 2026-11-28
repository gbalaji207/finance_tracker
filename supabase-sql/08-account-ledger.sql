-- 08-account-ledger.sql
-- Ledger functions for the Accounts report: the entries of a date range with a running balance,
-- and the opening balance and totals for the same filters. Run after 01 to 03, 05 and 07.
-- Safe to run more than once: it drops the functions first (including the earlier version
-- without the bank account filter) and creates them again.
-- Both functions run as the caller (SECURITY INVOKER), so row level security applies.
--
-- Filters: p_bank_account (all accounts when null), p_source (all sources of that account when null),
-- p_type (all types when null).
--
-- Rules (the same as the Monthly report):
--  * only entries dated on or after their source's opening_date count;
--  * income is a credit, every other type (expense, investment, savings, partner) is a debit;
--  * the opening balance is, for each chosen source opened by the end of the range, its opening_balance
--    plus every earlier entry (from its opening_date up to the day before p_from). It ignores p_type.
--  * the running balance starts at that opening balance and is computed oldest to newest over ALL the
--    entries that match the filters (before paging), so later pages continue correctly.

drop function if exists public.account_ledger_summary(date, date, uuid, text);
drop function if exists public.account_ledger(date, date, uuid, text, int, int);
drop function if exists public.account_ledger_summary(date, date, uuid, uuid, text);
drop function if exists public.account_ledger(date, date, uuid, uuid, text, int, int);

-- Opening balance, totals and entry count for one set of filters.
create function public.account_ledger_summary(
  p_from date, p_to date, p_bank_account uuid default null,
  p_source uuid default null, p_type text default null)
returns table (opening_balance numeric, total_credit numeric, total_debit numeric, entry_count bigint)
language sql stable set search_path = public as $$
  with s as (
    select * from public.sources
    where (p_bank_account is null or bank_account_id = p_bank_account)
      and (p_source is null or id = p_source)
  ),
  opening as (
    select coalesce(sum(
      s.opening_balance + coalesce((
        select sum(case when t.type = 'income' then t.amount else -t.amount end)
        from public.transactions t
        where t.source_id = s.id and t.tx_date >= s.opening_date and t.tx_date < p_from
      ), 0)
    ), 0) as amt
    from s
    where s.opening_date <= p_to
  ),
  shown as (
    select t.type as entry_type, t.amount as entry_amount
    from public.transactions t
    join s on s.id = t.source_id
    where t.tx_date >= s.opening_date
      and t.tx_date >= p_from and t.tx_date <= p_to
      and (p_type is null or t.type = p_type)
  )
  select (select amt from opening),
         coalesce(sum(entry_amount) filter (where entry_type = 'income'), 0),
         coalesce(sum(entry_amount) filter (where entry_type <> 'income'), 0),
         count(*)
  from shown;
$$;

-- One page of entries, newest first, each with its running balance after the entry.
create function public.account_ledger(
  p_from date, p_to date, p_bank_account uuid default null,
  p_source uuid default null, p_type text default null,
  p_limit int default 25, p_offset int default 0)
returns table (entry_id uuid, entry_date date, description text, entry_type text,
               source_id uuid, amount numeric, closing numeric)
language sql stable set search_path = public as $$
  with s as (
    select * from public.sources
    where (p_bank_account is null or bank_account_id = p_bank_account)
      and (p_source is null or id = p_source)
  ),
  opening as (
    select coalesce(sum(
      s.opening_balance + coalesce((
        select sum(case when t.type = 'income' then t.amount else -t.amount end)
        from public.transactions t
        where t.source_id = s.id and t.tx_date >= s.opening_date and t.tx_date < p_from
      ), 0)
    ), 0) as amt
    from s
    where s.opening_date <= p_to
  ),
  shown as (
    select t.id, t.tx_date, t.description, t.type, t.source_id, t.amount, t.created_at
    from public.transactions t
    join s on s.id = t.source_id
    where t.tx_date >= s.opening_date
      and t.tx_date >= p_from and t.tx_date <= p_to
      and (p_type is null or t.type = p_type)
  ),
  running as (
    select sh.*,
      (select amt from opening)
        + sum(case when sh.type = 'income' then sh.amount else -sh.amount end)
            over (order by sh.tx_date, sh.created_at, sh.id) as closing
    from shown sh
  )
  select r.id, r.tx_date, r.description, r.type, r.source_id, r.amount, r.closing
  from running r
  order by r.tx_date desc, r.created_at desc, r.id desc
  limit p_limit offset p_offset;
$$;

-- Only signed-in users may call these.
revoke execute on function
  public.account_ledger_summary(date, date, uuid, uuid, text),
  public.account_ledger(date, date, uuid, uuid, text, int, int)
from public, anon;
grant execute on function
  public.account_ledger_summary(date, date, uuid, uuid, text),
  public.account_ledger(date, date, uuid, uuid, text, int, int)
to authenticated;
