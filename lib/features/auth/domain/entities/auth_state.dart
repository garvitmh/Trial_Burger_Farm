import 'auth_user.dart';

/// AuthState — Immutable state representing the current session context.
///
/// Handles the lifecycle of an authentication session, from unknown (startup)
/// to authenticated, unauthenticated, or failed.
sealed class AuthState {
  const AuthState();
}

/// Initial state during app bootstrap before session is restored.
class AuthStateUnknown extends AuthState {
  const AuthStateUnknown();
}

/// User is fully authenticated.
class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated(this.user);
  final AuthUser user;
}

/// User is NOT authenticated (guest/logged out).
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}
