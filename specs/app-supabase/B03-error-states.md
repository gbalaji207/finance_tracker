# B03: Error states

**Goal:** when loading fails (no network, bad key, server error) every page shows a clear message with a "Try again" button instead of an endless spinner. Also adds the small helpers later specs use for messages and empty lists.

**Prerequisites:** B02 done.

## Files

| File | Change |
|------|--------|
| `lib/core/models/load_status.dart` | add `error` to `LoadStatus` |
| `lib/core/utils/error_message.dart` | new: `friendlyError(Object)` |
| `lib/core/widgets/error_view.dart` | new: `ErrorView` |
| `lib/core/widgets/empty_note.dart` | new: `EmptyNote` |
| `lib/core/widgets/app_snack.dart` | new: `AppSnack` |
| all page states and cubits | add error handling (list below) |
| all page views | show `ErrorView` on error |

## friendlyError

`String friendlyError(Object e)` returns:
- `PostgrestException`: code `23505` gives `That name is already used.`; `23503` gives `This item is still in use, so it cannot be removed. Archive it instead.`; `23514` gives `Some values are not allowed. Check the form.`; otherwise `The server rejected the request: ${e.message}`.
- `AuthException`: its `message`.
- `AuthFailure`: its `message`.
- A network failure: when `e.toString()` contains `Failed to fetch`, `ClientException` or `SocketException`: `Could not reach the server. Check your connection.`
- Anything else: `Something went wrong. Try again.`

## Widgets

- `ErrorView({required String message, required VoidCallback onRetry})`: an `AppCard` (padding 24) centered in the content area, `Column(mainAxisSize: min, spacing: 12)`: `Could not load this page` in `sectionTitle`, the message in `bodySecondary`, `AppButton('Try again', secondary, medium)`.
- `EmptyNote(String text)`: centered `text` in `bodySecondary` with 24px padding all around.
- `AppSnack`: `static void info(BuildContext c, String message)` shows a normal `SnackBar`; `static void error(BuildContext c, String message)` shows a `SnackBar` with background `AppColors.danger` and white text. Both clear the current SnackBar first.

## Cubits and states

For the `Dashboard`, `Transactions`, `MonthlyReport`, `SourceReport`, `Templates` and `Settings` states add `String? errorMessage` (include it in `props`). `copyWith` gets a `bool clearError = false` parameter so the message can be reset.

In each cubit's `load()`:
```dart
Future<void> load() async {
  emit(state.copyWith(status: LoadStatus.loading, clearError: true));
  try {
    // existing fetches ...
    emit(state.copyWith(status: LoadStatus.loaded /* , data */));
  } catch (e) {
    emit(state.copyWith(status: LoadStatus.error, errorMessage: friendlyError(e)));
  }
}
```
Other cubit methods that fetch (added in later specs) follow the same try/catch pattern.

## Views

In each page view add the third case: `status == LoadStatus.error` shows `ErrorView(message: state.errorMessage ?? '', onRetry: cubit.load)` (in the place where the spinner or content would be).

## Do not

Change how loaded pages look. Add retry timers.

## Verify

- [ ] Sample mode: temporarily make `MockFinanceRepository.sourceSummaries` throw `Exception('boom')`. The Dashboard shows the card with "Something went wrong. Try again." and a button; reverting the code and clicking "Try again" loads the page. Repeat for one other page by throwing in one of its calls, then revert everything.
- [ ] The real "no network" message cannot be tried yet, because the app still reads sample data. It is checked in B05.
- [ ] `flutter analyze` and `flutter test` pass.
