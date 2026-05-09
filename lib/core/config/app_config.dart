// ============================================================================
// FILE: lib/core/config/app_config.dart
// CHANGES:
//   - Extracted _phase0FirebaseOnlyMode from AuthRepositoryImpl
//   - Centralized environment configuration for testability
//   - Added feature flags for gradual rollouts
// ============================================================================
import 'package:flutter/foundation.dart';

/// Centralized application configuration.
/// All environment-specific flags live here — never hardcode in repositories.
abstract final class AppConfig {
  AppConfig._();

  /// Phase 0: Skip Node.js backend, use Firebase only.
  /// Set to `false` in production to enable full backend JWT exchange.
  static const bool useFirebaseOnlyMode = true;

  /// Whether to enable debug logging for network requests.
  static bool get enableNetworkLogging => kDebugMode;

  /// OTP timeout duration for Firebase phone verification.
  static const Duration otpTimeout = Duration(seconds: 60);

  /// Base URL for the Node.js backend API.
  static const String baseApiUrl = 'http://10.0.2.2:5000';
}
