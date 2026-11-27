# 07: Component additions

**Goal:** the small extra pieces the new screens need: danger buttons, password-capable text field, generic badge, info box, dialog shell, selected table rows, and a few tokens.

**Prerequisites:** Part 1 (specs 00 to 06 and all five pages) done.

## Files to change or create

| File | Change |
|------|--------|
| `lib/core/theme/app_colors.dart` | add tokens (below) |
| `lib/core/theme/app_text_styles.dart` | add `dialogTitle`, `brandLarge` |
| `lib/core/widgets/app_button.dart` | add variants `danger`, `dangerOutline` |
| `lib/core/widgets/app_text_field.dart` | add `obscureText`, `textInputAction`, `onSubmitted`, `autofillHints` |
| `lib/core/widgets/app_badge.dart` | new: `AppBadge` |
| `lib/core/widgets/type_badge.dart` | rebuild on top of `AppBadge` (same look and API) |
| `lib/core/widgets/info_box.dart` | new: `InfoBox` |
| `lib/core/widgets/app_dialog.dart` | new: `AppDialog`, `showAppDialog` |
| `lib/core/widgets/app_table.dart` | add `AppTableRow.background` |
| `lib/dev/component_gallery.dart` | add the new pieces |

## Tokens

Add to `AppColors`:

```dart
static const danger = Color(0xFF7A271A);        // delete buttons and text
static const neutralBg = Color(0xFFE9E9E3);     // "Archived" badge
static const neutralFg = Color(0xFF4A5057);
static const rowSelected = Color(0xFFEAF4F1);   // selected table row
static const scrim = Color(0xFF1F2328);         // dialog barrier, used at 35% opacity
```

Add to `AppTextStyles` (Inter): `dialogTitle` 20 / 700 / textPrimary (dialog titles and the login "Sign in" heading), `brandLarge` 22 / 700 / textPrimary (login brand).

## AppButton variants

| Variant | Background | Text | Border |
|---------|-----------|------|--------|
| `danger` | `AppColors.danger` | white | none |
| `dangerOutline` | `surface` | `AppColors.danger` | 1px `AppColors.danger` |

Same sizes, radius and disabled rule (50% opacity) as the existing variants.

## AppTextField additions

New optional parameters: `bool obscureText = false`, `TextInputAction? textInputAction`, `ValueChanged<String>? onSubmitted`, `Iterable<String>? autofillHints`. They pass straight to the underlying `TextField`. No visual change.

## AppBadge

`AppBadge({required String text, required Color background, required Color foreground})`: padding 4 vertical / 8 horizontal, radius 6, text in `AppTextStyles.badge` colored `foreground`. Rewrite `TypeBadge` to return an `AppBadge` using `type.badgeBg` and `type.badgeFg`.

## InfoBox

`InfoBox({required Widget child, bool bordered = false})`: padding 12, radius 8.
- Filled (default): background `AppColors.pageBg`.
- `bordered: true`: background `surface` with a 1px border `AppColors.cardBorder`.

## AppDialog

```dart
class AppDialog extends StatelessWidget {
  const AppDialog({super.key, required this.title, required this.content, required this.actions});
  final String title;
  final Widget content;
  final List<Widget> actions;
}

Future<T?> showAppDialog<T>(BuildContext context, WidgetBuilder builder)
```

- `showAppDialog` calls `showDialog<T>` with `barrierColor: AppColors.scrim` at 35% opacity and the given builder. Esc and a click on the barrier close it (defaults).
- `AppDialog` builds a `Dialog` with transparent background and zero elevation, `insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 40)`. Inside, a `ConstrainedBox(maxWidth: 440)` containing a `Container` with background `surface`, radius 12, padding 24 and a shadow (`Color(0x401F2328)`, blur 40, offset 0 / 12). Its child is a scrollable `Column(mainAxisSize: min, crossAxisAlignment: stretch, spacing: 16)`:
  1. `title` in `dialogTitle` (wrapped in `Semantics(header: true)`).
  2. `content`.
  3. `Padding(top: 4)` with a `Wrap(alignment: WrapAlignment.end, spacing: 12, runSpacing: 12)` of `actions`.

Each real dialog is its own widget (often a `StatefulWidget`) that returns an `AppDialog`, and is opened with `showAppDialog`.

## AppTableRow.background

Add `Color? background` to `AppTableRow`. When set, the row is painted with that color (full row width). `highlight` still wins when both are set.

## Gallery additions

Add a "Part 2 additions" heading with: all four button variants side by side (primary, secondary, danger, dangerOutline) in medium size; a password `AppTextField` (`obscureText: true`); two `AppBadge`s ("Active" `incomeBg`/`income`, "Archived" `neutralBg`/`neutralFg`); a filled and a bordered `InfoBox` with two key-value rows each; a table with one row using `background: AppColors.rowSelected`; two buttons "Open sample dialog" and "Open destructive dialog" that call `showAppDialog` with a plain `AppDialog` (title, one line of text, Cancel + Save) and one with a Cancel + danger "Delete" pair.

## Do not

Change the look of existing components beyond what is listed. Do not add dialogs for real features yet.

## Verify

- [x] `flutter analyze` is clean; existing pages look unchanged (badges still render the same).
- [x] The gallery shows the danger solid (dark red, white text) and outline buttons; the password field hides its text.
- [x] Both sample dialogs open centered, 440 wide at most, on a dimmed background; Esc and a click outside close them; actions wrap under the content on a narrow window.
- [x] The selected table row has a pale teal background.
