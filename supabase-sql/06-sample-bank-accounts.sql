-- 06-sample-bank-accounts.sql
-- DEV ONLY, optional. Run after 05 if you loaded the sample data (04) before 05.
-- Splits the sample data over two bank accounts so the multi-account screens have something to show:
--   HDFC Salary: Salary, Side hustle, Old freelance      SBI Rentals: Aqua 105, VR
-- Do not run it on real data.

do $$
begin
  if not exists (select 1 from public.sources where name = 'Aqua 105')
     or not exists (select 1 from public.bank_accounts where name = 'Main account') then
    raise exception 'Expected the sample data in one "Main account". Nothing changed.';
  end if;
end $$;

update public.bank_accounts set name = 'HDFC Salary' where name = 'Main account';

insert into public.bank_accounts (user_id, name, created_at)
select user_id, 'SBI Rentals', created_at + interval '1 second'
from public.bank_accounts where name = 'HDFC Salary';

update public.sources
set bank_account_id = (select id from public.bank_accounts where name = 'SBI Rentals')
where name in ('Aqua 105', 'VR');

-- The single sample bank balance (132400 on 26 Nov) becomes two.
update public.bank_balances set balance = 75600
where bank_account_id = (select id from public.bank_accounts where name = 'HDFC Salary');

insert into public.bank_balances (user_id, bank_account_id, as_of, balance)
select user_id, id, date '2026-11-26', 56800
from public.bank_accounts where name = 'SBI Rentals';
