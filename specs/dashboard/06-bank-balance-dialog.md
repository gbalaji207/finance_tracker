# Dashboard 06: Update bank balance dialog

**Goal:** the dialog opened from "Update bank balance" on the reconciliation strip, with a live difference and an in-memory update of the strip.

**Prerequisites:** Dashboard 01 and 02 done; spec 07 done.

## Files

| File | Contents |
|------|----------|
| `lib/features/dashboard/widgets/bank_balance_dialog.dart` | `BankBalanceDialog`, `BankBalanceResult`, `showBankBalanceDialog` |
| `lib/features/dashboard/cubit/dashboard_cubit.dart` | add `updateBankBalance(double balance, DateTime asOf)` |
| `lib/features/dashboard/view/dashboard_page.dart` | change: wire `onUpdateBankBalance` |

## Dialog

```dart
typedef BankBalanceResult = ({double balance, DateTime asOf});

Future<BankBalanceResult?> showBankBalanceDialog(BuildContext context, {
  required double sourcesTotal,
  required double currentBankBalance,
  required DateTime asOf,
})
```
Opens through `showAppDialog`. `BankBalanceDialog` is a `StatefulWidget` (local state: an amount controller initialised with `currentBankBalance` as a whole number, and the selected date) returning an `AppDialog`:

- **Title:** `Update bank balance`
- **Content** (`Column(spacing: 16)`):
  1. Paragraph `Enter the balance shown in your bank statement. The dashboard compares it with the sum of your source balances.` in `bodySecondary`.
  2. `Row` (12px gap) of two `Expanded`: `AppTextField` `Bank balance (₹)` (decimal keyboard, controller above) and `AppDateField` `As on` (value from state).
  3. A filled `InfoBox` with a `Column(spacing: 8)` of two rows: `Sum of source balances` (`rowLabel`) with `Money.plain(sourcesTotal)` (`rowValue`); and `Difference` with a `StatusPill`: when the typed amount equals `sourcesTotal` a success pill `₹0 · Matches`, otherwise a warning pill `Off by ${Money.plain((sourcesTotal - typed).abs())}`. This updates as the user types.
- **Actions:** `AppButton('Cancel', secondary, large)` pops `null`; `AppButton('Save bank balance', primary, large)` pops a `BankBalanceResult`. Save is disabled while the amount cannot be parsed. Parsing: remove commas and spaces, then `double.tryParse`; empty or invalid is disabled.

## Cubit and page

- `DashboardCubit.updateBankBalance(balance, asOf)` emits a state whose `reconciliation` is a new `BankReconciliation(sourcesTotal: <unchanged>, bankBalance: balance, asOf: asOf)`. In memory only.
- In the page, `ReconciliationStrip.onUpdateBankBalance` becomes: open the dialog with the current reconciliation values, and if a result comes back call `updateBankBalance`.

## Expected content (sample data)

Opening the dialog shows `132400` and `26 Nov 2026`, sum `₹1,32,400`, green pill `₹0 · Matches`.

## Do not

Persist the balance or touch the source balances.

## Verify

- [x] "Update bank balance" on the Dashboard opens the dialog with the values above.
- [x] Typing `132000` changes the pill to a warning `Off by ₹400`; clearing the field disables Save.
- [x] Saving `132000` closes the dialog and the strip now shows `₹1,32,000`, the entry date, and the warning pill `Off by ₹400`; reloading the page resets it.
- [x] Cancel and Esc change nothing. `flutter analyze` is clean.
