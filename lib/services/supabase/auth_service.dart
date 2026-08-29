import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:neend_companion/services/supabase/supabase_service.dart';

/// Authentication service wrapping Supabase Auth.
///
/// For MVP, authentication is optional — the app works fully
/// with local storage. Auth is required only for:
/// - AI API calls (Edge Functions require auth token)
/// - Cloud sync (future)
///
/// Supports email/password auth for MVP.
/// Can be extended with Google, Apple, OTP login later.
class AuthService {
  final SupabaseClient _client;

  AuthService() : _client = SupabaseService.client;

  /// Current authenticated user.
  User? get currentUser => _client.auth.currentUser;

  /// Whether user is signed in.
  bool get isSignedIn => currentUser != null;

  /// Auth state change stream.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in anonymously (for MVP - allows AI calls without full registration).
  Future<AuthResponse> signInAnonymously() async {
    return await _client.auth.signInAnonymously();
  }

  /// Sign out.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get current session token (for Edge Function calls).
  String? get accessToken => _client.auth.currentSession?.accessToken;

  /// Refresh session if expired.
  Future<AuthResponse> refreshSession() async {
    return await _client.auth.refreshSession();
  }

  /// Delete user account and all associated data.
  /// Note: This requires a server-side function in production.
  Future<void> deleteAccount() async {
    // In production, call an Edge Function that:
    // 1. Deletes all user data from tables
    // 2. Deletes user from auth.users
    // For MVP, just sign out
    await signOut();
  }
}
