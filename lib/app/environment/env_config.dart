import 'app_environment.dart';

/// EnvConfig — Burger Farm Environment Configuration
///
/// Defines environment-specific config values.
/// Actual secrets MUST be injected at build-time via --dart-define.
/// DO NOT hardcode API keys, Firebase config, or any secrets here.
///
/// Usage (at launch):
///   flutter run --dart-define=ENVIRONMENT=development
///   flutter run --dart-define=ENVIRONMENT=production --dart-define=API_URL=https://...
///
/// Access:
///   final config = EnvConfig.current;
///   config.apiBaseUrl;
class EnvConfig {
  const EnvConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String appName;

  // ─── Factory Constructors per Environment ─────────────────────────────────

  factory EnvConfig.development() => const EnvConfig._(
        environment: AppEnvironment.development,
        // Use dart-define to inject actual local or tunnel URLs
        apiBaseUrl: 'https://dev-api.burgerfarm.app',
        appName: 'Burger Farm [DEV]',
      );

  factory EnvConfig.staging() => const EnvConfig._(
        environment: AppEnvironment.staging,
        apiBaseUrl: 'https://staging-api.burgerfarm.app',
        appName: 'Burger Farm [STAGING]',
      );

  factory EnvConfig.production() => const EnvConfig._(
        environment: AppEnvironment.production,
        apiBaseUrl: 'https://api.burgerfarm.app',
        appName: 'Burger Farm',
      );

  // ─── Runtime Resolution ───────────────────────────────────────────────────

  /// Reads --dart-define ENVIRONMENT at compile time.
  /// Defaults to development if not specified.
  static const String _envLabel =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

  /// The active config for the current build.
  static EnvConfig get current => switch (_envLabel) {
        'production' => EnvConfig.production(),
        'staging' => EnvConfig.staging(),
        _ => EnvConfig.development(),
      };
}
