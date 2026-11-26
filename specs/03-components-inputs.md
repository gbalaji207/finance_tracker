# 03: Input components

**Goal:** buttons, text link, text field, dropdown, date field, entry-type selector and labelled checkbox, plus a component gallery page to check them.

**Prerequisites:** specs 01 and 02 done.

## Files to create

| File | Class |
|------|-------|
| `lib/core/widgets/app_button.dart` | `AppButton`, `AppButtonVariant`, `AppButtonSize` |
| `lib/core/widgets/app_text_link.dart` | `AppTextLink` |
| `lib/core/widgets/app_text_field.dart` | `AppTextField` |
| `lib/core/widgets/app_dropdown.dart` | `AppDropdown<T>`, `AppDropdownItem<T>` |
| `lib/core/widgets/app_date_field.dart` | `AppDateField` |
| `lib/core/widgets/type_selector.dart` | `TypeSelector` |
| `lib/core/widgets/labeled_checkbox.dart` | `LabeledCheckbox` |
| `lib/dev/component_gallery.dart` | `ComponentGallery` (temporary, extended in spec 04) |
| `lib/main.dart` | change: home becomes `ComponentGallery` |

## AppButton

`AppButton({required String label, required VoidCallback? onPressed, AppButtonVariant variant = primary, AppButtonSize size = medium, bool expand = false})`.

| Size | Height | Text style | Horizontal padding |
|------|--------|------------|--------------------|
| small | 40 | `buttonSmall` | 16 |
| medium | 44 | `button` | 20 |
| large | 48 | `button` | 20 |

- **primary:** background `primary`, white text, no border.
- **secondary:** background `surface`, text `primaryDark`, 1px border `primary`.
- Radius 8. `expand: true` makes it full width. Disabled (`onPressed == null`): 50% opacity, no pointer cursor.
- Implement with `FilledButton` / `OutlinedButton` styled through `ButtonStyle` (no elevation, `minimumSize` set to the height, `tapTargetSize: shrinkWrap`).

## AppTextLink

`AppTextLink({required String label, required VoidCallback onPressed})`. A `TextButton` with `AppTextStyles.link` (13px, 600, `primaryDark`, underlined), padding `vertical 4, horizontal 0`, `minimumSize: Size.zero`, `tapTargetSize: shrinkWrap`, no hover background.

## Field look (shared by text field, dropdown, date field)

- Label above the input: `AppTextStyles.label`, 6px gap below it. Label is optional.
- Input box: height 44, background `surface`, 1px border `inputBorder`, radius 8, horizontal padding 12, text `body`, hint text `body` in `textSecondary`.
- Focused: border `primary`, 1.5px. No error styling in this phase.
- Optional helper text under the box: `caption`, 6px gap.

## AppTextField

`AppTextField({String? label, String? hintText, String? helperText, TextEditingController? controller, TextInputType? keyboardType, ValueChanged<String>? onChanged})`.

## AppDropdown

```dart
class AppDropdownItem<T> { const AppDropdownItem(this.value, this.label); final T value; final String label; }
AppDropdown<T>({String? label, required List<AppDropdownItem<T>> items, T? value, String? hintText, ValueChanged<T?>? onChanged, String? helperText})
```
Use `DropdownButtonFormField<T>` (`isExpanded: true`, icon `Icons.keyboard_arrow_down`, `borderRadius` 8, dropdown menu background `surface`) so the closed box matches the field look. `value == null` shows `hintText`.

## AppDateField

`AppDateField({String? label, required DateTime value, required ValueChanged<DateTime> onChanged})`. A read-only field showing `AppDates.dayMonthYear(value)` with a trailing `Icons.calendar_today_outlined` (size 18). Tapping opens `showDatePicker` (first date 2020-01-01, last 2035-12-31) and calls `onChanged` with the pick.

## TypeSelector

`TypeSelector({String? label, required TxType value, required ValueChanged<TxType> onChanged})`.

A `Row` of four equal (`Expanded`) buttons, 6px apart, in the order Income, Expense, Investment, Savings. Each is 44 high, radius 8, label in `FittedBox(fit: scaleDown)` at 13px.
- Selected: border `primary`, background `primaryTint`, text `primaryDark`, weight 700.
- Unselected: 1px border `inputBorder`, background `surface`, text `textPrimary`, weight 400.
- Use real buttons and `Semantics(selected: ...)`. The optional label sits above with the field label style.

## LabeledCheckbox

`LabeledCheckbox({required bool value, required ValueChanged<bool> onChanged, required Widget label})`. Row with a 20×20 checkbox (`MaterialTapTargetSize.shrinkWrap`), 12px gap, `Expanded(label)`. The whole row is tappable and at least 44 high.

## ComponentGallery

A scrollable page (padding 32, max content width 720) with a heading "Inputs" and sub-sections using the real widgets:
- Buttons: 3 sizes × 2 variants, plus one disabled primary and one `expand: true` primary.
- Link: `AppTextLink('View all')`.
- Fields: text field with label and hint; one with helper text; dropdown with 3 items and a value; dropdown with no value showing a hint; date field.
- `TypeSelector` (stateful, starts on Expense) with a label.
- Two `LabeledCheckbox`es (stateful).

The buttons and link do nothing except show the SnackBar `Not wired yet (sample data)`. Spec 04 will add more sections to this file.

## Do not

Add validation, error states or form logic.

## Verify

- [ ] Primary buttons are teal with white text; secondary are white with a teal outline; heights are 40/44/48.
- [ ] Fields are 44px tall with grey borders that turn teal when focused; labels sit above in small bold grey.
- [ ] The dropdown opens and changes value; the date field opens a calendar and shows `26 Nov 2026`-style text after picking.
- [ ] `TypeSelector` highlights the clicked option in teal tint; the four options fit within a 300px-wide column (try it by narrowing the window).
- [ ] Checkboxes toggle by clicking the label text. `flutter analyze` is clean.
