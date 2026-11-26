# Templates 02: Your templates (list)

**Goal:** the table of saved templates with Use and Edit links.

**Prerequisites:** Templates 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/templates/widgets/templates_list_card.dart` | `TemplatesListCard` |
| `lib/features/templates/view/templates_page.dart` | change: replace the `primary` placeholder |

## TemplatesListCard

`TemplatesListCard({required List<EntryTemplate> templates, required String Function(String sourceId) sourceName, required String Function(String? categoryId) categoryName, required ValueChanged<EntryTemplate> onUse, required ValueChanged<EntryTemplate> onEdit})`

An `AppCard` (padding 20) with:
1. Title `Your templates` in `sectionTitle`, 8px below it.
2. `AppTable(minWidth: 620)` with columns:

| Column | Width / flex | Align |
|--------|--------------|-------|
| Name | flex 1.2 | left |
| Type | 104 | left |
| Source | 104 | left |
| Category | 112 | left |
| Default amount | 100 | right |
| Actions | 120 | right |

Cells: name `bodyStrong`; `TypeBadge`; source name; category name (secondary); default amount `Money.plain(amount)` or `—` when null; actions: a `Row(mainAxisSize: min)` of `AppTextLink('Use')` and `AppTextLink('Edit')` 16px apart.

In the page: `onUse` → `context.go(AppRoutes.transactions)`; `onEdit` → SnackBar `Not wired yet (sample data)`.

## Expected content (sample data)

| Name | Type | Source | Category | Default amount |
|------|------|--------|----------|---------------:|
| Home EMI | Expense | Salary | Housing | ₹32,000 |
| SIP: index fund | Investment | Salary | Mutual funds | ₹20,000 |
| Rent received | Income | Aqua 105 | — | ₹45,000 |
| Rent received | Income | VR | — | ₹28,000 |
| Internet bill | Expense | VR | Utilities | — |
| Recurring deposit | Savings | Aqua 105 | Fixed deposit | ₹10,000 |

## Verify

- [ ] Six rows as above with colored badges; each row has underlined "Use" and "Edit" links.
- [ ] "Use" opens `/transactions`; "Edit" shows the SnackBar.
- [ ] Narrower than about 900px the table scrolls horizontally. `flutter analyze` is clean.
