import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/data/onboarding_prefs_service.dart';
import 'startup_tasks.dart';

/// AppInitializer — Burger Farm Async Initialization Orchestrator
///
/// Orchestrates Tier 2 (essential) startup tasks during the splash lifecycle.
/// Tier 3 (deferred) tasks are scheduled post-first-frame by BootstrapManager.
///
/// ANTI-PATTERN PREVENTION:
///   - Never call heavy sync work here.
///   - Never block the widget tree render.
///   - Failures in non-mandatory tasks are caught and logged, never rethrown.

class AppInitializer {
  AppInitializer._();

  static bool _initialized = false;

  /// Runs all essential (Tier 2) startup tasks concurrently where safe.
  /// Called by SplashPage during the bootstrap lifecycle.
  static Future<void> initialize(WidgetRef ref) async {
    if (_initialized) return;

    debugPrint('[AppInitializer] Starting essential initialization...');

    final tasks = StartupTaskRegistry.essential;

    if (tasks.isEmpty) {
      debugPrint('[AppInitializer] No essential tasks registered. Proceeding.');
      _initialized = true;
      return;
    }

    // Run mandatory tasks sequentially; non-mandatory tasks in parallel
    final mandatoryTasks = tasks.where((t) => t.isMandatory).toList();
    final optionalTasks = tasks.where((t) => !t.isMandatory).toList();

    // Mandatory: Sequential (order matters — e.g., SharedPrefs before Firebase)
    for (final task in mandatoryTasks) {
      debugPrint('[AppInitializer] Running: ${task.name}');
      await task.execute();
    }

    // Optional: Parallel (failures are swallowed)
    if (optionalTasks.isNotEmpty) {
      await Future.wait(
        optionalTasks.map((task) async {
          try {
            debugPrint('[AppInitializer] Running optional: ${task.name}');
            await task.execute();
          } catch (e, stack) {
            debugPrint('[AppInitializer] Optional task failed: ${task.name}');
            debugPrint('$e\n$stack');
          }
        }),
      );
    }

    _initialized = true;
    debugPrint('[AppInitializer] Essential initialization complete.');

    // Warm the onboarding completion state so the router guard can read it
    // synchronously without waiting for its own AsyncNotifier build.
    await ref.read(onboardingCompleteProvider.future).catchError((_) => false);
    debugPrint('[AppInitializer] Onboarding state warmed.');
  }

  /// Precaches visual assets required by the onboarding + auth flows.
  ///
  /// Strategy:
  ///   - Must be called with a [BuildContext] after the first frame renders.
  ///   - Failures are swallowed — the UI must degrade gracefully without assets.
  ///   - Only precache assets that appear in the first 3 screens (critical path).
  ///
  /// Assets used in onboarding/auth are generated via CustomPainter (no files),
  /// so this is a no-op for the current build. When image assets are added
  /// (e.g., onboarding illustration PNGs), register them here.
  static Future<void> precacheAssets(BuildContext context) async {
    // Example when real image assets are added:
    // const onboardingImages = [
    //   'assets/images/onboarding_slide_1.webp',
    //   'assets/images/onboarding_slide_2.webp',
    //   'assets/images/onboarding_slide_3.webp',
    // ];
    // await Future.wait(
    //   onboardingImages.map((path) =>
    //     precacheImage(AssetImage(path), context).catchError((_) {})
    //   ),
    // );
    debugPrint('[AppInitializer] Asset precaching complete (CustomPainter mode — no files).');
  }

  /// Schedules deferred (Tier 3) tasks post-first-frame.
  /// These tasks MUST NOT block the user from seeing the first rendered frame.
  static void scheduleDeferredTasks() {
    final tasks = StartupTaskRegistry.deferred;
    if (tasks.isEmpty) return;

    // Use addPostFrameCallback to guarantee post-frame execution
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      for (final task in tasks) {
        Future.microtask(() async {
          try {
            debugPrint('[AppInitializer] Deferred task: ${task.name}');
            await task.execute();
          } catch (e, stack) {
            debugPrint('[AppInitializer] Deferred task failed: ${task.name}');
            debugPrint('$e\n$stack');
          }
        });
      }
    });
  }

  @visibleForTesting
  static void resetForTesting() => _initialized = false;
}
