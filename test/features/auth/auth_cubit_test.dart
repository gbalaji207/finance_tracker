import 'dart:async';

import 'package:finance_tracker/core/data/auth_repository.dart';
import 'package:finance_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:finance_tracker/features/auth/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuth implements AuthRepository {
  _FakeAuth({this.email, this.failure});

  String? email;
  final AuthFailure? failure;
  int signInCalls = 0;
  final _controller = StreamController<String?>.broadcast();

  @override
  String? get currentEmail => email;

  @override
  Stream<String?> get emailChanges => _controller.stream;

  @override
  Future<void> signIn(String email, String password) async {
    signInCalls++;
    if (failure != null) throw failure!;
    this.email = email;
    _controller.add(email);
  }

  @override
  Future<void> signOut() async {
    email = null;
    _controller.add(null);
  }
}

void main() {
  test(
    'empty email or password sets an error without calling the repo',
    () async {
      final repo = _FakeAuth();
      final cubit = AuthCubit(repo);
      await cubit.signIn('  ', 'pw');
      expect(cubit.state.errorMessage, 'Enter your email and password.');
      await cubit.signIn('a@b.c', '   ');
      expect(cubit.state.errorMessage, 'Enter your email and password.');
      expect(repo.signInCalls, 0);
      await cubit.close();
    },
  );

  test('an AuthFailure leaves the cubit signed out with its message', () async {
    final cubit = AuthCubit(_FakeAuth(failure: const AuthFailure('x')));
    await cubit.signIn('a@b.c', 'pw');
    expect(cubit.state.status, AuthStatus.signedOut);
    expect(cubit.state.errorMessage, 'x');
    await cubit.close();
  });

  test('a successful sign in ends signed in with the trimmed email', () async {
    final cubit = AuthCubit(_FakeAuth());
    await cubit.signIn('  a@b.c ', 'pw');
    expect(cubit.state.status, AuthStatus.signedIn);
    expect(cubit.state.email, 'a@b.c');
    expect(cubit.state.errorMessage, isNull);
    await cubit.close();
  });

  test(
    'initial state is signed in when the repo has a current email',
    () async {
      final cubit = AuthCubit(_FakeAuth(email: 'me@x.y'));
      expect(cubit.state.status, AuthStatus.signedIn);
      expect(cubit.state.email, 'me@x.y');
      await cubit.close();
    },
  );
}
