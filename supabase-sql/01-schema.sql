-- 01-schema.sql
-- Tables for the Money Tracker. Run once in the Supabase SQL Editor.
-- Safe to run on an empty project only (it creates, it does not alter).

-- Sources: each income stream or rental property.
create table public.sources (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name            text not null check (length(trim(name)) > 0),
  kind            text not null check (kind in ('Employment', 'Freelance', 'Rental', 'Other')),
  opening_balance numeric(14,2) not null default 0,
  opening_date    date not null default current_date,   -- entries before this date are not counted
  is_active       boolean not null default true,        -- false = archived
  created_at      timestamptz not null default now(),
  unique (user_id, name)
);

-- Categories for expense, investment and savings entries (income uses sources).
create table public.categories (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name       text not null check (length(trim(name)) > 0),
  kind       text not null check (kind in ('expense', 'investment', 'savings')),
  is_active  boolean not null default true,
  created_at timestamptz not null default now(),
  unique (user_id, name),
  unique (id, kind)                                     -- lets entries check category kind = entry type
);

-- Entries. Amount is always positive; the direction comes from type.
create table public.transactions (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  tx_date     date not null,
  type        text not null check (type in ('income', 'expense', 'investment', 'savings')),
  source_id   uuid not null references public.sources (id) on delete restrict,
  category_id uuid references public.categories (id) on delete restrict,
  amount      numeric(14,2) not null check (amount > 0),
  description text not null default '',
  created_at  timestamptz not null default now(),
  -- income has no category; everything else must have one
  check ((type = 'income' and category_id is null) or (type <> 'income' and category_id is not null)),
  -- the category's kind must equal the entry type (skipped for income because category_id is null)
  foreign key (category_id, type) references public.categories (id, kind)
);
create index transactions_user_date_idx on public.transactions (user_id, tx_date desc);
create index transactions_source_date_idx on public.transactions (source_id, tx_date);
create index transactions_category_idx on public.transactions (category_id);

-- Templates for recurring entries. Amount can be empty (fill in each time).
create table public.entry_templates (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name        text not null check (length(trim(name)) > 0),
  type        text not null check (type in ('income', 'expense', 'investment', 'savings')),
  source_id   uuid not null references public.sources (id) on delete cascade,
  category_id uuid references public.categories (id) on delete cascade,
  amount      numeric(14,2) check (amount is null or amount > 0),
  description text not null default '',
  quick_add   boolean not null default false,           -- shown as a chip on the Dashboard
  sort_order  int not null default 0,
  created_at  timestamptz not null default now(),
  check ((type = 'income' and category_id is null) or (type <> 'income' and category_id is not null)),
  foreign key (category_id, type) references public.categories (id, kind)
);

-- Bank balance as read from the bank statement; the latest row is the current one.
create table public.bank_balances (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  as_of      date not null,
  balance    numeric(14,2) not null,
  created_at timestamptz not null default now(),
  unique (user_id, as_of)
);
