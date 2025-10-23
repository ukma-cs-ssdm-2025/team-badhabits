import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Remote data source for authentication operations
///
/// Handles direct communication with Firebase Auth and Firestore
abstract class AuthRemoteDataSource {
  /// Sign in with email and password using Firebase Auth
  Future<UserModel> signIn({required String email, required String password});

  /// Sign up with email, password, name, and user type
  /// Creates user in Firebase Auth and stores user data in Firestore
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserType userType,
  });

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current authenticated user
  Future<UserModel> getCurrentUser();

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;
}

/// Implementation of [AuthRemoteDataSource]
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign in failed: user is null');
      }

      // Get user data from Firestore
      final userDoc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User document not found in Firestore');
      }

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserType userType,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign up failed: user is null');
      }

      final userId = userCredential.user!.uid;

      // Create user model
      final userModel = UserModel(
        id: userId,
        email: email,
        name: name,
        userType: userType,
        createdAt: DateTime.now(),
      );

      // Store user data in Firestore
      await firestore
          .collection('users')
          .doc(userId)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception('User document not found in Firestore');
      }

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw Exception('Get current user failed: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
        if (firebaseUser == null) {
          return null;
        }

        try {
          final userDoc = await firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

          if (!userDoc.exists) {
            return null;
          }

          return UserModel.fromFirestore(userDoc);
        } catch (e) {
          return null;
        }
      });

  /// Handle Firebase Auth exceptions and convert to readable messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Wrong password');
      case 'email-already-in-use':
        return Exception('An account already exists with this email');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'operation-not-allowed':
        return Exception('Operation not allowed');
      case 'too-many-requests':
        return Exception('Too many requests. Please try again later');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}
