import 'package:equatable/equatable.dart';

enum AuthStatus { signedOut, signedIn }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.signedOut,
    this.email = '',
    this.errorMessage,
  });

  final AuthStatus status;
  final String email;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, email, errorMessage];
}
