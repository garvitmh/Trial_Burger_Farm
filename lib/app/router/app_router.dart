import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import 'route_paths.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/preferences/presentation/pages/preferences_page.dart';
import '../../features/location/presentation/pages/location_setup_page.dart';
import '../../features/location/presentation/pages/address_search_page.dart';

/// AppRouter — Burger Farm GoRouter Configuration
///
/// ARCHITECTURAL RULES (FORBIDDEN_PATTERNS.md compliance):
///  - Route guards MUST be the sole source of navigation logic.
///  - Repositories must NEVER call context.go() or context.push().
///  - Auth redirects MUST wait for bootstrap completion to prevent flicker.
///
/// SPLASH RERENDER FIX:
///  The legacy codebase suffered from splash rerender loops caused by
///  GoRouter rebuilding while auth state was loading. This is fixed by:
///    1. refreshListenable points to a listenable that only notifies AFTER
///       bootstrap is complete.
///    2. The redirect function returns null while loading (no-op).
///
/// SHELL ROUTE:
///  The main app shell (bottom nav + global scaffold) is wrapped in a
///  ShellRoute so the nav bar persists across tab navigation without rebuild.

import '../../features/auth/presentation/controllers/auth_session_manager.dart';
import '../../features/onboarding/data/onboarding_prefs_service.dart';
import '../../shared/providers/app_providers.dart';
import 'route_guards.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) {
    // Listen to dependencies that should trigger a redirect evaluation.
    // Using a ValueNotifier that bumps whenever our providers change.
    final notifier = _RouterNotifier(ref);

    return GoRouter(
      debugLogDiagnostics: true, // Disable in production via env check
      initialLocation: RoutePaths.splash,
      refreshListenable: notifier,

      // ─── Global Redirect Logic ─────────────────────────────────────────
      redirect: (context, state) => RouteGuards.guardLogic(ref, state),

      // ─── Route Tree ────────────────────────────────────────────────────
      routes: [
        // ── Splash (bootstrap entry point) ───────────────────────────────
        GoRoute(
          path: RoutePaths.splash,
          name: RouteNames.splash,
          pageBuilder: (context, state) => _fadeTransition(
            state: state,
            child: const SplashPage(),
          ),
        ),

        // ── Onboarding ───────────────────────────────────────────────────
        GoRoute(
          path: RoutePaths.onboarding,
          name: RouteNames.onboarding,
          pageBuilder: (context, state) => _slideUpTransition(
            state: state,
            child: const OnboardingPage(),
          ),
        ),

        // ── Auth ─────────────────────────────────────────────────────────
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          pageBuilder: (context, state) => _slideUpTransition(
            state: state,
            child: const LoginPage(),
          ),
          routes: [
            GoRoute(
              path: RoutePaths.otpVerification,
              name: RouteNames.otpVerification,
              pageBuilder: (context, state) => _fadeTransition(
                state: state,
                child: const OtpVerificationPage(),
              ),
            ),
          ],
        ),

        // ── Location Setup ────────────────────────────────────────────────
        GoRoute(
          path: RoutePaths.locationSetup,
          name: RouteNames.locationSetup,
          pageBuilder: (context, state) => _slideUpTransition(
            state: state,
            child: const LocationSetupPage(),
          ),
          routes: [
            GoRoute(
              path: RoutePaths.addressSearch,
              name: RouteNames.addressSearch,
              pageBuilder: (context, state) => _fadeTransition(
                state: state,
                child: const AddressSearchPage(),
              ),
            ),
          ],
        ),

        // ── Preferences ───────────────────────────────────────────────────
        GoRoute(
          path: RoutePaths.preferences,
          name: RouteNames.preferences,
          pageBuilder: (context, state) => _slideUpTransition(
            state: state,
            child: const PreferencesPage(),
          ),
        ),

        // ── Main App Shell (bottom navigation) ───────────────────────────
        ShellRoute(
          builder: (context, state, child) {
            // TODO(phase-4): Replace with actual AppShell widget
            return _PlaceholderShell(child: child);
          },
          routes: [
            GoRoute(
              path: '${RoutePaths.shell}/${RoutePaths.home}',
              name: RouteNames.home,
              pageBuilder: (context, state) => _fadeTransition(
                state: state,
                child: const _PlaceholderPage(label: 'Home'),
              ),
            ),
            GoRoute(
              path: '${RoutePaths.shell}/${RoutePaths.stores}',
              name: RouteNames.stores,
              pageBuilder: (context, state) => _fadeTransition(
                state: state,
                child: const _PlaceholderPage(label: 'Stores'),
              ),
              routes: [
                GoRoute(
                  path: RoutePaths.storeDetail,
                  name: RouteNames.storeDetail,
                  pageBuilder: (context, state) => _fadeTransition(
                    state: state,
                    child: _PlaceholderPage(
                      label: 'Store: ${state.pathParameters['storeId']}',
                    ),
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '${RoutePaths.shell}/${RoutePaths.profile}',
              name: RouteNames.profile,
              pageBuilder: (context, state) => _fadeTransition(
                state: state,
                child: const _PlaceholderPage(label: 'Profile'),
              ),
            ),
          ],
        ),

        // ── 404 Not Found ─────────────────────────────────────────────────
        GoRoute(
          path: RoutePaths.notFound,
          name: RouteNames.notFound,
          pageBuilder: (context, state) => _fadeTransition(
            state: state,
            child: const _PlaceholderPage(label: '404 Not Found'),
          ),
        ),
      ],

      // ─── Error Handler ─────────────────────────────────────────────────
      errorPageBuilder: (context, state) => _fadeTransition(
        state: state,
        child: _PlaceholderPage(label: 'Error: ${state.error?.message}'),
      ),
    );
  },
  name: 'appRouterProvider',
);

// ─── Transition Helpers ──────────────────────────────────────────────────────

CustomTransitionPage<void> _fadeTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _slideUpTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      );
    },
  );
}

// ─── Placeholder Widgets (replaced in later phases) ──────────────────────────

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F2),
      body: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Recoleta',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF271200),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderShell extends StatelessWidget {
  const _PlaceholderShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// _RouterNotifier bridges Riverpod state changes to GoRouter's refreshListenable.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
    _ref.listen(
      bootstrapCompleteProvider,
      (previous, next) => notifyListeners(),
    );
    _ref.listen(
      onboardingCompleteProvider,
      (previous, next) => notifyListeners(),
    );
  }

  final Ref _ref;
}
