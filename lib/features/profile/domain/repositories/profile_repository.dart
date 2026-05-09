// ============================================================================
// FILE: lib/features/profile/domain/repositories/profile_repository.dart
// CHANGES:
//   - Created ProfileRepository interface
// ============================================================================
import 'package:burger_farm_app/features/profile/data/dtos/profile_dto.dart';

/// Repository contract for user profile operations.
abstract class ProfileRepository {
  /// Fetches the current user's profile.
  Future<UserProfileDto> getProfile();

  /// Updates the user's profile.
  Future<UserProfileDto> updateProfile(UpdateProfileRequest request);

  /// Updates dietary preferences only.
  Future<DietaryPreferenceDto> updateDietaryPreference(
    DietaryPreferenceDto preference,
  );
}
