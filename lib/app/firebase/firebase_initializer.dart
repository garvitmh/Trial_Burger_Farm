import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../environment/app_environment.dart';
import 'firebase_options_stub.dart';

/// FirebaseInitializer — Orchestrates startup-safe Firebase initialization.
///
/// Must be executed within `AppInitializer` (Tier 2).
/// Includes preparation for Firebase App Check.
class FirebaseInitializer {
  FirebaseInitializer._();

  static Future<void> initialize(AppEnvironment environment) async {
    try {
      debugPrint('[FirebaseInitializer] Initializing for ${environment.name}...');
      
      final options = AppFirebaseOptions.currentPlatform(environment);
      await Firebase.initializeApp(options: options);

      debugPrint('[FirebaseInitializer] Firebase initialized.');
    } catch (e, stack) {
      debugPrint('[FirebaseInitializer] FAILED to initialize Firebase: $e');
      debugPrint(stack.toString());
      // Re-throw critical failures if required, or fallback gracefully.
      rethrow;
    }
  }

  /// App Check activation must be deferred (Tier 3) to avoid splash blocking.
  static Future<void> activateAppCheck(AppEnvironment environment) async {
    if (!environment.isAppCheckEnforced) {
      debugPrint('[FirebaseInitializer] App Check bypassed for ${environment.name}.');
      return;
    }

    try {
      debugPrint('[FirebaseInitializer] Activating App Check...');
      
      await FirebaseAppCheck.instance.activate(
        providerAndroid: environment.isDev ? AndroidDebugProvider() : AndroidPlayIntegrityProvider(),
        providerApple: environment.isDev ? AppleDebugProvider() : AppleDeviceCheckProvider(),
      );
      
      debugPrint('[FirebaseInitializer] App Check activated.');
    } catch (e, stack) {
      debugPrint('[FirebaseInitializer] App Check activation failed: $e');
      debugPrint(stack.toString());
    }
  }
}
