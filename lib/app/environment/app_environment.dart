/// AppEnvironment — Burger Farm Environment Enum & Contract
///
/// Defines the three distinct deployment environments.
/// All environment-specific logic MUST branch on AppEnvironment values.
/// Secrets must NEVER be hardcoded here.
enum AppEnvironment {
  development,
  staging,
  production;

  bool get isDev => this == AppEnvironment.development;
  bool get isStaging => this == AppEnvironment.staging;
  bool get isProd => this == AppEnvironment.production;

  /// Whether analytics and crashlytics should be active.
  bool get isAnalyticsEnabled => this != AppEnvironment.development;

  /// Whether verbose logging is permitted.
  bool get isLoggingEnabled => this != AppEnvironment.production;

  /// Whether Firebase App Check enforcement is active.
  bool get isAppCheckEnforced => this == AppEnvironment.production;

  String get displayName => switch (this) {
        AppEnvironment.development => 'Development',
        AppEnvironment.staging => 'Staging',
        AppEnvironment.production => 'Production',
      };
}
