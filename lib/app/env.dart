class Env {
  Env._();

  // Paste your Supabase project URL and anon/publishable key here.
  static const supabaseUrl = 'https://tifoduyhndfooxywuvjw.supabase.co';
  static const supabaseAnonKey = 'sb_publishable_gESxYt5TcZBo1SdqqvJT4A_zkctbDSe';


  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') &&
      !supabaseUrl.contains('YOUR_') &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseAnonKey.contains('YOUR_');
}
