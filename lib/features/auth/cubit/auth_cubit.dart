import 'dart:async';

import 'package:finance_tracker/core/data/auth_repository.dart';
import 'package:finance_tracker/features/auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo)
    : super(
        _repo.currentEmail != null
            ? AuthState(status: AuthStatus.signedIn, email: _repo.currentEmail!)
            : const AuthState(),
      ) {
    _subscription = _repo.emailChanges.listen(_onEmail);
  }

  final AuthRepository _repo;
  late final StreamSubscription<String?> _subscription;

  void _onEmail(String? email) {
    if (isClosed) return;
    emit(
      email == null
          ? const AuthState()
          : AuthState(status: AuthStatus.signedIn, email: email),
    );
  }

  Future<void> signIn(String email, String password) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.trim().isEmpty) {
      emit(_withError('Enter your email and password.'));
      return;
    }
    try {
      await _repo.signIn(trimmedEmail, password);
      // The stream also reports this; set it directly so the UI need not wait.
      if (!isClosed) {
        emit(AuthState(status: AuthStatus.signedIn, email: trimmedEmail));
      }
    } on AuthFailure catch (e) {
      if (!isClosed) emit(_withError(e.message));
    }
  }

  Future<void> signOut() => _repo.signOut();

  void clearError() =>
      emit(AuthState(status: state.status, email: state.email));

  /// Keeps the current status and email; only the message changes.
  AuthState _withError(String message) => AuthState(
    status: state.status,
    email: state.email,
    errorMessage: message,
  );

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
