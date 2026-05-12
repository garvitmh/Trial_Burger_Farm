/// AuthFailure — Structured domain failures for authentication operations.
///
/// Maps underlying exceptions (e.g., FirebaseAuthException) to safe,
/// domain-specific error representations that can be displayed to the user.
abstract class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
}

// ─── Network & System ──────────────────────────────────────────────────

class NetworkFailure extends AuthFailure {
  const NetworkFailure() : super('Please check your internet connection and try again.');
}

class ServerFailure extends AuthFailure {
  const ServerFailure([super.message = 'Our servers are currently unavailable. Please try again later.']);
}

// ─── OTP & Phone Auth ──────────────────────────────────────────────────

class InvalidPhoneNumberFailure extends AuthFailure {
  const InvalidPhoneNumberFailure() : super('Please enter a valid phone number.');
}

class InvalidOtpFailure extends AuthFailure {
  const InvalidOtpFailure() : super('The code entered is invalid. Please check and try again.');
}

class OtpExpiredFailure extends AuthFailure {
  const OtpExpiredFailure() : super('The verification code has expired. Please request a new one.');
}

class TooManyRequestsFailure extends AuthFailure {
  const TooManyRequestsFailure() : super('Too many attempts. Please wait a few minutes before trying again.');
}

// ─── General Auth ──────────────────────────────────────────────────────

class UserDisabledFailure extends AuthFailure {
  const UserDisabledFailure() : super('This account has been disabled. Please contact support.');
}

class OperationCanceledFailure extends AuthFailure {
  const OperationCanceledFailure() : super('The operation was canceled.');
}

class SignInCancelledFailure extends AuthFailure {
  const SignInCancelledFailure() : super('Sign-in was cancelled.');
}

class GoogleSignInConfigurationFailure extends AuthFailure {
  const GoogleSignInConfigurationFailure([
    super.message =
        'Google Sign-In is not configured correctly on this device.',
  ]);
}

class CredentialFailure extends AuthFailure {
  const CredentialFailure([
    super.message = 'Could not obtain valid credentials for sign-in.',
  ]);
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure([super.message = 'An unexpected authentication error occurred. Please try again.']);
}
