import 'dart:async';

import 'package:finance_tracker/app/auth_config.dart';
import 'package:finance_tracker/core/data/auth_repository.dart';

/// Sample-mode authentication: in memory only. The password `wrong` fails so
/// the error state can be seen.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({String? initialEmail = kMockAccountEmail})
    : _email = initialEmail;

  String? _email;
  final _controller = StreamController<String?>.broadcast();

  @override
  String? get currentEmail => _email;

  @override
  Stream<String?> get emailChanges => _controller.stream;

  @override
  Future<void> signIn(String email, String password) async {
    if (password == 'wrong') {
      throw const AuthFailure('Wrong email or password. Try again.');
    }
    _email = email;
    _controller.add(_email);
  }

  @override
  Future<void> signOut() async {
    _email = null;
    _controller.add(null);
  }
}
