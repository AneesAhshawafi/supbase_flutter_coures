import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSupa {
  final supaAuth = Supabase.instance.client.auth;

  signUp(String email, String password) async {
    await supaAuth.signUp(email: email, password: password);
  }

  signin(String email, String password) async {
    await supaAuth.signInWithPassword(email: email, password: password);
  }

  logout() async {
    await supaAuth.signOut();
  }
}
