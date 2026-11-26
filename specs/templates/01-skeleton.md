# Templates 01: Skeleton

**Goal:** the real page structure for Templates and copy-last-month with Cubit (including the checklist selection), header and one placeholder per section.

**Prerequisites:** specs 00 to 06 done.

## Files

| File | Contents |
|------|----------|
| `lib/features/templates/cubit/templates_state.dart` | `TemplatesState` |
| `lib/features/templates/cubit/templates_cubit.dart` | `TemplatesCubit` |
| `lib/features/templates/view/templates_page.dart` | change: real page |

## State (`Equatable`, README pattern)

| Field | Type | Initial |
|-------|------|---------|
| `status` | `LoadStatus` | `loading` |
| `sources` | `List<Source>` | `[]` |
| `categories` | `List<Category>` | `[]` |
| `templates` | `List<EntryTemplate>` | `[]` |
| `previousEntries` | `List<Transaction>` | `[]` |
| `selectedIds` | `Set<String>` | `{}` |

Helpers on the state: `sourceName(String id)`, `categoryName(String? id)` (returns `—` for null/unknown), and `int get selectedCount`.

## Cubit

- `load()`: fetches `sources()`, `categories()`, `templates()`, `previousMonthEntries(mockMonth minus one month)`. Emits `loaded` with `selectedIds` = all previous entry ids **except** `o5` (the electricity bill), i.e. `{o1, o2, o3, o4, o6}`.
- `toggleEntry(String id)`: adds or removes the id from `selectedIds`.

## Page

`TemplatesPage` creates the Cubit (`..load()`); loading shows a centered `CircularProgressIndicator`; otherwise `Column(crossAxisAlignment: start, spacing: 24)`:
1. `PageHeader(title: 'Templates and copy last month', subtitle: 'Sample data · nothing is created automatically; these only pre-fill the entry form')`.
2. `TwoPane(primaryMin: 560, secondaryWidth: 340, primary: SectionPlaceholder(name: 'Your templates', height: 360), secondary: SectionPlaceholder(name: 'New template form', height: 360))`.
3. `SectionPlaceholder(name: 'Copy from last month', height: 360)`.

## Do not

Build the sections.

## Verify

- [ ] `/templates` shows the header with the long subtitle and three placeholders: a wide one with a 340px one beside it (stacked when narrow), then a full-width one.
- [ ] `flutter analyze` is clean.
