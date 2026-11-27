import 'package:finance_tracker/core/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A short, friendly message for any error a repository call can throw.
String friendlyError(Object e) {
  if (e is PostgrestException) {
    return switch (e.code) {
      '23505' => 'That name is already used.',
      '23503' =>
        'This item is still in use, so it cannot be removed. Archive it '
            'instead.',
      '23514' => 'Some values are not allowed. Check the form.',
      _ => 'The server rejected the request: ${e.message}',
    };
  }
  if (e is AuthException) return e.message;
  if (e is AuthFailure) return e.message;
  final text = e.toString();
  if (text.contains('Failed to fetch') ||
      text.contains('ClientException') ||
      text.contains('SocketException')) {
    return 'Could not reach the server. Check your connection.';
  }
  return 'Something went wrong. Try again.';
}
