import 'package:finance_tracker/app/auth_config.dart';
import 'package:finance_tracker/features/auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mock authentication: nothing leaves the app and nothing is stored.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit()
      : super(
          kRequireLogin
              ? const AuthState()
              : const AuthState(
                  status: AuthStatus.signedIn,
                  email: kMockAccountEmail,
                ),
        );

  void signIn(String email, String password) {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.trim().isEmpty) {
      emit(_withError('Enter your email and password.'));
    } else if (password == 'wrong') {
      // Only exists so the error state can be seen; it goes away with real
      // authentication.
      emit(_withError('Wrong email or password. Try again.'));
    } else {
      emit(AuthState(status: AuthStatus.signedIn, email: trimmedEmail));
    }
  }

  void signOut() => emit(const AuthState());

  void clearError() => emit(
        AuthState(status: state.status, email: state.email),
      );

  /// Keeps the current status and email; only the message changes.
  AuthState _withError(String message) => AuthState(
        status: state.status,
        email: state.email,
        errorMessage: message,
      );
}
