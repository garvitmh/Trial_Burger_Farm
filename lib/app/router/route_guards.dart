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

  static String? guardLogic(Ref ref, GoRouterState state) {
    final currentPath = state.uri.path;

    // ── Phase 1: Bootstrap gate ──────────────────────────────────────────────
    // If bootstrap (Tier 2 init + session restore) is not done, block all
    // navigation outside the splash screen.
    final bootstrapComplete = ref.read(bootstrapCompleteProvider);
    if (!bootstrapComplete) {
      return currentPath == RoutePaths.splash ? null : RoutePaths.splash;
    }

    // ── Phase 2: Session loading gate ────────────────────────────────────────
    // AuthSessionManager starts in AsyncLoading. Wait for it to resolve
    // before any auth-based redirect decision.
    final authAsync = ref.read(authStateProvider);
    if (authAsync.isLoading) {
      return currentPath == RoutePaths.splash ? null : RoutePaths.splash;
    }

    // ── Phase 3: Onboarding completion gate ──────────────────────────────────
    // Read onboarding flag. If still loading, conservatively stay on splash.
    final onboardingAsync = ref.read(onboardingCompleteProvider);
    final onboardingComplete = onboardingAsync.value ?? false;
    if (onboardingAsync.isLoading) {
      return currentPath == RoutePaths.splash ? null : RoutePaths.splash;
    }

    // ── Phase 4: Concrete routing decisions ──────────────────────────────────
    final session = authAsync.value;
    final isAuthenticated = session is AuthStateAuthenticated;

    // -- Authenticated user: skip onboarding/login entirely --
    if (isAuthenticated) {
      if (currentPath == RoutePaths.splash ||
          _authOnlySkipPaths.contains(currentPath)) {
        return '${RoutePaths.shell}/${RoutePaths.home}';
      }
      return null; // Allow all other routes for authenticated users
    }

    // -- Unauthenticated user --
    // If on splash, decide where to go next
    if (currentPath == RoutePaths.splash) {
      return onboardingComplete ? RoutePaths.login : RoutePaths.onboarding;
    }

    // ── Phase 5: No redirect needed ──────────────────────────────────────────
    // If onboarding not done yet, force it before login is accessible
    if (!onboardingComplete && currentPath == RoutePaths.login) {
      return RoutePaths.onboarding;
    }

    // Block unauthenticated users from app shell routes
    if (currentPath.startsWith(RoutePaths.shell)) {
      return onboardingComplete ? RoutePaths.login : RoutePaths.onboarding;
    }

    // Allow all other routes (onboarding, preferences, location, otp)
    return null;
  }
}
