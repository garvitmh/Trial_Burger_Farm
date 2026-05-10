import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/value_objects/auth_failures.dart';

/// AuthExceptionMapper — Translates raw Firebase exceptions into safe domain failures.
///
/// Prevents data-layer leakage and ensures UI components only deal with
/// structured, user-friendly domain errors.
abstract final class AuthExceptionMapper {
  static AuthFailure map(Object error) {
    if (error is FirebaseAuthException) {
      return _mapFirebaseException(error);
    }
    
    // Handle network specific errors or generic fallbacks
    // TODO: Add specific connectivity checks if needed
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
      case 'web-context-cancelled':
      case 'credential-already-in-use':
        return const OperationCanceledFailure();
      default:
        return UnknownAuthFailure(e.message ?? 'An unexpected authentication error occurred.');
    }
  }
}
