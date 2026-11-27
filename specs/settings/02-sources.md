# Settings 02: Sources

**Goal:** the Sources list card with Archive/Restore, and the New source form card beside it.

**Prerequisites:** Settings 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/settings/widgets/sources_card.dart` | `SourcesCard` |
| `lib/features/settings/widgets/new_source_card.dart` | `NewSourceCard` |
| `lib/features/settings/view/settings_page.dart` | change: replace the "Sources list" and "New source form" placeholders |

## SourcesCard

`SourcesCard({required List<Source> sources, required ValueChanged<Source> onEdit, required ValueChanged<Source> onToggleActive})`

An `AppCard` (padding 20) with `Column(crossAxisAlignment: start)`:
1. `Sources` in `sectionTitle`.
2. 4px below: `Each income stream or property is a source. Archived sources keep their history but are hidden from new entries.` in `subtitle`; 8px of space under it.
3. `AppTable(minWidth: 560)`:

| Column | Width / flex | Align |
|--------|--------------|-------|
| Name | flex 1.2 | left |
| Kind | 100 | left |
| Opening balance | 130 | right |
| Status | 96 | left |
| Actions | 130 | right |

Cells: name `bodyStrong`; kind secondary text; opening `Money.plain(openingBalance)`; status `AppBadge` (`Active`: `incomeBg` / `income`; `Archived`: `neutralBg` / `neutralFg`); actions a `Row(mainAxisSize: min, spacing: 16)` of `AppTextLink('Edit')` and `AppTextLink(isActive ? 'Archive' : 'Restore')`.

In the page: `onEdit` shows the SnackBar `Not wired yet (sample data)`; `onToggleActive` calls `SettingsCubit.toggleSourceActive`.

## NewSourceCard

`NewSourceCard({required VoidCallback onSave})`, stateful (local state for the dropdown and controllers).

An `AppCard` (padding 20) with `Column(crossAxisAlignment: stretch, spacing: 14)`:
1. `New source` in `sectionTitle`.
2. `AppTextField` `Name`, hint `e.g. Aqua 410`.
3. `AppDropdown<String>` `Kind`: Employment, Freelance, Rental, Other; default **Rental**.
4. `AppTextField` `Opening balance (₹)`, hint `0`, decimal keyboard, helper `Balance of this source on the day you start using the app.`
5. `AppButton('Save source', primary, large, expand)` calling `onSave`; in the page it shows the SnackBar `Not wired yet (sample data)`.

## Expected content (sample data)

| Name | Kind | Opening balance | Status | Actions |
|------|------|----------------:|--------|---------|
| Salary | Employment | ₹15,000 | Active | Edit · Archive |
| Side hustle | Freelance | ₹6,000 | Active | Edit · Archive |
| Aqua 105 | Rental | ₹8,000 | Active | Edit · Archive |
| VR | Rental | ₹4,000 | Active | Edit · Archive |
| Old freelance | Freelance | ₹0 | Archived | Edit · Restore |

## Do not

Persist anything or validate the form.

## Verify

- [x] The table shows the five rows above; the archived row has a grey badge and a "Restore" link.
- [x] Clicking Archive on "VR" turns its badge grey and the link to "Restore" (and back); reloading the page resets it.
- [x] "Edit" and "Save source" show the SnackBar. The form's Kind defaults to Rental.
- [x] The categories and account placeholders are still there. `flutter analyze` is clean.
