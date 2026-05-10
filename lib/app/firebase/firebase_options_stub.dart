
import '../environment/app_environment.dart';

/// FirebaseOptionsStub — Environment-aware Firebase configuration.
///
/// DO NOT hardcode actual Firebase credentials here.
/// In Phase 3, this structure defines how credentials will be injected via
/// environment variables (dart-define) or securely loaded config files.
abstract final class AppFirebaseOptions {
  static dynamic currentPlatform(AppEnvironment environment) {
    if (environment.isProd) {
      return _prodOptions;
    } else if (environment.isStaging) {
      return _stagingOptions;
    } else {
      return _devOptions;
    }
  }

  // TODO(phase-3): Replace `dynamic` with actual FirebaseOptions once credentials exist.
  static dynamic get _devOptions => null;
  static dynamic get _stagingOptions => null;
  static dynamic get _prodOptions => null;
}
