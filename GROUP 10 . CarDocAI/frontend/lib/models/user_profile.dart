import 'dart:convert';

class UserProfile {
  final String profileId;
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String preferredLanguage;
  final Map<String, dynamic>? notificationPreferences;
  final bool locationSharingEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.profileId,
    required this.userId,
    this.firstName,
    this.lastName,
    this.phone,
    required this.preferredLanguage,
    this.notificationPreferences,
    required this.locationSharingEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      profileId: json['profile_id'],
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      preferredLanguage: json['preferred_language'],
      notificationPreferences: json['notification_preferences'] != null 
          ? jsonDecode(json['notification_preferences'])
          : null,
      locationSharingEnabled: json['location_sharing_enabled'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'preferred_language': preferredLanguage,
      'notification_preferences': notificationPreferences != null 
          ? jsonEncode(notificationPreferences)
          : null,
      'location_sharing_enabled': locationSharingEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 