import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/bootstrap/bootstrap_manager.dart';
import 'app/config/burger_farm_app.dart';
import 'app/firebase/firebase_initializer.dart';
import 'shared/providers/app_providers.dart';

/// main() — Burger Farm application entry point.
///
/// Boot sequence:
///   1. BootstrapManager.bootstrap()      — engine binding, system UI
///   2. Firebase.initializeApp(...)       — BEFORE runApp so providers that
///                                          read FirebaseAuth.instance from
///                                          their build() (notably
///                                          authStateProvider via the router
///                                          notifier) never observe a missing
///                                          [core/no-app] state.
///   3. runApp(ProviderScope(...))        — first frame
///   4. Deferred tasks                    — already queued by bootstrap()
///
/// Firebase init failure does NOT crash the app: the failure is captured in
/// firebaseInitFailedProvider and surfaced by RouteGuards so the user lands on
/// an inert splash instead of a black screen.
Future<void> main() async {
  await BootstrapManager.bootstrap();

  Object? firebaseInitError;
  try {
    await FirebaseInitializer.initialize(EnvConfig.current.environment);
  } catch (e, stack) {
    firebaseInitError = e;
    debugPrint('[main] Firebase init failed — running in degraded mode: $e');
    debugPrint('$stack');
  }

  runApp(
    ProviderScope(
      overrides: [
        if (firebaseInitError != null)
          firebaseInitFailedProvider.overrideWithValue(true),
      ],
      child: const BurgerFarmApp(),
    ),
  );
}
