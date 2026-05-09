// ============================================================================
// FILE: lib/core/services/secure_storage_service.dart
// CHANGES:
//   - Created flutter_secure_storage wrapper for JWT token management
//   - Provides typed methods for token persistence
// ============================================================================
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keys used for secure storage.
abstract final class _StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userPhone = 'user_phone';
}

/// Secure storage service for sensitive auth data.
///
/// Uses [FlutterSecureStorage] to persist tokens beyond app restarts.
/// All methods are static for global access without DI overhead.
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accountName: 'burger_farm_secure_storage',
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Stores the access token (JWT from backend).
  static Future<void> setAccessToken(String token) async {
    await _storage.write(key: _StorageKeys.accessToken, value: token);
  }

  /// Retrieves the access token.
  static Future<String?> getAccessToken() async {
    return _storage.read(key: _StorageKeys.accessToken);
  }

  /// Stores the refresh token.
  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _StorageKeys.refreshToken, value: token);
  }

  /// Retrieves the refresh token.
  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _StorageKeys.refreshToken);
  }

  /// Stores user ID.
  static Future<void> setUserId(String userId) async {
    await _storage.write(key: _StorageKeys.userId, value: userId);
  }

  /// Retrieves user ID.
  static Future<String?> getUserId() async {
    return _storage.read(key: _StorageKeys.userId);
  }

  /// Stores user phone number.
  static Future<void> setUserPhone(String phone) async {
    await _storage.write(key: _StorageKeys.userPhone, value: phone);
  }

  /// Retrieves user phone number.
  static Future<String?> getUserPhone() async {
    return _storage.read(key: _StorageKeys.userPhone);
  }

  /// Clears all stored auth data. Call on sign-out.
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Whether the user has a stored access token (persists across restarts).
  static Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
