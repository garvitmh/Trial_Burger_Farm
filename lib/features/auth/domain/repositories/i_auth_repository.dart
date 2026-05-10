import '../entities/auth_user.dart';

/// IAuthRepository — Abstract interface for authentication data operations.
///
/// Ensures the domain layer is decoupled from Firebase.
/// The presentation layer should ONLY interact with this interface or UseCases.
abstract interface class IAuthRepository {
  /// Stream of current user authentication state.
  /// Yields [null] if unauthenticated.
  Stream<AuthUser?> get authStateChanges;

  /// Retrieves the current user synchronously if available.
  AuthUser? get currentUser;

  /// Initiates phone number verification.
  /// Uses callbacks to handle the multi-step OTP flow cleanly.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(Exception error) verificationFailed,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  });

  /// Verifies the OTP code sent to the user's phone.
  Future<AuthUser> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Authenticates using Google Sign-In.
  Future<AuthUser> signInWithGoogle();

  /// Signs out the current user and clears session tokens.
  Future<void> signOut();
}
