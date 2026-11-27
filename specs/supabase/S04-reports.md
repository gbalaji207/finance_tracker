# S04: Report functions

**Goal:** the SQL functions that produce the dashboard, monthly report and source report numbers.

**Prerequisites:** S02 and S03 done.

## Run

SQL Editor, paste `supabase-sql/03-reports.sql`, Run. It uses `create or replace`, so it is safe to re-run any time (including after you edit a function).

## The functions

All run as the signed-in user, so the security rules from S03 apply to them too. Only signed-in users may call them.

| Function | Arguments | Returns (columns) | Used by |
|----------|-----------|-------------------|---------|
| `source_summaries` | `p_month date` (any day in the month) | `source_id, name, kind, opening_balance, is_active, month_opening, income, expense, invested, saved, closing, invested_saved_to_date`, one row per source | Dashboard, Monthly report |
| `expense_by_category` | `p_month date` | `category, amount`, largest first | Monthly report |
| `source_month_rows` | `p_source uuid`, `p_end_month date` (default today), `p_months int` (default 6) | `month, income, expense, invested_saved, closing`, newest first | Source report |
| `source_balance` | `p_source uuid` | one number: the source's balance now | Delete dialog, Source report |
| `current_reconciliation` | none | `sources_total, bank_balance, as_of` (bank columns are null if no bank balance exists) | Dashboard strip |
| `category_usage` | none | `category_id, name, kind, is_active, entry_count` | Settings |

Rules inside them:

- Balance = `opening_balance` + income - expense - investment - savings, counting only entries on or after the source's `opening_date`.
- `month_opening` is the balance at the start of the month; `closing = month_opening + income - expense - invested - saved`.
- `source_summaries` skips an archived source that has no balance and no activity that month (so "Old freelance" does not clutter the dashboard).
- Totals for the Monthly report (income, expense, ...) are sums of the per-source rows; the app adds them up.

## Verify

Nothing is in the tables yet, so there is nothing to see. Check only that the functions exist; this must return 6 rows:

```sql
select routine_name from information_schema.routines
where routine_schema = 'public'
  and routine_name in ('source_summaries', 'expense_by_category', 'source_month_rows',
                       'source_balance', 'current_reconciliation', 'category_usage')
order by 1;
```

The real checks, with numbers, are in S05 once there is data.
