import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // Sign up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      if (kDebugMode) {
        print('✅ User signed up successfully: ${response.user?.email}');
      }

      // Create user record and profile after successful signup
      if (response.user != null) {
        await _createUserRecord(response.user!.id, email, role);
        await _createUserProfile(response.user!.id, fullName, role);
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Sign up failed: $error');
      }
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Sign in existing user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ User signed in successfully: ${response.user?.email}');
      }

      // Update last login
      if (response.user != null) {
        await _updateLastLogin(response.user!.id);
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Sign in failed: $error');
      }
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      if (kDebugMode) {
        print('✅ User signed out successfully');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Sign out failed: $error');
      }
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      if (kDebugMode) {
        print('✅ Password reset email sent to: $email');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Password reset failed: $error');
      }
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (kDebugMode) {
        print('✅ Password updated successfully');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Password update failed: $error');
      }
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Private helper methods
  Future<void> _createUserRecord(String userId, String email, String role) async {
    try {
      await _client.from('users').insert({
        'user_id': userId,
        'email': email,
        'role': role,
        'account_status': 'active',
        'email_verified': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('✅ User record created successfully in users table');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to create user record: $error');
      }
      rethrow; // This is critical, so we should fail the registration
    }
  }

  Future<void> _createUserProfile(String userId, String fullName, String role) async {
    try {
      await _client.from('user_profiles').insert({
        'user_id': userId,
        'first_name': fullName.split(' ').first,
        'last_name': fullName.split(' ').length > 1 ? fullName.split(' ').last : '',
        'preferred_language': 'en',
        'location_sharing_enabled': false,
        'notification_preferences': {
          'email_notifications': true,
          'push_notifications': true,
          'maintenance_reminders': true,
        },
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('✅ User profile created successfully');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to create user profile: $error');
      }
      rethrow; // This is critical, so we should fail the registration
    }
  }

  Future<void> _updateLastLogin(String userId) async {
    try {
      await _client.from('users').update({
        'last_login': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      if (kDebugMode) {
        print('✅ Last login updated');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to update last login: $error');
      }
      // Don't rethrow here as the main signin was successful
    }
  }
}
