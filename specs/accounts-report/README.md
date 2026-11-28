# Part 5: Accounts report

New requirement: a ledger page, like a bank statement, listing every entry with Date, Description, Credit, Debit and a running Closing balance, filtered by date range, source and type.

## Prerequisites

Partner transfers finished (PT01 to PT04), the Transactions and Settings redesigns, and everything before them.

## Order

| # | File | What you will see afterwards |
|---|------|------------------------------|
| AR01 | `AR01-models-and-mock.md` | Ledger models, the repository method, mock data and tests |
| AR02 | `AR02-page-and-route.md` | An "Accounts report" page at `/reports/accounts` with filters, summary tiles, the table and paging, in sample mode |
| AR03 | `AR03-database.md` | Database migration run in the console (`supabase-sql/08-account-ledger.sql`) |
| AR04 | `AR04-supabase-repository.md` | The real repository calls the new functions; everything works against Supabase |

Do AR01 and AR02 in **sample mode** (plain `flutter run`). AR03 is safe to run any time: it only adds functions. Supabase mode shows the page's error card until AR04 is done.

## How it works

- **Rows:** every entry (all types) of the chosen source, or of all sources, dated inside the range. Entries dated before a source's opening date are not counted, as everywhere else.
- **Credit** is an income entry; **Debit** is an expense, investment, savings or Jillu entry. A row has one or the other, the other cell shows `—`.
- **Closing** is a running balance. It starts from the **opening balance**: the balance of the chosen sources just before the From date (opening balance plus all earlier entries). Then each row adds its credit or subtracts its debit, **oldest to newest, over the rows that are shown**.
  - With no Type filter, Closing is the real balance after each entry, and the last (newest) row matches the Dashboard when the range ends today.
  - With a Type filter the rows that are hidden are not part of the running total, so Closing is the opening balance plus only the shown rows. The summary tiles say so.
- **Order:** newest first. The running total is still computed oldest first and then displayed in reverse.
- **Filters:** From and To dates (default the first and last day of the current month; From can never be after To), Bank account (All accounts or one, archived ones included), Source (All sources or one; when a bank account is chosen it lists only that account's sources, and choosing another account clears a source that is not in it), Type (All types or one). A bank account limits the report to its sources, so the Opening balance is that account's and can be compared with its bank statement.
- **Summary tiles above the table:** Opening balance, Total credit, Total debit, Closing balance. They cover the whole filtered range, not only the current page.
- **Paging:** 25 rows a page.
- **Not in this change:** a Description search, export, or editing entries from this page.

## Database file in this bundle (`supabase-sql/`)

`08-account-ledger.sql` (new): two functions, `account_ledger` (the rows with the running Closing, paged) and `account_ledger_summary` (opening balance and totals). Run it once.

Conventions are the same as in `specs/README.md` and `specs/app-supabase/README.md`.
