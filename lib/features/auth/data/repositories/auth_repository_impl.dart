import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../datasources/node_auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource firebaseDataSource;
  final NodeAuthRemoteDataSource nodeDataSource;

  /// Set this to true to skip the Node.js backend call during Phase 0 testing.
  /// When false (production), the Firebase ID token is exchanged for a backend JWT.
  static const bool _phase0FirebaseOnlyMode = true;

  AuthRepositoryImpl({
    required this.firebaseDataSource,
    required this.nodeDataSource,
  });

  @override
  Future<String> sendOtp(String phoneNumber) async {
    return await firebaseDataSource.sendOtp(phoneNumber);
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
    // This lets you test the full OTP flow without the backend server running.
    if (_phase0FirebaseOnlyMode) {
      return UserEntity(
        id: firebaseUser.uid,
        phone: firebaseUser.phoneNumber ?? 'Unknown',
        token: null, // No backend JWT in Phase 0 mode
      );
    }

    // Production: Step 2 — Get Firebase ID token
    final idToken = await firebaseUser.getIdToken();

    if (idToken == null) {
      throw Exception('Failed to get Firebase ID Token');
    }

    // Production: Step 3 — Exchange Firebase ID token for backend JWT
    final backendData = await nodeDataSource.verifyIdToken(idToken);

    return UserEntity(
      id: backendData['user']['_id'],
      phone: backendData['user']['phone'],
      token: backendData['token'],
    );
  }
}
