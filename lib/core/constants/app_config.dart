/// Application configuration.
/// Override at build time with:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class AppConfig {
  AppConfig._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://tsjlpuldbyjiijsrepjx.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
        '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRzamxwdWxkYnlqaWlqc3JlcGp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwNjc5MzUsImV4cCI6MjA4ODY0MzkzNX0'
        '.Ive58YsFOne92L7DuDmW_pDagxCDt_9Oc-w9hBJHKqs',
  );
}
