import 'package:finance_tracker/core/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  String? get currentEmail => _auth.currentSession?.user.email;

  @override
  Stream<String?> get emailChanges =>
      _auth.onAuthStateChange.map((s) => s.session?.user.email).distinct();

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      if (e.statusCode == '400') {
        throw const AuthFailure('Wrong email or password. Try again.');
      }
      throw AuthFailure('Could not sign in: ${e.message}');
    } catch (_) {
      throw const AuthFailure(
        'Could not reach the server. Check your connection.',
      );
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
