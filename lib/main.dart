import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/bootstrap/bootstrap_manager.dart';
import 'app/config/burger_farm_app.dart';

/// main() — Burger Farm application entry point.
///
/// Boot sequence (PERFORMANCE_RULES.md compliance):
///   1. BootstrapManager.bootstrap() — Tier 1 + Tier 2 initialization
///   2. runApp() — First frame rendered ASAP
///   3. Deferred tasks scheduled post-frame (already queued by bootstrap)
///
/// ProviderScope wraps the entire app as the Riverpod dependency root.
/// All providers are created lazily on first access.
Future<void> main() async {
  // Tier 1 + 2: Engine binding, system UI, essential async init
  await BootstrapManager.bootstrap();

  runApp(
    const ProviderScope(
      child: BurgerFarmApp(),
    ),
  );
}
