abstract final class SupabaseConfig {
  /// For security reasons, these should ideally be stored in environment variables or a secure vault, not hardcoded.
  /// For testing purpose, you can replace these with your actual Supabase project URL and anon key.
  static const String url = 'https://gneuqiffsvvxsfwnhbhx.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImduZXVxaWZmc3Z2eHNmd25oYmh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNDU4MjEsImV4cCI6MjA4OTgyMTgyMX0.L8iVBvrD0oRBwQeEdQOlI73llZ7S3CF4kFGPjZn5rxc';

  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      url != 'YOUR_SUPABASE_URL' &&
      anonKey != 'YOUR_SUPABASE_ANON_KEY';
}
