import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_session_manager.dart';
import '../../features/auth/domain/entities/auth_state.dart';
import '../../shared/providers/app_providers.dart';
import 'route_paths.dart';

/// RouteGuards — Burger Farm Route Protection Logic
///
/// Guards are pure functions returning a redirect path or null.
/// They are consumed by GoRouter's `redirect` callback.
///
/// AUTH GUARD PHILOSOPHY:
/// The auth guard must be non-flickering. It waits for the bootstrap
/// sequence and session restoration to complete before making any redirect decision.
abstract final class RouteGuards {
  /// Core routing logic evaluated on every GoRouter navigation or state change.
  static String? guardLogic(Ref ref, GoRouterState state) {
    final bootstrapComplete = ref.read(bootstrapCompleteProvider);
    final authState = ref.read(authStateProvider);

    // 1. Splash Phase (Blocking)
    // If essential init or session restoration is still loading, stay on Splash.
    if (!bootstrapComplete || authState.isLoading) {
      if (state.uri.path != RoutePaths.splash) {
        return RoutePaths.splash; // Force stay on splash until ready
      }
      return null; // Already on splash, wait.
    }

    // 2. Auth Resolution Phase
    // The session is loaded. We have a concrete AuthState.
    final session = authState.value;
    final isAuth = session is AuthStateAuthenticated;
    
    // Determine where the user is currently trying to go
    final isGoingToSplash = state.uri.path == RoutePaths.splash;
    final isGoingToAuth = state.uri.path.startsWith(RoutePaths.login);
    // TODO(phase-4): Add onboarding flag check here.
    
    if (!isAuth) {
      // Unauthenticated users MUST go to login (or onboarding)
      if (!isGoingToAuth) {
        // TODO(phase-4): Redirect to onboarding if first time, else login.
        return RoutePaths.login;
      }
    } else {
      // Authenticated users should NEVER see Splash or Login.
      if (isGoingToSplash || isGoingToAuth) {
        return '${RoutePaths.shell}/${RoutePaths.home}';
      }
    }

    // 3. No redirect needed, proceed to requested route.
    return null;
  }
}
