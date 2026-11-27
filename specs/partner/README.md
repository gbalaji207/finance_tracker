# Part 4: partner transfers

New requirement: money you send to your partner for day-to-day expenses. You do not track what is spent from it, only how much you transferred each month. It leaves your bank account, so it must reduce the source balance, but it must not count as an expense.

## Naming

The stored value and the code use `partner` (database constraints, `TxType.partner`, `partner` columns). The word shown on screen is **Jillu** (`TxType.label` and the column, tile and row labels). Wherever the specs below say "Partner" for something on screen, the app shows "Jillu". To change the wording again, change only those labels; no database change is needed.

## Prerequisites

Bank accounts finished (BA01 to BA07 pass), and everything before it.

## Order

| # | File | What you will see afterwards |
|---|------|------------------------------|
| PT01 | `PT01-models-and-mock.md` | New `Partner` entry type and category kind, amounts in the models, mock data with a partner transfer, tests |
| PT02 | `PT02-report-and-cards.md` | A Partner column in the Monthly report, a KPI tile, a row on the Dashboard source cards, and Partner figures on the Source report |
| PT03 | `PT03-database.md` | Database migration run in the console (`supabase-sql/07-partner-transfers.sql`) |
| PT04 | `PT04-supabase-repository.md` | The real repository reads the new figures; everything works against Supabase |

Do PT01 and PT02 in **sample mode** (plain `flutter run`). PT01 keeps Supabase mode working: the new amounts default to 0 until PT04. The migration (PT03) is safe to run any time after PT01, but do not enter a Partner entry in Supabase mode before PT03 and PT04 are both done.

## How it works

- **Partner** is a fifth entry type, next to Income, Expense, Investment and Savings. Categories get the same new kind: create a category such as `Day-to-day` with kind Partner in Settings, then pick it when you add a Partner entry. The existing rule applies unchanged: an entry's category kind must equal its type.
- **Balance:** `closing = opening + income − expense − invested − saved − partner`. The amount leaves the source, so the Dashboard's sources total drops together with the bank balance and the bank reconciliation keeps matching.
- **Not an expense:** Partner amounts are not part of the Expense column, the Expense by category list, or the Income vs spend chart.
- **Savings rate** stays `(invested + saved) / income`; Partner is not in it.
- **Shown in three places:** Monthly report (table column and KPI tile), Dashboard source cards, Source report (summary tile and month table column).
- **Not in this change:** tracking what the money is spent on, a limit or budget for the transfer, and a Partner series in the chart.

## Database file in this bundle (`supabase-sql/`)

`07-partner-transfers.sql` (new): widens the allowed values for categories and entries, and replaces `source_summaries` and `source_month_rows` (both gain a `partner` column and subtract it from the closing balance). `source_balance` needs no change: it already subtracts every non-income type. Run it **once**. The earlier scripts are not edited.

Conventions are the same as in `specs/README.md` and `specs/app-supabase/README.md`.
