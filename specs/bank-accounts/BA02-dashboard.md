# BA02: Dashboard: reconciliation per account and account on source cards

**Goal:** the reconciliation strip shows the totals and a list with one row per bank account (each with its own "Update" link); source cards show which account they belong to.

**Prerequisites:** BA01 done.

## Files

| File | Change |
|------|--------|
| `lib/features/dashboard/widgets/reconciliation_strip.dart` | rewrite (becomes stateful) |
| `lib/features/dashboard/widgets/source_balance_card.dart` | add the account caption |
| `lib/features/dashboard/widgets/source_cards_section.dart` | pass it through |
| `lib/features/dashboard/view/dashboard_page.dart` | wiring |
| `lib/core/utils/app_dates.dart` | add `dayMonth` if missing |

## ReconciliationStrip

```dart
class ReconciliationStrip extends StatefulWidget {
  const ReconciliationStrip({super.key, required this.data, required this.onUpdate});
  final BankReconciliation data;
  final ValueChanged<BankAccountReconciliation> onUpdate;   // opens the dialog for that account
}
```
`AppCard` (padding 16 vertical / 20 horizontal) with `Column(crossAxisAlignment: stretch)`:

1. **Totals row**, a `Wrap(spacing: 40, runSpacing: 16, crossAxisAlignment: center)`:
   - `KpiTile`-style pair (label 12px secondary, value 20 / 700): `Sum of source balances` and `Money.plain(data.sourcesTotal)`.
   - `Bank balances, all accounts` (label becomes `Bank balances, all accounts (${missingCount} not set)` when `missingCount > 0`) and `Money.plain(data.bankTotal)`.
   - A `StatusPill`:
     - `data.allMatch`: success tone, `Matches · difference ₹0`.
     - Otherwise warning tone, built from the parts that apply joined with `" · "`: `Off by ${Money.plain(offAmount)} in $offCount account(s)` when `offCount > 0` (write "account" for 1, "accounts" otherwise) and `Balance not set for $missingCount account(s)` when `missingCount > 0`.
2. **No accounts** (`data.accounts.isEmpty`): below a 12px gap, an `InfoBox` with `Add a bank account in Settings to compare your balances with the bank.` and nothing else.
3. **Accounts list** (otherwise): 12px gap, a 1px `divider` line, then an `AppTextLink` row `Bank accounts (${n})` that toggles the list (local state `expanded`, initially **true**; use `Semantics(expanded: ...)`). When expanded, an `AppTable(minWidth: 640)`:

| Column | Width / flex | Align |
|--------|--------------|-------|
| Account | flex 1.2 | left |
| Sources | 120 | right |
| Bank balance | 170 | right |
| Status | 150 | left |
| (no header) | 80 | right |

   Cells: account name `bodyStrong`; `Money.plain(sourcesTotal)`; bank balance `Money.plain(bankBalance)` followed by ` · ${AppDates.dayMonth(asOf)}` in `caption` (or `Not set` in secondary text when null); a `StatusPill`: matches gives success `Matches · ₹0`, off gives warning `Off by ${Money.plain(difference.abs())}`, not set gives warning `Not set`; and `AppTextLink('Update')` calling `onUpdate(row)`.

`AppDates.dayMonth(DateTime)` returns e.g. `26 Nov` (`DateFormat('d MMM')`).

## Source cards

`SourceBalanceCard` gets `String? bankAccountName`. The header becomes a `Row` (space-between): on the left a `Column(crossAxisAlignment: start)` with the source name (`bodyStrong`) and, when the account name is not null, the name in `caption` below it; on the right the kind text as before. `SourceCardsSection` passes `summary.source.bankAccountName`.

## Page wiring

`ReconciliationStrip(data: state.reconciliation, onUpdate: (row) => ...)`. Until BA03 the callback opens the existing dialog for the given account (the same adaptation as BA01, but with the tapped row's account) and calls `DashboardCubit.updateBankBalance(row.account.id, balance, asOf)`. The old single "Update bank balance" link is gone.

## Do not

Change the dialog (BA03) or the Settings page.

## Verify (sample mode)

- [ ] The strip shows `Sum of source balances ₹1,32,400`, `Bank balances, all accounts ₹1,32,400` and the green pill `Matches · difference ₹0`. Below it `Bank accounts (2)` is expanded with two rows: HDFC Salary ₹75,600 / ₹75,600 · 26 Nov / `Matches · ₹0` / Update, and SBI Rentals ₹56,800 / ₹56,800 · 26 Nov / `Matches · ₹0` / Update.
- [ ] Clicking `Bank accounts (2)` collapses and expands the list; the totals row stays.
- [ ] Salary and Side hustle cards show "HDFC Salary" under their names; Aqua 105 and VR show "SBI Rentals".
- [ ] "Update" on the SBI Rentals row opens the dialog (still the old design, showing ₹56,800 and `₹56,800`); saving `56400` changes only that row to `Off by ₹400`, the top pill to `Off by ₹400 in 1 account` and the bank total to ₹1,32,000. Reload resets it.
- [ ] The strip looks right at about 900px wide (the list scrolls sideways rather than overflowing). `flutter analyze` and `flutter test` pass.
