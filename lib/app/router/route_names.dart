/// RouteNames — Burger Farm Semantic Route Name Constants
///
/// All GoRouter route `name` values are defined here.
/// Widgets and providers MUST use these constants for navigation calls.
/// Never hardcode route names as string literals in UI code.
abstract final class RouteNames {
  // ─── Bootstrap ────────────────────────────────────────────────────────────
  static const String splash = 'splash';

  // ─── Onboarding ───────────────────────────────────────────────────────────
  static const String onboarding = 'onboarding';

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String login = 'login';
  static const String otpVerification = 'otp-verification';

  // ─── Location ─────────────────────────────────────────────────────────────
  static const String locationSetup = 'location-setup';
  static const String addressSearch = 'address-search';

  // ─── Preferences ──────────────────────────────────────────────────────────
  static const String preferences = 'preferences';

  // ─── Main Shell ───────────────────────────────────────────────────────────
  static const String shell = 'shell';
  static const String home = 'home';
  static const String stores = 'stores';
  static const String storeDetail = 'store-detail';
  static const String cart = 'cart';
  static const String profile = 'profile';

  // ─── Error ────────────────────────────────────────────────────────────────
  static const String notFound = 'not-found';
  static const String error = 'error';
}
