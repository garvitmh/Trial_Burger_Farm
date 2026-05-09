import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:burger_farm_app/core/config/app_config.dart';
import 'package:burger_farm_app/features/auth/data/datasources/auth_error_mapper.dart';

/// Data source for Firebase Authentication operations.
///
/// All Firebase interactions are centralized here. [FirebaseAuth] and
/// [GoogleSignIn] are injected via constructor for testability.
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Sends OTP to the given phone number.
  /// Returns the verification ID from Firebase.
  Future<String> sendOtp(String phoneNumber) async {
    final completer = Completer<String>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: AppConfig.otpTimeout,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification on Android — sign in directly
        if (!completer.isCompleted) {
          try {
            final result = await _firebaseAuth.signInWithCredential(credential);
            // Use the credential's verification ID if available
            completer.complete(result.additionalUserInfo?.providerId ?? 'auto-verified');
          } catch (e) {
            completer.completeError(e);
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Called when auto-verification times out
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  /// Verifies OTP using verificationId and smsCode.
  /// Returns the [UserCredential] from Firebase.
  Future<UserCredential> verifyOtp(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  /// Signs in with Google.
  /// Returns the [UserCredential] or null if user canceled.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      // Handle specific Google Sign-In errors
      if (e.toString().contains('sign_in_canceled') ||
          e.toString().contains('canceled')) {
        return null;
      }
      if (e.toString().contains('network_error') ||
          e.toString().contains('network')) {
        throw FirebaseAuthException(
          code: 'network_error',
          message: 'Network error. Please check your internet connection.',
        );
      }
      if (e.toString().contains('account_exists')) {
        throw FirebaseAuthException(
          code: 'account-exists-with-different-credential',
          message: 'An account already exists with the same email.',
        );
      }
      rethrow;
    }
  }

  /// Signs out from Firebase and Google Sign-In.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
