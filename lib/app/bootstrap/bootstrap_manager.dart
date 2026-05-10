import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_initializer.dart';

/// BootstrapManager — Burger Farm Application Startup Orchestrator
///
/// Entry point for all startup sequencing. Called from main().
///
/// STARTUP SEQUENCE:
///   1. ensureFlutterInitialized()     — Tier 1: synchronous, pre-runApp
///   2. _configureSystemUI()           — Tier 1: overlay style, status bar
///   3. AppInitializer.initialize()    — Tier 2: async essential tasks
///   4. AppInitializer.scheduleDeferredTasks() — Tier 3: post-frame
///
/// This class is the ONLY place allowed to call WidgetsFlutterBinding.
/// Never call ensureFlutterInitialized() anywhere else in the codebase.

class BootstrapManager {
  BootstrapManager._();

  /// Main bootstrap entry point. Called before runApp.
  static Future<void> bootstrap() async {
    // ── Tier 1: Flutter engine binding ──────────────────────────────────────
    WidgetsFlutterBinding.ensureInitialized();

    // ── Tier 1: Configure system UI overlays ────────────────────────────────
    await _configureSystemUI();

    // ── Tier 2: Run essential async initialization ───────────────────────────
    await AppInitializer.initialize();

    // ── Tier 3: Schedule deferred post-frame tasks ───────────────────────────
    // These are registered here but only execute after the first frame renders.
    AppInitializer.scheduleDeferredTasks();
  }

  /// Configures Android/iOS system chrome: status bar, navigation bar.
  static Future<void> _configureSystemUI() async {
    // Extend content into status bar (edge-to-edge)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Set transparent overlays — allows themed status bars per screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Lock to portrait — Burger Farm is a portrait-first mobile app
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
