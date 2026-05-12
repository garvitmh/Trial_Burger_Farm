import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a global instance of SecureStorageService.
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

/// SecureStorageService — Wrapper for encrypted on-device storage.
///
/// Used exclusively for sensitive data:
/// - Firebase Auth Custom Tokens
/// - Backend JWTs (Future)
/// - Refresh Tokens
///
/// DO NOT use this for non-sensitive preferences (e.g., theme, onboarding state).
/// Use SharedPreferences for non-sensitive data instead.
class SecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  // ─── Keys ─────────────────────────────────────────────────────────
  static const String _keyAuthToken = 'auth_token';
  static const String _keySessionState = 'session_state';
  static const String _keyOtpVerificationId = 'otp_verification_id';

  // ─── Read/Write Methods ───────────────────────────────────────────

  /// Saves the active authentication token securely.
  Future<void> saveAuthToken(String token) async {
    await _storage.write(
      key: _keyAuthToken,
      value: token,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  /// Retrieves the stored authentication token.
  Future<String?> getAuthToken() async {
    return await _storage.read(
      key: _keyAuthToken,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  /// Clears all secure auth data during logout.
  Future<void> clearSession() async {
    await _storage.delete(key: _keyAuthToken, aOptions: _getAndroidOptions(), iOptions: _getIOSOptions());
    await _storage.delete(key: _keySessionState, aOptions: _getAndroidOptions(), iOptions: _getIOSOptions());
    await clearVerificationId();
  }

  // ─── OTP verificationId persistence ───────────────────────────────
  // Phone-auth flow on Android requires the user to leave the app to read
  // the SMS. When the Dart isolate is suspended, the in-memory verificationId
  // held by OtpController is lost. Persisting it here keeps the OTP step
  // recoverable across backgrounding.

  Future<void> saveVerificationId(String verificationId) async {
    await _storage.write(
      key: _keyOtpVerificationId,
      value: verificationId,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  Future<String?> getVerificationId() async {
    return _storage.read(
      key: _keyOtpVerificationId,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  Future<void> clearVerificationId() async {
    await _storage.delete(
      key: _keyOtpVerificationId,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  /// Deletes all data. Use with caution (e.g., on first install or account deletion).
  Future<void> deleteAll() async {
    await _storage.deleteAll(aOptions: _getAndroidOptions(), iOptions: _getIOSOptions());
  }

  // ─── Platform Specific Options ────────────────────────────────────

  AndroidOptions _getAndroidOptions() => const AndroidOptions();

  IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      );
}
