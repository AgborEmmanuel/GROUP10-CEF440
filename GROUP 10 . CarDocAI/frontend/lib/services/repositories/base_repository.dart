import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

abstract class BaseRepository {
  final SupabaseClient _client = SupabaseService.instance.client;
  
  SupabaseClient get client => _client;
  
  String get tableName;
  
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .execute();
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getById(String id) async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .eq('id', id)
          .single()
          .execute();
      return response.data as Map<String, dynamic>;
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getByField(String field, dynamic value) async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .eq(field, value)
          .execute();
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from(tableName)
          .insert(data)
          .select()
          .single()
          .execute();
      return response.data as Map<String, dynamic>;
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single()
          .execute();
      return response.data as Map<String, dynamic>;
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }
  
  Future<void> delete(String id) async {
    try {
      await _client
          .from(tableName)
          .delete()
          .eq('id', id)
          .execute();
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> query({
    String? select,
    Map<String, dynamic>? equals,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      var query = _client.from(tableName).select(select ?? '*');
      
      if (equals != null) {
        equals.forEach((key, value) {
          query = query.eq(key, value);
        });
      }
      
      if (orderBy != null) {
        query = descending 
            ? query.order(orderBy, ascending: false)
            : query.order(orderBy);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query.execute();
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (error) {
      SupabaseService.instance.handleError(error);
      rethrow;
    }
  }
} 