// ============================================================================
// FILE: lib/core/network/api_endpoints.dart
// CHANGES:
//   - Created centralized API route constants
//   - All backend routes defined here as single source of truth
// ============================================================================

/// Centralized API endpoint constants.
/// Any route changes require only a single edit here.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // ─── Auth ──────────────────────────────────────────
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // ─── Profile ───────────────────────────────────────
  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';
  static const String dietaryPreference = '/profile/dietary';

  // ─── Stores / Outlets ──────────────────────────────
  static const String stores = '/stores';
  static const String nearbyStores = '/stores/nearby';

  // ─── Menu ──────────────────────────────────────────
  static const String menu = '/menu';
  static const String menuCategories = '/menu/categories';
  static const String popularItems = '/menu/popular';

  // ─── Orders ────────────────────────────────────────
  static const String orders = '/orders';
  static const String createOrder = '/orders/create';
}
