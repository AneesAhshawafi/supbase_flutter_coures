import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supbase_flutter_coures/core/constants/app_config.dart';
import 'package:supbase_flutter_coures/screans/addnote.dart';
import 'package:supbase_flutter_coures/screans/auth.dart';
import 'package:supbase_flutter_coures/screans/home.dart';
import 'package:supbase_flutter_coures/shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final session = snapshot.data?.session;
          return session != null ? const Home() : const AuthPage();
        },
      ),
      routes: {
        'home': (context) => const Home(),
        'auth': (context) => const AuthPage(),
        'addnote': (context) => const Addnote(),
      },
    );
  }
}
