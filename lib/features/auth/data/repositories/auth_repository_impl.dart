import 'package:burger_farm_app/core/config/app_config.dart';
import 'package:burger_farm_app/features/auth/domain/entities/user_entity.dart';
import 'package:burger_farm_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:burger_farm_app/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:burger_farm_app/features/auth/data/datasources/node_auth_remote_data_source.dart';
import 'package:burger_farm_app/core/services/secure_storage_service.dart';

/// Implementation of [AuthRepository] that coordinates Firebase and backend auth.
///
/// Phase 0 (Firebase-only): Set [AppConfig.useFirebaseOnlyMode] = true to
/// skip backend JWT exchange during initial testing.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource firebaseDataSource;
  final NodeAuthRemoteDataSource nodeDataSource;

  AuthRepositoryImpl({
    required this.firebaseDataSource,
    required this.nodeDataSource,
  });

  @override
  Future<String> sendOtp(String phoneNumber) async {
    return firebaseDataSource.sendOtp(phoneNumber);
  }

  @override
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    // Step 1: Verify SMS with Firebase and sign in
    final userCredential = await firebaseDataSource.verifyOtp(verificationId, smsCode);
    final firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw Exception('Firebase authentication failed');
    }

    // Phase 0: Return Firebase user directly without calling Node.js backend.
    if (AppConfig.useFirebaseOnlyMode) {
      return UserEntity(
        id: firebaseUser.uid,
        phone: firebaseUser.phoneNumber ?? 'Unknown',
        token: null,
      );
    }

    // Production: Step 2 — Get Firebase ID token
    final idToken = await firebaseUser.getIdToken();

    if (idToken == null) {
      throw Exception('Failed to get Firebase ID Token');
    }

    // Production: Step 3 — Exchange Firebase ID token for backend JWT
    final backendData = await nodeDataSource.verifyIdToken(idToken);
    final token = backendData['token'] as String?;

    // Persist the backend JWT
    if (token != null) {
      await SecureStorageService.setAccessToken(token);
    }

    return UserEntity(
      id: backendData['user']['_id'] as String,
      phone: backendData['user']['phone'] as String,
      token: token,
    );
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    final userCredential = await firebaseDataSource.signInWithGoogle();

    if (userCredential == null) {
      return null; // User canceled
    }

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Firebase Google Auth failed');
    }

    if (AppConfig.useFirebaseOnlyMode) {
      return UserEntity(
        id: firebaseUser.uid,
        phone: firebaseUser.phoneNumber ?? firebaseUser.email ?? 'Unknown',
        token: null,
      );
    }

    final idToken = await firebaseUser.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to get Firebase ID Token');
    }

    final backendData = await nodeDataSource.verifyIdToken(idToken);
    final token = backendData['token'] as String?;

    if (token != null) {
      await SecureStorageService.setAccessToken(token);
    }

    return UserEntity(
      id: backendData['user']['_id'] as String,
      phone: backendData['user']['phone'] as String? ??
          backendData['user']['email'] as String? ??
          'Unknown',
      token: token,
    );
  }

  @override
  Future<void> signOut() async {
    await SecureStorageService.clearAll();
    await firebaseDataSource.signOut();
  }
}
