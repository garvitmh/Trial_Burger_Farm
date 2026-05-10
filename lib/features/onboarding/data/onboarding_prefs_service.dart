import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// OnboardingPrefsService — Persists onboarding completion state.
///
/// Uses SharedPreferences so the flag survives app restarts.
/// Architecture boundary: ONLY controls onboarding visibility.
/// Auth state is managed separately in AuthSessionManager.
class OnboardingPrefsService {
  OnboardingPrefsService._();
  static const _key = 'onboarding_complete_v1';

  static Future<bool> isComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Exposed only for testing — resets onboarding state.
  static Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// onboardingCompleteProvider — Reactive onboarding completion state.
///
/// Returns [AsyncValue<bool>] so routing can differentiate:
///   - AsyncLoading: still reading from disk — stay on splash
///   - AsyncData(false): first install — show onboarding
///   - AsyncData(true): returning user — skip onboarding
final onboardingCompleteProvider =
    AsyncNotifierProvider<OnboardingStateNotifier, bool>(
  OnboardingStateNotifier.new,
  name: 'onboardingCompleteProvider',
);

class OnboardingStateNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return OnboardingPrefsService.isComplete();
  }

  Future<void> markComplete() async {
    state = const AsyncLoading();
    await OnboardingPrefsService.markComplete();
    state = const AsyncData(true);
  }
}
