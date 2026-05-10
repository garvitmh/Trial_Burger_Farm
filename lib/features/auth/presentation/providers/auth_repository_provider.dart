import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../../../app/firebase/firebase_providers.dart';
import '../../../../core/security/secure_storage_service.dart';

/// authRepositoryProvider — Global access to the IAuthRepository.
///
/// Injects FirebaseAuth and SecureStorageService into the FirebaseAuthRepository.
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  
  return FirebaseAuthRepository(firebaseAuth, secureStorage);
});
