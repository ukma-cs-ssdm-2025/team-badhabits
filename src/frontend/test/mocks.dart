/// Mock Setup for Flutter Tests
/// Lab 6: Testing & Debugging
///
/// Generate mocks with: flutter pub run build_runner build --delete-conflicting-outputs
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';

// Generate mocks for Firebase services
@GenerateMocks([
  // Firebase Auth
  FirebaseAuth,
  UserCredential,
  User,

  // Firestore
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
void main() {}
