# Dashboard 02: Bank reconciliation strip

**Goal:** the strip that compares the sum of source balances to the bank balance.

**Prerequisites:** Dashboard 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/dashboard/widgets/reconciliation_strip.dart` | `ReconciliationStrip` |
| `lib/features/dashboard/view/dashboard_page.dart` | change: replace the "Bank reconciliation" placeholder |

## ReconciliationStrip

`ReconciliationStrip({required BankReconciliation data, required VoidCallback onUpdateBankBalance})`

An `AppCard` with padding `16 vertical, 20 horizontal` containing a `Row`:
- `Expanded` → `Wrap(spacing: 40, runSpacing: 16, crossAxisAlignment: center)` with three items:
  1. Column: caption `Sum of source balances` (`caption`), value `Money.plain(data.sourcesTotal)` (`summaryValue`).
  2. Column: caption `Bank balance (entered 26 Nov)` where the date is `AppDates.dayMonth(data.asOf)`, value `Money.plain(data.bankBalance)` (`summaryValue`).
  3. A `StatusPill`:
     - `difference == 0`: success, text `Matches · difference ₹0`.
     - otherwise: warning, text `Off by ${Money.plain(difference.abs())}`.
- At the right end: `AppTextLink('Update bank balance')` calling `onUpdateBankBalance`.

In the page, pass `onUpdateBankBalance` that shows the SnackBar `Not wired yet (sample data)`.

## Expected content (sample data)

Sum of source balances `₹1,32,400`; bank balance `₹1,32,400` (entered 26 Nov); green pill "Matches · difference ₹0".

## Do not

Add editing of the bank balance.

## Verify

- [x] The strip matches the numbers above, with large bold values and small grey captions.
- [x] The green pill shows; temporarily changing the mock bank balance to 132000 turns it into a red-tinted "Off by ₹400" (revert afterwards).
- [x] Clicking "Update bank balance" shows the SnackBar. `flutter analyze` is clean.
