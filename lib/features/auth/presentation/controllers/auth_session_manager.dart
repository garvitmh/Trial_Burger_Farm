import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_state.dart';
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
class AuthSessionManager extends AsyncNotifier<AuthState> {
  late final IAuthRepository _authRepo;
  StreamSubscription? _authStateSub;

  @override
  FutureOr<AuthState> build() async {
    _authRepo = ref.watch(authRepositoryProvider);
    
    // Begin session restoration process.
    // This blocks the provider in AsyncLoading, preventing the router from
    // making premature redirect decisions.
    final initialState = await _restoreSession();
    
    // Once initial state is resolved, listen to future Firebase token changes.
    _listenToAuthChanges();

    return initialState;
  }

  Future<AuthState> _restoreSession() async {
    debugPrint('[AuthSessionManager] Restoring session...');
    
    // Add artificial minimum delay if desired for brand presence, 
    // though typically we want this to be as fast as possible.
    // await Future.delayed(const Duration(milliseconds: 800));

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

  Future<void> signOut() async {
    try {
      await _authRepo.signOut();
      // The stream listener will automatically update the state to Unauthenticated.
    } catch (e) {
      debugPrint('[AuthSessionManager] Sign out failed: $e');
      // Rethrow to UI to show error toast if needed
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
}
