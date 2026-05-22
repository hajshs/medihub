// ─────────────────────────────────────────────────────────────────────────────
// SUPABASE CONFIGURATION
// Replace these values with your actual Supabase project credentials.
// Find them at: Supabase Dashboard → Project Settings → API
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseConfig {
  // Your Supabase project URL
  // Example: 'https://xyzabc.supabase.co'
  static const String supabaseUrl = 'https://knxypvmywbkvvibijwzu.supabase.co';

  // Your anon/public key (safe to use in client apps)
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtueHlwdm15d2JrdnZpYmlqd3p1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkzNjU2NTcsImV4cCI6MjA5NDk0MTY1N30.d08InJUATfkm7LSgHNbgjQsx3ngX6d5Sx9S1KjSr8WY';

  // Storage bucket name (create this in Supabase Dashboard → Storage)
  static const String storageBucket = 'medihub-files';
}
