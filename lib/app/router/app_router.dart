import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:burger_farm_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:burger_farm_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:burger_farm_app/features/auth/presentation/screens/login_screen.dart';
import 'package:burger_farm_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:burger_farm_app/features/preferences/presentation/screens/preferences_screen.dart';
import 'package:burger_farm_app/features/location/presentation/screens/location_screen.dart';
import 'package:burger_farm_app/features/location/presentation/screens/outlet_screen.dart';
import 'package:burger_farm_app/features/location/presentation/screens/address_screen.dart';
import 'package:burger_farm_app/features/address_detail/presentation/screens/address_detail_screen.dart';
import 'package:burger_farm_app/features/menu/presentation/screens/detail_screen.dart';
import 'package:burger_farm_app/features/home/presentation/screens/home_screen.dart';
import 'package:burger_farm_app/features/auth/presentation/providers/auth_provider.dart';

/// Route name constants — single source of truth.
abstract final class AppRoute {
  AppRoute._();

  static const String splash        = '/';
  static const String onboarding    = '/onboarding';
  static const String login         = '/login';
  static const String otp           = '/otp';
  static const String preferences   = '/preferences';
  static const String location      = '/location';
  static const String outlet        = '/outlet';
  static const String address       = '/address';
  static const String addressDetail = '/address-detail';
  static const String detail        = '/detail';
  static const String home          = '/home';
}

/// App-level router provider.
/// Consumed by [MaterialApp.router] in main.dart.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.splash,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.user != null;
      final isAuthRoute = state.matchedLocation == AppRoute.splash ||
          state.matchedLocation == AppRoute.login ||
          state.matchedLocation == AppRoute.otp ||
          state.matchedLocation == AppRoute.onboarding;

      // Redirect authenticated users away from auth routes
      if (isAuthenticated && isAuthRoute) {
        return AppRoute.home;
      }

      // Redirect unauthenticated users away from protected routes
      if (!isAuthenticated && !isAuthRoute &&
          state.matchedLocation != AppRoute.onboarding) {
        return AppRoute.login;
      }

      return null; // No redirect
    },
    routes: [
      GoRoute(
        path: AppRoute.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: AppRoute.preferences,
        builder: (context, state) => const PreferencesScreen(),
      ),
      GoRoute(
        path: AppRoute.location,
        builder: (context, state) => const LocationScreen(),
      ),
      GoRoute(
        path: AppRoute.outlet,
        builder: (context, state) => const OutletScreen(),
      ),
      GoRoute(
        path: AppRoute.address,
        builder: (context, state) => const AddressScreen(),
      ),
      GoRoute(
        path: AppRoute.addressDetail,
        builder: (context, state) => const AddressDetailScreen(),
      ),
      GoRoute(
        path: AppRoute.detail,
        builder: (context, state) => const DetailScreen(),
      ),
      GoRoute(
        path: AppRoute.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
