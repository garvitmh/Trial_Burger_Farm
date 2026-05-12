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

      // ID token persistence is managed by AuthSessionManager's
      // idTokenChanges listener (audit fix I-2) — no direct save here.

      return AuthUserDto.fromFirebaseUser(user);
    } catch (e) {
      throw AuthExceptionMapper.map(e);
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      // Audit fix I-15: if a non-anonymous user is already signed in, sign
      // them out first (and clear cached secure-storage session). Otherwise
      // `signInWithCredential` would silently replace user A with user B,
      // which is a session-hijack vector on shared / lost devices. Anonymous
      // users (guest sessions) can be upgraded freely.
      final existing = _firebaseAuth.currentUser;
      if (existing != null && !existing.isAnonymous) {
        await _firebaseAuth.signOut();
        await _secureStorage.clearSession();
      }

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

      // ID token persistence is now managed by AuthSessionManager's
      // idTokenChanges listener (audit fix I-2). No direct save here.

      return AuthUserDto.fromFirebaseUser(user);
    } catch (e) {
      throw AuthExceptionMapper.map(e);
    }
  }

  @override
  Future<AuthUser> signInAsGuest() async {
    try {
      final existing = _firebaseAuth.currentUser;
      if (existing != null && existing.isAnonymous) {
        // Already anonymous — reuse the session.
        return AuthUserDto.fromFirebaseUser(existing);
      }
      if (existing != null) {
        // A real user is signed in. Refuse silently — caller should sign
        // them out explicitly first.
        return AuthUserDto.fromFirebaseUser(existing);
      }
      final result = await _firebaseAuth.signInAnonymously();
      final user = result.user;
      if (user == null) {
        throw const UnknownAuthFailure(
          'Firebase returned a null user after anonymous sign-in.',
        );
      }
      return AuthUserDto.fromFirebaseUser(user);
    } catch (e) {
      throw AuthExceptionMapper.map(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out both Firebase and Google so the next sign-in surfaces the
      // account picker correctly. Google `signOut` is best-effort: any
      // network failure shouldn't block Firebase sign-out.
      try {
        await _googleSignIn.signOut();
      } catch (_) {/* best-effort */}
      await _firebaseAuth.signOut();
      await _secureStorage.clearSession();
    } catch (e) {
      throw AuthExceptionMapper.map(e);
    }
  }
}
