import 'package:cardocai/models/user.dart';
import 'package:cardocai/models/user_profile.dart';
import 'base_repository.dart';

class UserRepository extends BaseRepository {
  @override
  String get tableName => 'users';

  // Get user with profile
  Future<Map<String, dynamic>> getUserWithProfile(String userId) async {
    try {
      final response = await client
          .from(tableName)
          .select('''
            *,
            user_profiles (*)
          ''')
          .eq('user_id', userId)
          .single()
          .execute();
      return response.data as Map<String, dynamic>;
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Create or update user profile
  Future<UserProfile> upsertProfile(UserProfile profile) async {
    try {
      final response = await client
          .from('user_profiles')
          .upsert(profile.toJson())
          .select()
          .single()
          .execute();
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Update user status
  Future<User> updateUserStatus(String userId, String status) async {
    try {
      final response = await client
          .from(tableName)
          .update({'account_status': status})
          .eq('user_id', userId)
          .select()
          .single()
          .execute();
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('email', email)
          .single()
          .execute();
      if (response.data == null) return null;
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Update user role
  Future<User> updateUserRole(String userId, String role) async {
    try {
      final response = await client
          .from(tableName)
          .update({'role': role})
          .eq('user_id', userId)
          .select()
          .single()
          .execute();
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Get all active users
  Future<List<User>> getActiveUsers() async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('account_status', 'active')
          .execute();
      return (response.data as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }

  // Update last login
  Future<void> updateLastLogin(String userId) async {
    try {
      await client
          .from(tableName)
          .update({
            'last_login': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .execute();
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }
} 