import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cardocai/models/mechanic.dart';
import 'dart:math' as math;

class MechanicRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all mechanics with optional search and filtering
  Future<List<Mechanic>> getMechanics({
    String? searchQuery,
    String? sortBy = 'rating', // rating, distance, reviews
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      var query = _supabase.from('mechanics').select('*');

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'business_name.ilike.%$searchQuery%,'
          'certifications.cs.{$searchQuery}'
        );
      }

      // Execute query
      final response = await query;
      
      List<Mechanic> mechanics = (response as List)
          .map((json) => Mechanic.fromJson(json))
          .toList();

      // Apply sorting
      switch (sortBy) {
        case 'rating':
          mechanics.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          break;
        case 'distance':
          if (userLatitude != null && userLongitude != null) {
            mechanics.sort((a, b) {
              double distanceA = _calculateDistance(
                userLatitude, userLongitude, 
                a.latitude ?? 0, a.longitude ?? 0
              );
              double distanceB = _calculateDistance(
                userLatitude, userLongitude, 
                b.latitude ?? 0, b.longitude ?? 0
              );
              return distanceA.compareTo(distanceB);
            });
          }
          break;
        case 'reviews':
          // For now, sort by rating as we don't have review count in schema
          mechanics.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          break;
      }

      return mechanics;
    } catch (e) {
      print('Error fetching mechanics: $e');
      throw Exception('Failed to load mechanics: $e');
    }
  }

  // Get mechanic by ID
  Future<Mechanic?> getMechanicById(String mechanicId) async {
    try {
      final response = await _supabase
          .from('mechanics')
          .select('*')
          .eq('mechanic_id', mechanicId)
          .single();

      return Mechanic.fromJson(response);
    } catch (e) {
      print('Error fetching mechanic: $e');
      return null;
    }
  }

  // Get mechanics near user location
  Future<List<Mechanic>> getNearbyMechanics({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    try {
      // For now, get all mechanics and filter by distance
      // In production, you'd use PostGIS for spatial queries
      final allMechanics = await getMechanics();
      
      return allMechanics.where((mechanic) {
        if (mechanic.latitude == null || mechanic.longitude == null) {
          return false;
        }
        
        double distance = _calculateDistance(
          latitude, longitude,
          mechanic.latitude!, mechanic.longitude!
        );
        
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      print('Error fetching nearby mechanics: $e');
      throw Exception('Failed to load nearby mechanics: $e');
    }
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = 
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) * 
        math.pow(math.sin(dLon / 2), 2);
    
    double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
