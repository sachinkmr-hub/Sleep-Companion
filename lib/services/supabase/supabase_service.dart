import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service wrapper for backend operations.
///
/// Handles initialization and provides access to Supabase client.
/// For MVP, most data is stored locally. Supabase is used for:
/// - Authentication
/// - AI API proxy (Edge Functions)
/// - Cloud sync (future)
/// - Voice recording storage (future)
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase with project credentials.
  /// Call this in main.dart before runApp.
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  /// Check if Supabase is configured and reachable.
  static bool get isInitialized {
    try {
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get current authenticated user, if any.
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated.
  static bool get isAuthenticated => currentUser != null;

  /// Invoke a Supabase Edge Function.
  static Future<FunctionResponse> invokeFunction(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    return await client.functions.invoke(
      functionName,
      body: body ?? {},
    );
  }
}
