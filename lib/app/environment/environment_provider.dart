import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'env_config.dart';
import 'app_environment.dart';

/// environmentProvider — makes EnvConfig available globally via Riverpod.
/// Scope: global, never autoDisposed (app lifecycle = provider lifecycle).
final environmentProvider = Provider<EnvConfig>(
  (_) => EnvConfig.current,
  name: 'environmentProvider',
);

/// Convenience provider: exposes only the environment enum.
final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => ref.watch(environmentProvider).environment,
  name: 'appEnvironmentProvider',
);
