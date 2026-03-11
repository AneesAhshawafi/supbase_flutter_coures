import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supbase_flutter_coures/core/errors/app_exception.dart';

/// Authentication service — wraps Supabase Auth with typed exceptions.
class AuthService {
  final _auth = Supabase.instance.client.auth;

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.signUp(email: email.trim(), password: password);
    } catch (e) {
      throw AuthException('Sign up failed. Please try again.', originalError: e);
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      throw AuthException(
        'Sign in failed. Check your credentials.',
        originalError: e,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Logout failed.', originalError: e);
    }
  }
}
