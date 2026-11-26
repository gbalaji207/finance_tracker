# Templates 04: Copy from last month

**Goal:** the checklist of last month's entries with a live "Copy N selected" button. This completes the Templates page and all five mocked pages.

**Prerequisites:** Templates 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/templates/widgets/copy_last_month_card.dart` | `CopyLastMonthCard` |
| `lib/features/templates/view/templates_page.dart` | change: replace the "Copy from last month" placeholder |

## CopyLastMonthCard

`CopyLastMonthCard({required List<Transaction> entries, required Set<String> selectedIds, required String Function(String sourceId) sourceName, required ValueChanged<String> onToggle, required VoidCallback onCopy})`

An `AppCard` (padding 20) with `Column(crossAxisAlignment: stretch)`:

1. **Header** (a `Wrap`, space-between, 12px gaps, 8px below):
   - Left: title `Copy from October 2026` in `sectionTitle`; below it (4px) `Tick the entries to re-create in November. You can change amounts before saving.` in `subtitle`.
   - Right: `AppButton(label: 'Copy ${selectedIds.length} selected to November', size: large, onPressed: selectedIds.isEmpty ? null : onCopy)`.
2. **Rows**, one per entry, each with a 1px bottom border `divider`, min height 44, vertical padding 6, `Row` with 12px gaps:
   - `LabeledCheckbox` taking the left `Expanded` space, `value: selectedIds.contains(id)`, `onChanged: (_) => onToggle(id)`, label = description in `bodyStrong`.
   - Source name in a 120px box (`body`).
   - Amount in a 110px right-aligned box: `AmountText(amount, type)`.

In the page: `onToggle` → `cubit.toggleEntry`; `onCopy` → SnackBar `Copied ${state.selectedCount} entries (sample data, nothing is created yet)`.

## Expected content (sample data)

Initially checked: all rows except the electricity bill. Button reads `Copy 5 selected to November`.

| Description | Source | Amount | Checked |
|-------------|--------|-------:|:-------:|
| Home EMI | Salary | −₹32,000 | yes |
| SIP: index fund | Salary | −₹20,000 | yes |
| Rent received | Aqua 105 | +₹45,000 | yes |
| Rent received | VR | +₹28,000 | yes |
| Electricity bill | VR | −₹2,100 | no |
| Recurring deposit | Aqua 105 | −₹10,000 | yes |

## Verify

- [ ] Rows and checkboxes match the table; the button says "Copy 5 selected to November".
- [ ] Ticking the electricity bill changes the button to "Copy 6 selected…"; unticking everything disables the button (greyed).
- [ ] Clicking the button with items ticked shows the SnackBar with the right count.
- [ ] The full Templates page matches the wireframe and no placeholder boxes remain. `flutter analyze` is clean.
