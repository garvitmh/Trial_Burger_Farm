// ============================================================================
// FILE: lib/features/profile/data/repositories/mock_profile_repository.dart
// CHANGES:
//   - Created mock profile repository that logs to console
//   - Used until the backend profile endpoints are ready
// ============================================================================
import 'dart:developer' as developer;
import 'package:burger_farm_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:burger_farm_app/features/profile/data/dtos/profile_dto.dart';

/// Mock implementation of [ProfileRepository] that logs operations to console.
///
/// TODO: Replace with [ProfileRepositoryImpl] when backend endpoints are live.
class MockProfileRepository implements ProfileRepository {
  static const String _tag = 'MOCK_PROFILE';

  UserProfileDto _mockProfile = const UserProfileDto(
    id: 'mock-user-id',
    name: 'Guest User',
    email: 'guest@burgerfarm.app',
    phone: '+919876543210',
    dietaryPreference: DietaryPreferenceDto(
      isVegetarian: false,
      isVegan: false,
      isGlutenFree: false,
    ),
  );

  @override
  Future<UserProfileDto> getProfile() async {
    developer.log('getProfile() called', name: _tag);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _mockProfile;
  }

  @override
  Future<UserProfileDto> updateProfile(UpdateProfileRequest request) async {
    developer.log('updateProfile($request) called', name: _tag);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _mockProfile = UserProfileDto(
      id: _mockProfile.id,
      name: request.name ?? _mockProfile.name,
      email: request.email ?? _mockProfile.email,
      phone: _mockProfile.phone,
      avatarUrl: _mockProfile.avatarUrl,
      dietaryPreference: request.dietaryPreference ?? _mockProfile.dietaryPreference,
    );
    return _mockProfile;
  }

  @override
  Future<DietaryPreferenceDto> updateDietaryPreference(
    DietaryPreferenceDto preference,
  ) async {
    developer.log('updateDietaryPreference($preference) called', name: _tag);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return preference;
  }
}
