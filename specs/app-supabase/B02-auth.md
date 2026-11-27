# B02: Real login

**Goal:** sign in with your Supabase user, stay signed in across reloads, sign out, and protect every page. Sample mode keeps working without login.

**Prerequisites:** B01 done.

## Files

| File | Change |
|------|--------|
| `lib/core/data/auth_repository.dart` | new: `AuthRepository`, `AuthFailure` |
| `lib/core/data/mock_auth_repository.dart` | new: `MockAuthRepository` |
| `lib/core/data/supabase/supabase_auth_repository.dart` | new: `SupabaseAuthRepository` |
| `lib/features/auth/cubit/auth_cubit.dart` | change: takes an `AuthRepository` |
| `lib/app/auth_config.dart` | change: `kRequireLogin` follows the mode |
| `lib/app/app.dart` | provide the right `AuthRepository` |
| `test/features/auth/auth_cubit_test.dart` | new tests |

## AuthRepository

```dart
class AuthFailure implements Exception { const AuthFailure(this.message); final String message; }

abstract interface class AuthRepository {
  String? get currentEmail;            // null when signed out
  Stream<String?> get emailChanges;    // emits on sign in, sign out, session expiry
  Future<void> signIn(String email, String password);   // throws AuthFailure
  Future<void> signOut();
}
```

- `MockAuthRepository`: holds the email in memory (initially `kMockAccountEmail`); `signIn` throws `AuthFailure('Wrong email or password. Try again.')` when the password is `wrong`, otherwise sets the email; a broadcast `StreamController` for `emailChanges`.
- `SupabaseAuthRepository`: `currentEmail` is `auth.currentSession?.user.email`; `emailChanges` is `auth.onAuthStateChange.map((s) => s.session?.user.email).distinct()`; `signIn` calls `signInWithPassword`; `signOut` calls `auth.signOut()`. Error mapping inside `signIn`:
  - `AuthException` with `statusCode == '400'` (invalid credentials) becomes `AuthFailure('Wrong email or password. Try again.')`;
  - any other `AuthException` becomes `AuthFailure('Could not sign in: ${e.message}')`;
  - any other error (network) becomes `AuthFailure('Could not reach the server. Check your connection.')`.

## AuthCubit changes

- Constructor `AuthCubit(AuthRepository repo)`. Initial state: `signedIn` with `repo.currentEmail` when non-null, otherwise `signedOut`.
- Subscribes to `repo.emailChanges` and emits `signedIn(email)` or `signedOut`; cancels in `close()`.
- `signIn(email, password)`: if either (trimmed) is empty emit `Enter your email and password.`; otherwise call the repository, and on `AuthFailure` emit its message as the error. The success path comes from the stream (and may also be set directly so the UI does not wait).
- `signOut()` calls the repository. `clearError()` stays.
- Remove the old hardcoded `wrong` rule from the cubit (it now lives only in the mock repository).

## Wiring

- `kRequireLogin` becomes `AppConfig.useSupabase` (a getter or constant derived from it). With it on, the router redirects exactly as written in Login 01.
- `App` provides `RepositoryProvider<AuthRepository>` (`SupabaseAuthRepository` when `useSupabase`, else `MockAuthRepository`) above the `AuthCubit` provider, and creates the cubit from it.
- The Account card's "Sign out" keeps calling `AuthCubit.signOut()` then going to `/login`.

## Tests (`auth_cubit_test.dart`, hand-written fake repository)

- Empty email or password sets the "Enter your email and password." error without calling the repository.
- A repository that throws `AuthFailure('x')` leaves the cubit signed out with error `x`.
- A successful sign in ends `signedIn` with the trimmed email.
- Initial state is `signedIn` when the fake has a current email.

## Do not

Build sign-up, password reset or "change password". Store the password anywhere.

## Verify

- [x] Supabase mode: the app opens on `/login`. A wrong password shows "Wrong email or password. Try again."; your real login goes to the Dashboard (it will show an error card until B05; that is fine).
- [x] Reload the browser while signed in: you stay signed in. In a private window you are asked to sign in.
- [x] Settings, Sign out: back to `/login`; typing `/transactions` in the address bar then redirects to `/login`.
- [x] `/dev/supabase` shows `Session: <your email>` when signed in.
- [x] Sample mode: opens straight on the Dashboard as before; `/login` still shows the form and password `wrong` still fails.
- [x] `flutter analyze` and `flutter test` pass.
