# Settings 04: Account

**Goal:** the Account card with the signed-in email, a Change password button and Sign out. This completes Settings.

**Prerequisites:** Settings 01 and Login 01 done.

## Files

| File | Class |
|------|-------|
| `lib/features/settings/widgets/account_card.dart` | `AccountCard` |
| `lib/features/settings/view/settings_page.dart` | change: replace the "Account" placeholder |

## AccountCard

`AccountCard({required String email, required VoidCallback onChangePassword, required VoidCallback onSignOut})`

An `AppCard` (padding 20) containing a `Wrap(alignment: spaceBetween, crossAxisAlignment: center, spacing: 16, runSpacing: 16)` with two children:
- Left `Column(crossAxisAlignment: start)`: `Account` in `sectionTitle`; 6px below, a `Text.rich` with `Signed in as ` in `subtitle` followed by the email in 13px / 600 / `textPrimary`.
- Right `Row(spacing: 12)`: `AppButton('Change password', secondary, medium)` and `AppButton('Sign out', secondary, medium)`.

In the page:
- `email` comes from `context.watch<AuthCubit>().state.email`.
- `onChangePassword` shows the SnackBar `Not wired yet (sample data)`.
- `onSignOut` calls `AuthCubit.signOut()` then `context.go(AppRoutes.login)`.

## Expected content (sample data)

`Signed in as your-email@example.com` (the mock account email).

## Verify

- [ ] The card shows the title, the email line and two outlined buttons; the buttons wrap under the text on a narrow window.
- [ ] "Change password" shows the SnackBar; "Sign out" goes to `/login`; signing in again goes back to the Dashboard.
- [ ] No placeholder boxes remain on Settings; the page matches the wireframe. `flutter analyze` is clean.
