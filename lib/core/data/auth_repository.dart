class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  /// Null when signed out.
  String? get currentEmail;

  /// Emits on sign in, sign out and session expiry.
  Stream<String?> get emailChanges;

  /// Throws [AuthFailure] with a message that is safe to show.
  Future<void> signIn(String email, String password);

  Future<void> signOut();
}
