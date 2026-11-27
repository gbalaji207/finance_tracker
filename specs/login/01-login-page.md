# Login 01: Login page and mock auth

**Goal:** the Login page at `/login` (outside the sidebar shell), a mock `AuthCubit`, and a router guard that is switched off for now.

**Prerequisites:** Part 1 done; specs 07 (`AppTextField` password support, `dialogTitle`, `brandLarge`) and 08 done.

## Files

| File | Change |
|------|--------|
| `lib/app/auth_config.dart` | new: config constants |
| `lib/features/auth/cubit/auth_state.dart` | new: `AuthState` |
| `lib/features/auth/cubit/auth_cubit.dart` | new: `AuthCubit` |
| `lib/features/auth/view/login_page.dart` | new: `LoginPage` |
| `lib/app/routes.dart` | add `static const login = '/login';` |
| `lib/app/router.dart` | add the route and the guard; `createRouter` now takes an `AuthCubit` |
| `lib/app/app.dart` | provide `AuthCubit` above `MaterialApp.router` |

## Config (`auth_config.dart`)

```dart
const bool kRequireLogin = false;   // the Supabase phase turns this on
const String kMockAccountEmail = 'your-email@example.com';
```

## AuthState / AuthCubit

State (`Equatable`): `status` (`AuthStatus { signedOut, signedIn }`), `email` (`String`), `errorMessage` (`String?`).

`AuthCubit` initial state: if `kRequireLogin` then `signedOut` with empty email, otherwise `signedIn` with `kMockAccountEmail`.

- `signIn(String email, String password)`:
  - if either (trimmed) is empty: emit error `Enter your email and password.`
  - else if `password == 'wrong'`: emit error `Wrong email or password. Try again.` (this rule only exists so the error state can be seen; it goes away with real auth)
  - else emit `signedIn` with the trimmed email and no error.
- `signOut()`: emit `signedOut`, empty email, no error.
- `clearError()`.

## Router

- Add `GoRoute(path: AppRoutes.login)` **outside** the `ShellRoute` (no sidebar), using `NoTransitionPage`.
- `createRouter(AuthCubit auth)` sets `refreshListenable` to a small listenable that notifies on every `auth.stream` event.
- Redirect logic: when `kRequireLogin` is true, a signed-out user going anywhere but `/login` is sent to `/login`, and a signed-in user opening `/login` is sent to `/dashboard`. When `kRequireLogin` is false there are no auth redirects (the existing `/` to `/dashboard` redirect stays).
- `App` wraps its tree in `BlocProvider<AuthCubit>(create: (_) => AuthCubit())` and passes `context.read<AuthCubit>()` to `createRouter` once (create the router in a place that has the cubit available).

## LoginPage layout

`Scaffold` with the page background; content centered, scrollable, padding 24 horizontal / 40 vertical, in a `ConstrainedBox(maxWidth: 400)` with `Column(spacing: 20)`:

1. **Brand block** (centered): `Money Tracker` in `brandLarge`; `Income, spending and savings by source` in `subtitle`, 4px below.
2. **Form card:** `AppCard(padding: 24)` with an `AutofillGroup` and `Column(crossAxisAlignment: stretch, spacing: 16)`:
   - `Sign in` in `dialogTitle` (header semantics).
   - `AppTextField` label `Email`, hint `your-email@example.com`, keyboard email, `textInputAction: next`, autofill hint username.
   - `AppTextField` label `Password`, hint `Your password`, `obscureText: true`, `textInputAction: done`, autofill hint password, `onSubmitted` triggers sign in.
   - If `errorMessage != null`: a container (background `expenseBg`, radius 8, padding 10 vertical / 12 horizontal) with the message in 13px / 600 / `expenseFg`, wrapped in a live-region `Semantics`.
   - `AppButton('Sign in', primary, large, expand)`.
   - Centered `AppTextLink('Forgot password?')` that shows the SnackBar `Not wired yet (sample data)`.
3. **Footer:** `Private app. Only the owner can sign in; sign-ups are turned off.` in `caption`, centered.

A `BlocListener` on `AuthCubit`: when the status becomes `signedIn`, call `context.go(AppRoutes.dashboard)`.

## Do not

Call any backend, store credentials, or build a sign-up flow.

## Verify

- [x] Opening `/login` shows the centered card without the sidebar, matching the wireframe.
- [x] Empty fields then Sign in shows "Enter your email and password."; password `wrong` shows "Wrong email or password. Try again."; anything else goes to `/dashboard`. Pressing Enter in the password field also signs in.
- [x] With `kRequireLogin = false` the app still opens straight on the Dashboard.
- [x] Temporarily set `kRequireLogin = true`: every URL redirects to `/login` until you sign in, then lands on `/dashboard`, and `/login` redirects to `/dashboard` while signed in. Set it back to `false`.
- [x] `flutter analyze` is clean.
