import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase instance providers.
/// Ensures that widgets and repositories never access `Firebase*.instance` directly,
/// allowing for mock injection during testing and clean abstraction boundaries.

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/*
// Deferred to Phase 4 (Stores/Database)
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
*/
