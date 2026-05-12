/// RoutePaths — Burger Farm URL Path Constants
///
/// All GoRouter `path` values are defined here.
/// These map 1:1 with RouteNames for deep-link compatibility.
abstract final class RoutePaths {
  // ─── Bootstrap ────────────────────────────────────────────────────────────
  static const String splash = '/';

  // ─── Onboarding ───────────────────────────────────────────────────────────
  static const String onboarding = '/onboarding';

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String otpVerification = '/login/otp';

  // ─── Location ─────────────────────────────────────────────────────────────
  static const String locationSetup = '/location';
  static const String addressSearch = '/location/search';
  static const String addressDetail = '/location/search/detail';

  // ─── Preferences ──────────────────────────────────────────────────────────
  static const String preferences = '/preferences';

  // ─── Main Shell ───────────────────────────────────────────────────────────
  static const String shell = '/app';
  static const String home = 'home';
  static const String stores = 'stores';
  static const String storeDetail = 'stores/:storeId';
  static const String cart = 'cart';
  static const String profile = 'profile';

  // ─── Error ────────────────────────────────────────────────────────────────
  static const String notFound = '/404';
}
