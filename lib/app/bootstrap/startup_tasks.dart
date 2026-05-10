// ignore_for_file: dangling_library_doc_comments
import '../firebase/firebase_initializer.dart';
import '../environment/env_config.dart';

// Startup task tier definitions and registry for the Burger Farm bootstrap sequence.

///
/// Defines discrete, sequenced startup tasks.
/// Tasks are CATEGORIZED by execution tier:
///
///   TIER 1 — Critical (must complete before first frame)
///     - Flutter engine binding
///     - System UI overlay configuration
///
///   TIER 2 — Essential (runs during splash, parallel where safe)
///     - Shared Preferences initialization
///     - Secure Storage warmup
///     - Environment config resolution
///     - Firebase Core initialization (future)
///
///   TIER 3 — Deferred (runs after first frame renders)
///     - Firebase App Check (future)
///     - Analytics initialization (future)
///     - Remote config fetch (future)
///     - Image precaching (future)
///
/// This tier structure prevents:
///   - Black screens (Tier 1 is synchronous only)
///   - ANRs (Tier 2 is async, non-blocking)
///   - Startup jank (Tier 3 defers heavy ops to post-frame)

enum StartupTaskTier {
  critical,   // Before runApp
  essential,  // During splash, async
  deferred,   // Post-frame, non-blocking
}

class StartupTask {
  const StartupTask({
    required this.name,
    required this.tier,
    required this.execute,
    this.isMandatory = true,
  });

  /// Human-readable name for logging/debugging
  final String name;

  /// Execution tier — determines when this task runs
  final StartupTaskTier tier;

  /// The async task function
  final Future<void> Function() execute;

  /// If false, task failure is logged but does not crash the app
  final bool isMandatory;
}

/// Registry of all startup tasks.
/// Task implementations are added as SDK integrations complete in later phases.
abstract final class StartupTaskRegistry {
  // ─── Tier 2: Essential Async Tasks ────────────────────────────────────────
  static final List<StartupTask> essential = [
    StartupTask(
      name: 'Firebase Core Initialization',
      tier: StartupTaskTier.essential,
      isMandatory: true,
      execute: () async {
        final env = EnvConfig.current.environment;
        await FirebaseInitializer.initialize(env);
      },
    ),
    // TODO(phase-3): Add FlutterSecureStorage warm-up task
  ];

  // ─── Tier 3: Deferred Post-Frame Tasks ────────────────────────────────────
  static final List<StartupTask> deferred = [
    StartupTask(
      name: 'Firebase App Check Activation',
      tier: StartupTaskTier.deferred,
      isMandatory: false,
      execute: () async {
        final env = EnvConfig.current.environment;
        await FirebaseInitializer.activateAppCheck(env);
      },
    ),
    // TODO(phase-5): Add analytics initialization task
    // TODO(phase-5): Add image precaching task
  ];
}
