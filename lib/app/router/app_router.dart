import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/preferences/presentation/screens/preferences_screen.dart';
import '../../features/location/presentation/screens/location_screen.dart';
import '../../features/location/presentation/screens/outlet_screen.dart';
import '../../features/location/presentation/screens/address_screen.dart';
import '../../features/address_detail/presentation/screens/address_detail_screen.dart';
import '../../features/menu/presentation/screens/detail_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

/// Route name constants — single source of truth.
class AppRoute {
  AppRoute._();

  static const String splash      = '/';
  static const String onboarding  = '/onboarding';
  static const String login       = '/login';
  static const String otp         = '/otp';
  static const String preferences = '/preferences';
  static const String location    = '/location';
  static const String outlet      = '/outlet';
  static const String address     = '/address';
  static const String addressDetail = '/address-detail';
  static const String detail      = '/detail';
  static const String home        = '/home';
}

/// App-level router provider.
/// Consumed by [MaterialApp.router] in main.dart.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoute.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.otp,
        builder: (_, _) => const OtpScreen(),
      ),
      GoRoute(
        path: AppRoute.preferences,
        builder: (_, _) => const PreferencesScreen(),
      ),
      GoRoute(
        path: AppRoute.location,
        builder: (_, _) => const LocationScreen(),
      ),
      GoRoute(
        path: AppRoute.outlet,
        builder: (_, _) => const OutletScreen(),
      ),
      GoRoute(
        path: AppRoute.address,
        builder: (_, _) => const AddressScreen(),
      ),
      GoRoute(
        path: AppRoute.addressDetail,
        builder: (_, _) => const AddressDetailScreen(),
      ),
      GoRoute(
        path: AppRoute.detail,
        builder: (_, _) => const DetailScreen(),
      ),
      GoRoute(
        path: AppRoute.home,
        builder: (_, _) => const HomeScreen(),
      ),
    ],
  );
});
