# Settings 01: Skeleton

**Goal:** replace the Settings placeholder with the real structure: Cubit loading data, header, and placeholders for each card. Sections arrive in specs 02 to 04.

**Prerequisites:** Part 1, specs 07 and 08, and Login 01 done.

## Files

| File | Contents |
|------|----------|
| `lib/features/settings/cubit/settings_state.dart` | `SettingsState` |
| `lib/features/settings/cubit/settings_cubit.dart` | `SettingsCubit` |
| `lib/features/settings/view/settings_page.dart` | change: real page |

## State (`Equatable`, README pattern)

| Field | Type | Initial |
|-------|------|---------|
| `status` | `LoadStatus` | `loading` |
| `sources` | `List<Source>` (active and archived) | `[]` |
| `categoryUsage` | `List<CategoryUsage>` | `[]` |

## Cubit

- `load()`: fetches `allSources()` and `categoryUsage()`, emits `loaded`.
- `toggleSourceActive(String id)`: flips `isActive` on that source in the state's list (use `Source.copyWith`). It lives in memory only and resets on reload.

## Page

`SettingsPage` creates the Cubit (`..load()`); loading shows a centered `CircularProgressIndicator`; otherwise `Column(crossAxisAlignment: start, spacing: 24)`:
1. `PageHeader(title: 'Settings', subtitle: 'Sample data · sources, categories and your account')`.
2. `TwoPane(primaryMin: 560, secondaryWidth: 340, primary: SectionPlaceholder(name: 'Sources list', height: 320), secondary: SectionPlaceholder(name: 'New source form', height: 320))`.
3. `TwoPane(primaryMin: 560, secondaryWidth: 340, primary: SectionPlaceholder(name: 'Categories list', height: 360), secondary: SectionPlaceholder(name: 'New category form', height: 200))`.
4. `SectionPlaceholder(name: 'Account', height: 80)`.

This replaces the earlier "Not designed yet" placeholder page.

## Do not

Build any of the sections.

## Verify

- [ ] `/settings` shows the header "Settings" with the subtitle above and four placeholder areas (two side-by-side pairs, then one full-width), stacking when narrow.
- [ ] The sidebar highlights Settings. `flutter analyze` is clean.
