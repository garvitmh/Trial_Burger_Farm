import 'package:firebase_auth/firebase_auth.dart' as fb;
// Google Sign-In will require the `google_sign_in` package, which we will add next.
// We'll prepare the architecture for it now.
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/value_objects/auth_failures.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../datasources/auth_exception_mapper.dart';
import '../dto/auth_user_dto.dart';

/// FirebaseAuthRepository — Firebase implementation of the auth interface.
///
/// Handles raw Firebase communication, mapping responses to DTOs,
/// and catching exceptions to map them to Domain failures.
class FirebaseAuthRepository implements IAuthRepository {
  FirebaseAuthRepository(this._firebaseAuth, this._secureStorage);

  final fb.FirebaseAuth _firebaseAuth;
  final SecureStorageService _secureStorage;

  @override
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((fbUser) {
      if (fbUser == null) return null;
      return AuthUserDto.fromFirebaseUser(fbUser);
    });
  }

  @override
  AuthUser? get currentUser {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return AuthUserDto.fromFirebaseUser(fbUser);
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(Exception error) verificationFailed,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          // Automatic resolution on Android (SMS Retriever API).
          // Handled at the Controller/Notifier layer if needed, but we typically
          // pass this through or let the stream pick it up.
          try {
            await _firebaseAuth.signInWithCredential(credential);
          } catch (e) {
            verificationFailed(AuthExceptionMapper.map(e));
          }
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          verificationFailed(AuthExceptionMapper.map(e));
        },
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      throw AuthExceptionMapper.map(e);
    }
  }

  @override
  Future<AuthUser> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw const UnknownAuthFailure('User object is null after OTP verification.');
      }

      // Securely persist the session token
      final token = await user.getIdToken();
      if (token != null) {
        await _secureStorage.saveAuthToken(token);
      }

      return AuthUserDto.fromFirebaseUser(user);
    } catch (e) {
      throw AuthExceptionMapper.map(e);
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    // TODO(phase-3): Implement actual Google Sign-In flow using google_sign_in package.
    // This is structurally prepared, awaiting package integration.
    throw UnimplementedError('Google Sign-In is not yet fully integrated.');
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _secureStorage.clearSession();
    } catch (e) {
      throw AuthExceptionMapper.map(e);
    }
  }
}
