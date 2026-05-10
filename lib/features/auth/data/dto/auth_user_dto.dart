import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/auth_user.dart';

/// AuthUserDto — Data Transfer Object for mapping Firebase User to Domain AuthUser.
///
/// Enforces the architectural boundary by preventing Firebase classes from
/// leaking into the domain or presentation layers.
abstract final class AuthUserDto {
  static AuthUser fromFirebaseUser(fb.User firebaseUser) {
    return AuthUser(
      id: firebaseUser.uid,
      phoneNumber: firebaseUser.phoneNumber,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isAnonymous: firebaseUser.isAnonymous,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }
}
