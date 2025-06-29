import 'dart:convert';

class Mechanic {
  final String mechanicId;
  final String businessName;
  final String? contactPhone;
  final String? contactEmail;
  final String? website;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final Map<String, dynamic>? workingHours;
  final List<String> certifications;
  final DateTime createdAt;

  Mechanic({
    required this.mechanicId,
    required this.businessName,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.address,
    this.latitude,
    this.longitude,
    this.rating,
    this.workingHours,
    required this.certifications,
    required this.createdAt,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      mechanicId: json['mechanic_id']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      website: json['website']?.toString(),
      address: json['address']?.toString(),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      rating: _parseDouble(json['rating']),
      workingHours: _parseWorkingHours(json['working_hours']),
      certifications: _parseCertifications(json['certifications']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Map<String, dynamic>? _parseWorkingHours(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is String) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static List<String> _parseCertifications(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        // If it's a simple string, return as single item
        return [value];
      }
    }
    return [];
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'mechanic_id': mechanicId,
      'business_name': businessName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'website': website,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'working_hours': workingHours != null ? jsonEncode(workingHours) : null,
      'certifications': certifications,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
