import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/environment/environment_provider.dart';
import '../../../app/environment/app_environment.dart';

// Re-export environment providers for clean imports from the shared layer.
// Feature providers MUST import from here, not directly from app/environment/.
export '../../../app/environment/environment_provider.dart';
export '../../../app/environment/app_environment.dart';
export '../../../app/environment/env_config.dart';

// ─── Bootstrap State ──────────────────────────────────────────────────────────

/// Notifier that tracks whether app initialization has completed.
///
/// CRITICAL FOR ROUTING: GoRouter's redirect function MUST read this before
/// making any auth-based redirect decisions. If [state] is false, return null
/// (no redirect) to prevent the auth-flicker race condition that existed in
/// the legacy codebase.
///
/// The splash screen calls [complete()] after AppInitializer.initialize().
class BootstrapNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Called by the splash screen once essential init is complete.
  void complete() => state = true;
}

final bootstrapCompleteProvider =
    NotifierProvider<BootstrapNotifier, bool>(
  BootstrapNotifier.new,
  name: 'bootstrapCompleteProvider',
);

// ─── App Lifecycle State ──────────────────────────────────────────────────────

/// Notifier that tracks the current [AppLifecycleState].
/// Used to pause/resume services when the app is backgrounded.
/// Wired via WidgetsBindingObserver in Phase 3.
class AppLifecycleNotifier extends Notifier<AppLifecycleState?> {
  @override
  AppLifecycleState? build() => null;

  void update(AppLifecycleState? newState) => state = newState;
}

final appLifecycleProvider =
    NotifierProvider<AppLifecycleNotifier, AppLifecycleState?>(
  AppLifecycleNotifier.new,
  name: 'appLifecycleProvider',
);

// ─── Convenience Selector Providers ──────────────────────────────────────────

/// Reads only the API base URL from the environment config.
final apiBaseUrlProvider = Provider<String>(
  (ref) => ref.watch(environmentProvider).apiBaseUrl,
  name: 'apiBaseUrlProvider',
);

/// Reads only the environment enum.
final currentEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => ref.watch(environmentProvider).environment,
  name: 'currentEnvironmentProvider',
);
