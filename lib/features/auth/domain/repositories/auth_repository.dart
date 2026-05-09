import 'package:burger_farm_app/features/auth/domain/entities/user_entity.dart';

/// Repository contract for authentication operations.
///
/// Abstracts Firebase and backend auth operations so the UI layer
/// is never coupled to specific auth implementations.
abstract class AuthRepository {
  /// Sends OTP to the given phone number.
  /// Returns the verificationId from Firebase.
  Future<String> sendOtp(String phoneNumber);

  /// Verifies OTP using verificationId and smsCode.
  /// Then sends the Firebase idToken to the Node.js backend.
  /// Returns the [UserEntity] with the backend JWT token.
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Signs in the user using Google Sign-In.
  /// Then sends the Firebase idToken to the Node.js backend.
  /// Returns the [UserEntity] with the backend JWT token.
  Future<UserEntity?> signInWithGoogle();

  /// Signs out the current user from all auth providers.
  Future<void> signOut();
}
