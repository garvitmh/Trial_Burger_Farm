import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
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
  FirebaseAuthRepository(
    this._firebaseAuth,
    this._secureStorage, {
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              // Web client ID from android/app/google-services.json
              // (oauth_client entry with client_type: 3). Required by
              // Firebase Auth so the returned idToken is accepted as a
              // GoogleAuthProvider credential on Android.
              serverClientId:
                  '284811640366-1hgtvm0t56dfgsu3sqa4fm67v79obvu5.apps.googleusercontent.com',
              scopes: const ['email', 'profile'],
            );

  final fb.FirebaseAuth _firebaseAuth;
  final SecureStorageService _secureStorage;
  final GoogleSignIn _googleSignIn;

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
    try {
      // Sign out any cached Google account first so the account picker always
      // shows; without this, switching accounts is impossible on Android.
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User dismissed the account picker — domain failure, not exception.
        throw const SignInCancelledFailure();
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;
      if (idToken == null || accessToken == null) {
        throw const CredentialFailure(
          'Google returned an empty credential. Check the OAuth web client ID.',
        );
      }

      final credential = fb.GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw const UnknownAuthFailure(
          'Firebase returned a null user after Google sign-in.',
        );
      }

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
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _secureStorage.clearSession();
    } catch (e) {
      throw AuthExceptionMapper.map(e);
    }
  }
}
