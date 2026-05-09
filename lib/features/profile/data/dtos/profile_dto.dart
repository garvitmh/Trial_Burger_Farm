// ============================================================================
// FILE: lib/features/profile/data/dtos/profile_dto.dart
// CHANGES:
//   - Created UserProfileDto for profile data transfer
//   - Created UpdateProfileRequest for profile updates
//   - Created DietaryPreferenceDto for dietary settings
// ============================================================================
import 'package:flutter/foundation.dart';

/// User profile data as returned by the backend.
@immutable
class UserProfileDto {
  final String id;
  final String? name;
  final String? email;
  final String phone;
  final String? avatarUrl;
  final DietaryPreferenceDto dietaryPreference;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfileDto({
    required this.id,
    this.name,
    this.email,
    required this.phone,
    this.avatarUrl,
    required this.dietaryPreference,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      dietaryPreference: DietaryPreferenceDto.fromJson(
        json['dietaryPreference'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'dietaryPreference': dietaryPreference.toJson(),
    };
  }
}

/// Request body for updating the user profile.
@immutable
class UpdateProfileRequest {
  final String? name;
  final String? email;
  final DietaryPreferenceDto? dietaryPreference;
  final bool? notificationEnabled;

  const UpdateProfileRequest({
    this.name,
    this.email,
    this.dietaryPreference,
    this.notificationEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (dietaryPreference != null)
        'dietaryPreference': dietaryPreference!.toJson(),
      if (notificationEnabled != null)
        'notificationEnabled': notificationEnabled,
    };
  }
}

/// Dietary preference settings.
@immutable
class DietaryPreferenceDto {
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;

  const DietaryPreferenceDto({
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
  });

  factory DietaryPreferenceDto.fromJson(Map<String, dynamic> json) {
    return DietaryPreferenceDto(
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isVegan: json['isVegan'] as bool? ?? false,
      isGlutenFree: json['isGlutenFree'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
    };
  }
}
