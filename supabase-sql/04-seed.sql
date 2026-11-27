-- 04-seed.sql
-- Sample data for development. It reproduces the November 2026 figures from the wireframes.
-- Needs your login user to exist first (Authentication > Users) and 05-bank-accounts.sql to have been run.
-- (If you loaded an earlier version of this seed before 05 existed, do not run this again; run 06 instead.)
-- Run once.

do $$
begin
  if not exists (select 1 from auth.users) then
    raise exception 'Create your login user first (Authentication > Users), then run this again.';
  end if;
  if exists (select 1 from public.sources) then
    raise exception 'Data already exists. Run 99-reset-dev-data.sql first if you want to reseed.';
  end if;
end $$;

-- Bank accounts.
insert into public.bank_accounts (user_id, name, created_at)
select u.id, v.name, timestamptz '2026-06-01 00:00:00+00' + v.n * interval '1 second'
from (select id from auth.users order by created_at limit 1) u
cross join (values (1, 'HDFC Salary'), (2, 'SBI Rentals')) as v(n, name);

-- Sources. Opening balances are the balance on opening_date (not on today).
insert into public.sources (user_id, name, kind, opening_balance, opening_date, is_active, created_at, bank_account_id)
select u.id, v.name, v.kind, v.opening, v.odate::date, v.active,
       timestamptz '2026-06-01 00:00:00+00' + v.n * interval '1 second', a.id
from (select id from auth.users order by created_at limit 1) u
cross join (values
  (1, 'Salary',        'Employment', 2000, '2026-10-01', true,  'HDFC Salary'),
  (2, 'Side hustle',   'Freelance',  3000, '2026-10-01', true,  'HDFC Salary'),
  (3, 'Aqua 105',      'Rental',     6000, '2026-06-01', true,  'SBI Rentals'),
  (4, 'VR',            'Rental',     2100, '2026-10-01', true,  'SBI Rentals'),
  (5, 'Old freelance', 'Freelance',     0, '2026-10-01', false, 'HDFC Salary')
) as v(n, name, kind, opening, odate, active, acct)
join public.bank_accounts a on a.name = v.acct;

-- Categories.
insert into public.categories (user_id, name, kind, created_at)
select u.id, v.name, v.kind, timestamptz '2026-06-01 00:00:00+00' + v.n * interval '1 second'
from (select id from auth.users order by created_at limit 1) u
cross join (values
  (1, 'Housing',         'expense'),
  (2, 'Groceries',       'expense'),
  (3, 'Utilities',       'expense'),
  (4, 'Property upkeep', 'expense'),
  (5, 'Other',           'expense'),
  (6, 'Mutual funds',    'investment'),
  (7, 'Fixed deposit',   'savings')
) as v(n, name, kind);

-- Entries: Aqua 105 from June, everything else from October.
insert into public.transactions (user_id, tx_date, type, source_id, category_id, amount, description)
select u.id, v.d::date, v.t, s.id, c.id, v.amount, v.descr
from (select id from auth.users order by created_at limit 1) u
cross join (values
  -- Aqua 105, June to September
  ('2026-06-22', 'income',     'Aqua 105', null,              45000, 'Rent received'),
  ('2026-06-12', 'expense',    'Aqua 105', 'Property upkeep',  9000, 'Maintenance'),
  ('2026-06-15', 'savings',    'Aqua 105', 'Fixed deposit',   40000, 'Fixed deposit'),
  ('2026-07-22', 'income',     'Aqua 105', null,              45000, 'Rent received'),
  ('2026-07-10', 'expense',    'Aqua 105', 'Property upkeep', 14000, 'Maintenance'),
  ('2026-07-15', 'savings',    'Aqua 105', 'Fixed deposit',   25000, 'Fixed deposit'),
  ('2026-08-22', 'income',     'Aqua 105', null,              45000, 'Rent received'),
  ('2026-08-10', 'expense',    'Aqua 105', 'Property upkeep',  8500, 'Maintenance'),
  ('2026-08-15', 'savings',    'Aqua 105', 'Fixed deposit',   35000, 'Fixed deposit'),
  ('2026-09-22', 'income',     'Aqua 105', null,              45000, 'Rent received'),
  ('2026-09-10', 'expense',    'Aqua 105', 'Property upkeep', 11000, 'Maintenance'),
  ('2026-09-15', 'savings',    'Aqua 105', 'Fixed deposit',   30000, 'Fixed deposit'),
  -- October
  ('2026-10-22', 'income',     'Aqua 105', null,              45000, 'Rent received'),
  ('2026-10-10', 'expense',    'Aqua 105', 'Property upkeep', 10500, 'Garden and pipeline repair'),
  ('2026-10-15', 'savings',    'Aqua 105', 'Fixed deposit',   10000, 'Recurring deposit'),
  ('2026-10-28', 'savings',    'Aqua 105', 'Fixed deposit',   30000, 'Fixed deposit top-up'),
  ('2026-10-05', 'income',     'Salary',   null,             120000, 'Salary credited'),
  ('2026-10-05', 'expense',    'Salary',   'Housing',         32000, 'Home EMI'),
  ('2026-10-05', 'investment', 'Salary',   'Mutual funds',    20000, 'SIP: index fund'),
  ('2026-10-12', 'expense',    'Salary',   'Groceries',       14000, 'Groceries'),
  ('2026-10-10', 'expense',    'Salary',   'Utilities',        6000, 'Electricity and internet'),
  ('2026-10-18', 'expense',    'Salary',   'Other',            5000, 'Miscellaneous'),
  ('2026-10-27', 'savings',    'Salary',   'Fixed deposit',   30000, 'Fixed deposit'),
  ('2026-10-17', 'income',     'Side hustle', null,           30000, 'Client payout'),
  ('2026-10-03', 'expense',    'Side hustle', 'Other',         7000, 'Software subscriptions'),
  ('2026-10-20', 'investment', 'Side hustle', 'Mutual funds', 20000, 'Mutual fund top-up'),
  ('2026-10-22', 'income',     'VR',       null,              28000, 'Rent received'),
  ('2026-10-20', 'expense',    'VR',       'Utilities',        2100, 'Electricity bill'),
  ('2026-10-28', 'savings',    'VR',       'Fixed deposit',   24000, 'Fixed deposit'),
  -- November: Aqua 105
  ('2026-11-22', 'income',     'Aqua 105', null,              45000, 'Rent received'),
  ('2026-11-12', 'expense',    'Aqua 105', 'Property upkeep',  3600, 'Plumbing repair'),
  ('2026-11-14', 'expense',    'Aqua 105', 'Property upkeep',  8400, 'Roof waterproofing'),
  ('2026-11-15', 'savings',    'Aqua 105', 'Fixed deposit',   10000, 'Recurring deposit'),
  -- November: Salary
  ('2026-11-05', 'income',     'Salary',   null,             120000, 'Salary credited'),
  ('2026-11-25', 'expense',    'Salary',   'Housing',         32000, 'Home EMI'),
  ('2026-11-25', 'expense',    'Salary',   'Groceries',        4200, 'Groceries'),
  ('2026-11-03', 'expense',    'Salary',   'Groceries',        3100, 'Groceries'),
  ('2026-11-10', 'expense',    'Salary',   'Groceries',        2800, 'Groceries'),
  ('2026-11-14', 'expense',    'Salary',   'Groceries',        2400, 'Groceries'),
  ('2026-11-18', 'expense',    'Salary',   'Groceries',        1500, 'Groceries'),
  ('2026-11-21', 'expense',    'Salary',   'Groceries',        1000, 'Groceries'),
  ('2026-11-08', 'expense',    'Salary',   'Utilities',        2800, 'Electricity bill'),
  ('2026-11-09', 'expense',    'Salary',   'Utilities',        1200, 'Internet bill'),
  ('2026-11-12', 'expense',    'Salary',   'Utilities',        2600, 'Water and gas'),
  ('2026-11-16', 'expense',    'Salary',   'Other',             700, 'Phone recharge'),
  ('2026-11-19', 'expense',    'Salary',   'Other',            1500, 'Dining out'),
  ('2026-11-24', 'investment', 'Salary',   'Mutual funds',    20000, 'SIP: index fund'),
  ('2026-11-06', 'savings',    'Salary',   'Fixed deposit',    6000, 'Emergency fund deposit'),
  -- November: Side hustle
  ('2026-11-18', 'income',     'Side hustle', null,           35000, 'Client payout'),
  ('2026-11-04', 'expense',    'Side hustle', 'Other',         3600, 'Software subscriptions'),
  ('2026-11-11', 'expense',    'Side hustle', 'Other',         5000, 'Co-working space'),
  ('2026-11-20', 'investment', 'Side hustle', 'Mutual funds', 10000, 'Mutual fund top-up'),
  -- November: VR
  ('2026-11-22', 'income',     'VR',       null,              28000, 'Rent received'),
  ('2026-11-20', 'expense',    'VR',       'Utilities',        2400, 'Electricity bill'),
  ('2026-11-13', 'expense',    'VR',       'Property upkeep',  2600, 'Painting touch-up'),
  ('2026-11-17', 'expense',    'VR',       'Other',            1200, 'Cleaning supplies')
) as v(d, t, src, cat, amount, descr)
join public.sources s on s.name = v.src
left join public.categories c on c.name = v.cat;

-- Templates.
insert into public.entry_templates (user_id, name, type, source_id, category_id, amount, description, quick_add, sort_order)
select u.id, v.name, v.t, s.id, c.id, v.amount, '', v.quick, v.n
from (select id from auth.users order by created_at limit 1) u
cross join (values
  (1, 'Home EMI',          'expense',    'Salary',   'Housing',      32000, true),
  (2, 'SIP: index fund',   'investment', 'Salary',   'Mutual funds', 20000, true),
  (3, 'Rent received',     'income',     'Aqua 105', null,           45000, true),
  (4, 'Rent received',     'income',     'VR',       null,           28000, false),
  (5, 'Internet bill',     'expense',    'VR',       'Utilities',     null, true),
  (6, 'Recurring deposit', 'savings',    'Aqua 105', 'Fixed deposit', 10000, false)
) as v(n, name, t, src, cat, amount, quick)
join public.sources s on s.name = v.src
left join public.categories c on c.name = v.cat;

-- Bank balances as on 26 Nov 2026 (HDFC Salary 75,600 and SBI Rentals 56,800, together 1,32,400).
insert into public.bank_balances (user_id, bank_account_id, as_of, balance)
select u.id, a.id, date '2026-11-26', v.balance
from (select id from auth.users order by created_at limit 1) u
cross join (values ('HDFC Salary', 75600), ('SBI Rentals', 56800)) as v(acct, balance)
join public.bank_accounts a on a.name = v.acct;
