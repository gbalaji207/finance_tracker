# BA03: Update bank balance dialog with an account picker

**Goal:** the dialog asks which bank account the balance belongs to, and shows that account's source total and difference.

**Prerequisites:** BA02 done.

## Files

| File | Change |
|------|--------|
| `lib/features/dashboard/widgets/bank_balance_dialog.dart` | account dropdown, per-account values |
| `lib/features/dashboard/view/dashboard_page.dart` | new call |
| `lib/features/dashboard/cubit/dashboard_cubit.dart` | confirm `updateBankBalance(accountId, balance, asOf)` |

## Dialog

```dart
typedef BankBalanceResult = ({String accountId, double balance, DateTime asOf});

Future<BankBalanceResult?> showBankBalanceDialog(BuildContext context, {
  required List<BankAccountReconciliation> accounts,   // the accounts to choose from (active ones)
  required String initialAccountId,
})
```
Opened through `showAppDialog`. `BankBalanceDialog` stays a `StatefulWidget`; its state holds the selected account id, the amount controller and the date. Layout (inside `AppDialog`, content `Column(spacing: 16)`):

1. Paragraph `Choose the bank account and enter the balance shown in its statement. The dashboard compares it with the sum of that account's source balances.` in `bodySecondary`.
2. `AppDropdown<String>` labelled `Bank account`, items = `accounts` (value = account id, label = name), value = the selected id.
3. The row with `AppTextField` `Bank balance (₹)` and `AppDateField` `As on`, as before.
4. The filled `InfoBox` with two rows: `Sum of this account's sources` / `Money.plain(selected.sourcesTotal)`, and `Difference` / the `StatusPill` (typed amount equal to the account's `sourcesTotal` gives success `₹0 · Matches`, otherwise warning `Off by ${Money.plain((sourcesTotal - typed).abs())}`; updates as the user types).

- When the selected account changes: set the amount to that account's current `bankBalance` as a whole number (empty when it has none) and the date to its `asOf` (or `appToday()` when it has none).
- Initially the same values are filled for `initialAccountId`.
- Save is disabled while the amount cannot be parsed (use `parseAmount` from B08); it pops a `BankBalanceResult`. Cancel pops null.

## Page and cubit

- The Dashboard's `onUpdate(row)` becomes: open the dialog with `accounts` = the reconciliation's accounts whose `account.isActive` is true **plus** the tapped row (in case it is archived) and `initialAccountId: row.account.id`; when a result comes back call `DashboardCubit.updateBankBalance(result.accountId, result.balance, result.asOf)`.
- `DashboardCubit.updateBankBalance`: calls `setBankBalance(accountId, balance, asOf)`, re-fetches `reconciliation()` and emits it; on failure it returns the message for `AppSnack.error`; on success `AppSnack.info(AppConfig.note('Bank balance saved'))`. (If BA01 already made it so, only check it.)

## Do not

Let the dialog create accounts (that is Settings).

## Verify (sample mode)

- [ ] "Update" on the HDFC Salary row opens the dialog with the account preselected, `75600`, `26 Nov 2026`, `Sum of this account's sources ₹75,600` and `₹0 · Matches`.
- [ ] Switching the dropdown to SBI Rentals changes the amount to `56800` and the sum to `₹56,800`; typing `56000` shows `Off by ₹800`; clearing the field disables Save.
- [ ] Saving `56000` for SBI Rentals closes the dialog; the SBI row reads `Off by ₹800`, HDFC still matches, the top pill reads `Off by ₹800 in 1 account`. Reload resets it.
- [ ] Cancel and Esc change nothing. `flutter analyze` and `flutter test` pass.
