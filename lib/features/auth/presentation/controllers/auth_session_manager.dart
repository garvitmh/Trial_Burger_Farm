import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/firebase/firebase_providers.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../providers/auth_repository_provider.dart';

/// authStateProvider — Exposes the reactive AuthState of the application.
///
/// This is the MOST IMPORTANT provider for routing. It dictates whether the
/// user sees the Splash, Login, or Home screen.
final authStateProvider = AsyncNotifierProvider<AuthSessionManager, AuthState>(
  AuthSessionManager.new,
  name: 'authStateProvider',
);

/// AuthSessionManager — Manages the lifecycle of the user's authentication session.
///
/// Prevents splash rerender loops by maintaining an `AsyncLoading` state until
/// the initial session is fully restored and verified from secure storage/Firebase.
///
/// Lifecycle hygiene:
///   - Cancels both the auth-state and id-token subscriptions when the
///     provider is disposed (audit fix I-1). Without this, hot-reload and
///     `ref.invalidate(authStateProvider)` orphan listeners that then
///     mutate a disposed notifier.
///   - Listens to `idTokenChanges()` and re-persists the fresh JWT to
///     secure storage every time Firebase rotates it (audit fix I-2).
///     Firebase ID tokens expire after 1 hour; without this, backend
///     calls reading the stored token would 401 silently.
class AuthSessionManager extends AsyncNotifier<AuthState> {
  late final IAuthRepository _authRepo;
  late final fb.FirebaseAuth _firebaseAuth;
  late final SecureStorageService _secureStorage;

  StreamSubscription<AuthUser?>? _authStateSub;
  StreamSubscription<fb.User?>? _idTokenSub;

  @override
  FutureOr<AuthState> build() async {
    _authRepo = ref.watch(authRepositoryProvider);
    _firebaseAuth = ref.watch(firebaseAuthProvider);
    _secureStorage = ref.watch(secureStorageProvider);

    // Critical: cancel subscriptions on dispose so a rebuilt notifier
    // doesn't orphan listeners that then race on a disposed state.
    ref.onDispose(() {
      _authStateSub?.cancel();
      _idTokenSub?.cancel();
    });

    final initialState = await _restoreSession();

    _listenToAuthChanges();
    _listenToIdTokenRefresh();

    return initialState;
  }

  Future<AuthState> _restoreSession() async {
    debugPrint('[AuthSessionManager] Restoring session...');
    try {
      final user = _authRepo.currentUser;
      if (user != null) {
        debugPrint('[AuthSessionManager] Session restored: Authenticated (${user.id})');
        return AuthStateAuthenticated(user);
      } else {
        debugPrint('[AuthSessionManager] Session restored: Unauthenticated');
        return const AuthStateUnauthenticated();
      }
    } catch (e) {
      debugPrint('[AuthSessionManager] Session restoration failed: $e');
      return const AuthStateUnauthenticated();
    }
  }

  void _listenToAuthChanges() {
    _authStateSub?.cancel();
    _authStateSub = _authRepo.authStateChanges.listen((user) {
      if (user != null) {
        debugPrint('[AuthSessionManager] Auth changed: Authenticated (${user.id})');
        state = AsyncData(AuthStateAuthenticated(user));
      } else {
        debugPrint('[AuthSessionManager] Auth changed: Unauthenticated');
        state = const AsyncData(AuthStateUnauthenticated());
      }
    });
  }

  /// Subscribes to Firebase's id-token rotation stream and re-persists the
  /// fresh token to secure storage. This is the only correct way to keep
  /// the stored token live across the 1-hour Firebase token expiry.
  void _listenToIdTokenRefresh() {
    _idTokenSub?.cancel();
    _idTokenSub = _firebaseAuth.idTokenChanges().listen((user) async {
      if (user == null) {
        // User signed out → token cache is cleared by the repository's
        // signOut() path. Defensive: best-effort clear here too.
        try {
          await _secureStorage.clearSession();
        } catch (_) {/* secure storage failures are non-fatal */}
        return;
      }
      try {
        final token = await user.getIdToken();
        if (token != null) {
          await _secureStorage.saveAuthToken(token);
        }
      } catch (e) {
        debugPrint('[AuthSessionManager] Token refresh persist failed: $e');
      }
    });
  }

  Future<void> signOut() async {
    try {
      await _authRepo.signOut();
      // The stream listener will automatically update the state to Unauthenticated.
    } catch (e) {
      debugPrint('[AuthSessionManager] Sign out failed: $e');
      rethrow;
    }
  }

  /// Initiates the Google Sign-In flow. The auth stream listener installed in
  /// [_listenToAuthChanges] picks up the resulting user and the router
  /// redirects automatically — callers do not need to navigate themselves.
  /// Throws the typed [AuthFailure] from the repository on failure so the UI
  /// can show a localized message.
  Future<void> signInWithGoogle() async {
    await _authRepo.signInWithGoogle();
  }

  /// Starts an anonymous Firebase session so the user can proceed through
  /// the pre-home flow as a guest. The id-token listener re-persists the
  /// anonymous user's token so downstream API calls can still attribute
  /// the request to a stable UID. The router's authenticated branch
  /// admits anonymous users (Firebase reports `isAnonymous: true` on the
  /// domain entity, but `AuthStateAuthenticated` doesn't differentiate —
  /// guard rules can read `currentUser.isAnonymous` if they later need to).
  Future<void> signInAsGuest() async {
    await _authRepo.signInAsGuest();
  }
}
