# Dashboard 05: Quick add

**Goal:** the "Quick add" card listing four templates with a Use button each. This completes the Dashboard.

**Prerequisites:** Dashboard 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/dashboard/widgets/quick_add_card.dart` | `QuickAddCard` |
| `lib/features/dashboard/view/dashboard_page.dart` | change: replace the `secondary` placeholder inside the `TwoPane` |

## QuickAddCard

`QuickAddCard({required List<EntryTemplate> templates, required String Function(String sourceId) sourceName, required ValueChanged<EntryTemplate> onUse, required VoidCallback onManage, required VoidCallback onCopyLastMonth})`

An `AppCard` (padding 20) with a `Column(crossAxisAlignment: stretch)`:
1. `SectionHeader(title: 'Quick add', actionLabel: 'Manage', onAction: onManage)`.
2. For each template a row with a 1px bottom border `divider` and vertical padding 10, `Row` space-between with 12px gap:
   - Left (`Expanded`): name in `bodyStrong`; below it `"${sourceName(sourceId)} · ${type.label}"` in `caption`.
   - Right: `AppButton(label: 'Use', variant: secondary, size: small, onPressed: () => onUse(template))`.
3. 12px below, `AppTextLink('Copy entries from last month')` calling `onCopyLastMonth`.

In the page: `onUse` and `onManage`/`onCopyLastMonth` navigate: `onUse` → `context.go(AppRoutes.transactions)`, `onManage` and `onCopyLastMonth` → `context.go(AppRoutes.templates)`.

## Expected content (sample data)

| Name | Meta |
|------|------|
| Home EMI | Salary · Expense |
| SIP: index fund | Salary · Investment |
| Rent received | Aqua 105 · Income |
| Internet bill | VR · Expense |

## Do not

Pass the chosen template to the Transactions page. "Use" is plain navigation in this phase; the form there is filled through its own template dropdown.

## Verify

- [x] The card shows the four rows with small outlined "Use" buttons.
- [x] "Use" opens `/transactions`; "Manage" and "Copy entries from last month" open `/templates`.
- [x] The whole Dashboard now matches the wireframe: header, reconciliation strip, four source cards, recent entries beside quick add.
- [x] No placeholder boxes remain on the Dashboard. `flutter analyze` is clean.
