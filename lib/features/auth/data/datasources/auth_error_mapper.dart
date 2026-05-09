// ============================================================================
// FILE: lib/features/auth/data/datasources/auth_error_mapper.dart
// CHANGES:
//   - Created centralized Firebase Auth error mapper
//   - Maps FirebaseAuthException codes to user-friendly messages
// ============================================================================
import 'package:firebase_auth/firebase_auth.dart';

/// Maps Firebase authentication error codes to user-friendly display messages.
///
/// This ensures consistent error handling across all auth flows (OTP, Google, Apple).
String mapFirebaseAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      // Phone OTP errors
      case 'invalid-phone-number':
        return 'The phone number entered is invalid. Please check and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'session-expired':
        return 'The OTP session has expired. Please request a new code.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check the code and try again.';
      case 'invalid-verification-id':
        return 'Verification failed. Please restart the login process.';
      case 'credential-already-in-use':
        return 'This phone number is already linked to another account.';
      // Google Sign-In errors
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in method.';
      case 'popup-closed-by-user':
      case 'cancelled':
      case 'sign_in_canceled':
        return 'Sign-in was cancelled.';
      case 'network-request-failed':
      case 'network_error':
        return 'Network error. Please check your internet connection.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      // General errors
      case 'timeout':
        return 'The request timed out. Please try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  if (error is Exception) {
    return 'Something went wrong. Please try again.';
  }

  return error.toString();
}
