import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import '../environment/app_environment.dart';

/// AppFirebaseOptions — Environment-aware Firebase configuration.
///
/// Values are derived from `android/app/google-services.json` for the
/// `burger-farm-2cba9` project. All three environments currently point at the
/// same Firebase project; split projects per-environment when staging/prod
/// projects are provisioned.
abstract final class AppFirebaseOptions {
  static FirebaseOptions currentPlatform(AppEnvironment environment) {
    if (kIsWeb) {
      throw UnsupportedError(
        'AppFirebaseOptions are not configured for web. Add a web app to the '
        'Firebase project and inject the options here.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS Firebase options not yet provisioned. Add GoogleService-Info.plist '
          'and the matching options entry.',
        );
      default:
        throw UnsupportedError(
          'Firebase is not configured for ${defaultTargetPlatform.name}.',
        );
    }
  }

  static const FirebaseOptions _android = FirebaseOptions(
    apiKey: 'AIzaSyD3FIGKI3wro_8CW9XWIh-7QOibAE3kgXE',
    appId: '1:284811640366:android:329840b61f6a67cbd769bf',
    messagingSenderId: '284811640366',
    projectId: 'burger-farm-2cba9',
    storageBucket: 'burger-farm-2cba9.firebasestorage.app',
  );
}
