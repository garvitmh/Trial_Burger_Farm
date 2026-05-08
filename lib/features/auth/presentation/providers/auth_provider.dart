import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/firebase_auth_data_source.dart';
import '../../data/datasources/node_auth_remote_data_source.dart';

// Simple State class
class AuthState {
  final bool isLoading;
  final String? verificationId;
  final UserEntity? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.verificationId,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? verificationId,
    bool clearVerificationId = false,
    UserEntity? user,
    bool clearUser = false,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      verificationId:
          clearVerificationId ? null : verificationId ?? this.verificationId,
      user: clearUser ? null : user ?? this.user,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// The Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firebaseDataSource: FirebaseAuthDataSource(),
    nodeDataSource: NodeAuthRemoteDataSource(),
  );
});

// The State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  Future<void> sendOtp(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      state = state.copyWith(error: 'Please enter a phone number');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final verId = await _repository.sendOtp(phoneNumber);
      state = state.copyWith(isLoading: false, verificationId: verId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    if (state.verificationId == null) return;
    if (smsCode.length != 6) {
      state = state.copyWith(error: 'OTP must be 6 digits');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.verifyOtp(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        state = state.copyWith(isLoading: false, user: user);
      } else {
        // User canceled sign-in
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Go back to the phone entry screen
  void resetVerificationId() {
    state = state.copyWith(clearVerificationId: true, clearError: true);
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = AuthState(); // Reset to initial state
  }
}

// The State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
