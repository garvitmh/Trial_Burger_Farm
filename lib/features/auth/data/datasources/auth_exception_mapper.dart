import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show PlatformException;
import '../../domain/value_objects/auth_failures.dart';

/// AuthExceptionMapper — Translates raw Firebase exceptions into safe domain failures.
///
/// Prevents data-layer leakage and ensures UI components only deal with
/// structured, user-friendly domain errors.
abstract final class AuthExceptionMapper {
  static AuthFailure map(Object error) {
    if (error is AuthFailure) return error;
    if (error is FirebaseAuthException) {
      return _mapFirebaseException(error);
    }
    if (error is PlatformException) {
      return _mapPlatformException(error);
    }
    return const UnknownAuthFailure();
  }

  static AuthFailure _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return const InvalidPhoneNumberFailure();
      case 'invalid-verification-code':
        return const InvalidOtpFailure();
      case 'session-expired':
        return const OtpExpiredFailure();
      case 'quota-exceeded':
      case 'too-many-requests':
        return const TooManyRequestsFailure();
      case 'user-disabled':
        return const UserDisabledFailure();
      case 'network-request-failed':
        return const NetworkFailure();
      case 'sign_in_cancelled':
      case 'web-context-cancelled':
        return const SignInCancelledFailure();
      case 'credential-already-in-use':
        return const OperationCanceledFailure();
      case 'invalid-credential':
        return const CredentialFailure();
      default:
        return UnknownAuthFailure(e.message ?? 'An unexpected authentication error occurred.');
    }
  }

  /// PlatformExceptions are thrown by the google_sign_in plugin when the
  /// device or Firebase project is misconfigured (missing OAuth client,
  /// SHA-1 mismatch, Google Play Services unavailable, etc.).
  static AuthFailure _mapPlatformException(PlatformException e) {
    switch (e.code) {
      case 'sign_in_canceled':
      case 'sign_in_cancelled':
        return const SignInCancelledFailure();
      case 'network_error':
        return const NetworkFailure();
      case 'sign_in_failed':
        return GoogleSignInConfigurationFailure(
          e.message ?? 'Google Sign-In failed. Check device configuration.',
        );
      default:
        return UnknownAuthFailure(e.message ?? 'Authentication failed.');
    }
  }
}
