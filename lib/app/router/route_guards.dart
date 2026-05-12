import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/auth_state.dart';
import '../../features/auth/presentation/controllers/auth_session_manager.dart';
import '../../features/onboarding/data/onboarding_prefs_service.dart';
import '../../shared/providers/app_providers.dart';
import 'route_paths.dart';

/// RouteGuards — Burger Farm Real Route Protection Logic
///
/// ROUTING LIFECYCLE:
///
///   FIRST INSTALL:
///     Splash → Onboarding → Login → Preferences → Location Setup
///
///   RETURNING AUTHENTICATED USER:
///     Splash → (bootstrap) → /app/home  [skip onboarding + login]
///
///   RETURNING UNAUTHENTICATED USER:
///     Splash → (bootstrap) → Login  [skip onboarding only]
///
/// GUARD CONTRACT:
///   - Returns null  → allow navigation
///   - Returns path  → redirect to path
///   - Never redirects while bootstrapping or session loading
///
/// ANTI-PATTERNS PREVENTED:
///   - No redirect during AsyncLoading (prevents auth flicker)
///   - No onboarding repetition (SharedPrefs flag)
///   - No splash rerender (bootstrapComplete gate)
///   - No loops (redirect only fires when on wrong screen)
abstract final class RouteGuards {
  // ─── Route groups ─────────────────────────────────────────────────────────

  // Paths that authenticated users must NOT access
  static const _authOnlySkipPaths = {
    RoutePaths.onboarding,
    RoutePaths.login,
    RoutePaths.otpVerification,
  };

  // Paths that should NOT be yanked back to splash when an async dependency
  // momentarily re-enters AsyncLoading (e.g. after the user marks onboarding
  // complete or while a refresh-token is being exchanged). The user is already
  // mid-flow on these screens; pulling them to splash is destructive.
  static const _inFlightSafePaths = {
    RoutePaths.onboarding,
    RoutePaths.login,
    RoutePaths.otpVerification,
    RoutePaths.preferences,
    RoutePaths.locationSetup,
    RoutePaths.addressSearch,
  };

  static String? guardLogic(Ref ref, GoRouterState state) {
    final currentPath = state.uri.path;

    // ── Phase 1: Bootstrap gate ──────────────────────────────────────────────
    // Block all navigation except splash until the splash widget has signalled
    // bootstrap completion. Splash itself is allowed because that is where
    // bootstrap actually runs.
    final bootstrapComplete = ref.read(bootstrapCompleteProvider);
    if (!bootstrapComplete) {
      return currentPath == RoutePaths.splash ? null : RoutePaths.splash;
    }

    // ── Phase 1b: Firebase init failure gate ─────────────────────────────────
    // If Firebase failed to initialize in main(), no auth provider is callable.
    // Route the user to login as a safe terminal state instead of looping on
    // splash. They'll see the inert auth screen rather than a hung splash.
    if (ref.read(firebaseInitFailedProvider)) {
      if (currentPath == RoutePaths.splash) return RoutePaths.login;
      return null;
    }

    // ── Phase 2: Session loading gate ────────────────────────────────────────
    // AuthSessionManager starts in AsyncLoading. Wait for it to resolve before
    // any auth-based redirect decision. Only hold the user on splash; once
    // they're past splash and onto another flow screen (login, OTP, etc.), do
    // not yank them back just because auth is momentarily re-resolving.
    final authAsync = ref.read(authStateProvider);
    if (authAsync.isLoading) {
      if (currentPath == RoutePaths.splash) return null;
      if (_inFlightSafePaths.contains(currentPath)) return null;
      return RoutePaths.splash;
    }

    // ── Phase 2b: Auth error gate (Bug A from forensic report) ───────────────
    // If authStateProvider entered AsyncError (e.g. Firebase available but the
    // session restoration call threw), do NOT treat the user as unauthenticated
    // — `.value` would be null and we'd route a legitimately-session'd user to
    // login. Instead, hold the current location (no redirect) so the user can
    // retry on their current screen. Splash is the one exception: there's
    // nothing actionable there, so push them to login as a terminal state.
    if (authAsync.hasError) {
      return currentPath == RoutePaths.splash ? RoutePaths.login : null;
    }

    // ── Phase 3: Onboarding completion gate (Bug B from forensic report) ────
    // Read onboarding flag. While it's loading, only pull the user to splash
    // during cold boot. If they're already on a flow screen (e.g. they just
    // tapped "Done" on onboarding which triggers a momentary AsyncLoading),
    // let them stay where they are until the new AsyncData arrives.
    final onboardingAsync = ref.read(onboardingCompleteProvider);
    final onboardingComplete = onboardingAsync.value ?? false;
    if (onboardingAsync.isLoading) {
      if (currentPath == RoutePaths.splash) return null;
      if (_inFlightSafePaths.contains(currentPath)) return null;
      return RoutePaths.splash;
    }
    if (onboardingAsync.hasError) {
      // Conservatively treat as not-complete so the user sees onboarding
      // rather than being silently routed past it.
      return currentPath == RoutePaths.splash ? RoutePaths.onboarding : null;
    }

    // ── Phase 4: Concrete routing decisions ──────────────────────────────────
    final session = authAsync.value;
    final isAuthenticated = session is AuthStateAuthenticated;

    // Authenticated user: skip onboarding/login entirely.
    if (isAuthenticated) {
      if (currentPath == RoutePaths.splash ||
          _authOnlySkipPaths.contains(currentPath)) {
        return '${RoutePaths.shell}/${RoutePaths.home}';
      }
      return null;
    }

    // Unauthenticated user on splash: decide where to go next.
    if (currentPath == RoutePaths.splash) {
      return onboardingComplete ? RoutePaths.login : RoutePaths.onboarding;
    }

    // ── Phase 5: Other unauthenticated routing rules ─────────────────────────
    // Force onboarding before login if the user has not completed it.
    if (!onboardingComplete && currentPath == RoutePaths.login) {
      return RoutePaths.onboarding;
    }

    // Block unauthenticated users from app shell routes.
    if (currentPath.startsWith(RoutePaths.shell)) {
      return onboardingComplete ? RoutePaths.login : RoutePaths.onboarding;
    }

    // Allow all other routes (onboarding, preferences, location, otp).
    return null;
  }
}
