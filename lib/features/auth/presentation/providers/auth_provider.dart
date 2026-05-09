import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burger_farm_app/features/auth/domain/entities/user_entity.dart';
import 'package:burger_farm_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:burger_farm_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:burger_farm_app/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:burger_farm_app/features/auth/data/datasources/node_auth_remote_data_source.dart';
import 'package:burger_farm_app/features/auth/data/datasources/auth_error_mapper.dart';
import 'package:burger_farm_app/core/services/secure_storage_service.dart';

/// Immutable state object for authentication.
@immutable
class AuthState {
  final bool isLoading;
  final String? verificationId;
  final UserEntity? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.verificationId,
    this.user,
    this.error,
  });

  /// Creates a copy with optional field updates.
  /// Fields set to explicit null will clear the value.
  AuthState copyWith({
    bool? isLoading,
    Object? verificationId = const _Optional.nullable(),
    Object? user = const _Optional.nullable(),
    Object? error = const _Optional.nullable(),
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      verificationId: verificationId is _Optional ? this.verificationId : verificationId as String?,
      user: user is _Optional ? this.user : user as UserEntity?,
      error: error is _Optional ? this.error : error as String?,
    );
  }

  /// Returns a cleared state (e.g., after sign-out).
  AuthState clear() => const AuthState();
}

/// Sentinel value for distinguishing "not passed" from "explicitly null".
class _Optional {
  final String? _value;
  const _Optional(this._value);
  const _Optional.nullable() : _value = null;
}

/// Provider for the [AuthRepository] instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firebaseDataSource: FirebaseAuthDataSource(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: null, // Uses default
    ),
    nodeDataSource: NodeAuthRemoteDataSource(),
  );
});

/// State notifier for authentication operations.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  /// Sends OTP to the given phone number.
  Future<void> sendOtp(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      state = state.copyWith(error: 'Please enter a phone number');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final verId = await _repository.sendOtp(phoneNumber);
      state = state.copyWith(isLoading: false, verificationId: verId);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: mapFirebaseAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong. Please try again.');
    }
  }

  /// Verifies OTP using the current verificationId.
  Future<void> verifyOtp(String smsCode) async {
    if (state.verificationId == null) return;
    if (smsCode.length != 6) {
      state = state.copyWith(error: 'OTP must be 6 digits');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.verifyOtp(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );
      // Persist tokens
      await SecureStorageService.setUserId(user.id);
      await SecureStorageService.setUserPhone(user.phone);
      state = state.copyWith(isLoading: false, user: user);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: mapFirebaseAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong. Please try again.');
    }
  }

  /// Signs in with Google.
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        await SecureStorageService.setUserId(user.id);
        await SecureStorageService.setUserPhone(user.phone);
        state = state.copyWith(isLoading: false, user: user);
      } else {
        // User canceled sign-in
        state = state.copyWith(isLoading: false);
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: mapFirebaseAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong. Please try again.');
    }
  }

  /// Clears the verification ID (navigate back to phone entry).
  void resetVerificationId() {
    state = state.copyWith(verificationId: null, error: null);
  }

  /// Signs out the current user and clears stored data.
  Future<void> signOut() async {
    await _repository.signOut();
    await SecureStorageService.clearAll();
    state = state.clear();
  }
}

/// Provider for the [AuthNotifier] instance.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
