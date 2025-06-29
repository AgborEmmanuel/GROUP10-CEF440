import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;

  // Singleton pattern
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseService._();

  SupabaseClient get client => _client;

  // Initialize Supabase
  static Future<void> initialize() async {
    // Replace these with your actual Supabase credentials
    const supabaseUrl = 'https://ggumdxyknjtwuptzboor.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdndW1keHlrbmp0d3VwdHpib29yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3MDUwMzksImV4cCI6MjA2NjI4MTAzOX0.YFwc_ggMEuGfR_BAGRfbQTKcgxG76o_a0A17FI6jfk4';

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode, // Only show debug logs in development
      );

      _instance = SupabaseService._();
      _instance!._client = Supabase.instance.client;
      
      if (kDebugMode) {
        print('✅ Supabase initialized successfully!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Supabase initialization failed: $e');
      }
      rethrow;
    }
  }

  // Helper method to get the current user's ID
  String? get currentUserId => _client.auth.currentUser?.id;

  // Helper method to check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  // Helper method to get the current session
  Session? get currentSession => _client.auth.currentSession;

  // Test database connection
  Future<bool> testConnection() async {
    try {
      final response = await _client
          .from('warning_lights')
          .select('count')
          .limit(1);
      
      if (kDebugMode) {
        print('✅ Database connection test successful!');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Database connection test failed: $e');
      }
      return false;
    }
  }

  // Generic error handler
  void handleError(dynamic error) {
    if (error is PostgrestException) {
      if (kDebugMode) {
        print('Database error: ${error.message}');
        print('Details: ${error.details}');
        print('Hint: ${error.hint}');
      }
    } else if (error is AuthException) {
      if (kDebugMode) {
        print('Authentication error: ${error.message}');
      }
    } else {
      if (kDebugMode) {
        print('Unknown error: $error');
      }
    }
    throw error;
  }
}
