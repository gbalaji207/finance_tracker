abstract final class AppConfig {
  static const useSupabase = bool.fromEnvironment('USE_SUPABASE');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Adds the sample-mode suffix to a confirmation message.
  static String note(String message) =>
      useSupabase ? message : '$message (sample data, nothing is stored yet)';
}
