import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Sends OTP to the given phone number.
  /// Returns the verificationId from Firebase.
  Future<String> sendOtp(String phoneNumber);

  /// Verifies OTP using verificationId and smsCode.
  /// Then sends the Firebase idToken to the Node.js backend.
  /// Returns the UserEntity with the backend JWT token.
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  });
}
