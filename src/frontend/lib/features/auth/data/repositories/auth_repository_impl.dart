import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementation of [AuthRepository]
///
/// Handles the business logic and error handling for authentication operations
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.remoteDataSource});
  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return const Left(
          ServerFailure('Please enter both email and password'),
        );
      }

      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      developer.log('User signed in: ${user.id}', name: 'auth.repository');
      return Right(user);
    } on FirebaseAuthException catch (e) {
      developer.log(
        'FirebaseAuth error in signIn: ${e.code}',
        name: 'auth.repository',
        level: 1000,
      );

      String userMessage;
      switch (e.code) {
        case 'user-not-found':
          userMessage = 'No account found with this email';
        case 'wrong-password':
          userMessage = 'Incorrect password';
        case 'invalid-email':
          userMessage = 'Invalid email format';
        case 'user-disabled':
          userMessage = 'This account has been disabled';
        case 'too-many-requests':
          userMessage = 'Too many attempts. Please try again later';
        case 'network-request-failed':
          userMessage = 'Connection error. Please try again.';
        default:
          userMessage = 'Authentication failed';
      }
      return Left(ServerFailure(userMessage));
    } catch (e) {
      developer.log(
        'Unexpected error in signIn: $e',
        name: 'auth.repository',
        level: 1000,
      );
      return const Left(ServerFailure('Connection error. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required UserType userType,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return const Left(
          ServerFailure('Please fill in all required fields'),
        );
      }

      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
        name: name,
        userType: userType,
      );
      developer.log('User signed up: ${user.id}', name: 'auth.repository');
      return Right(user);
    } on FirebaseAuthException catch (e) {
      developer.log(
        'FirebaseAuth error in signUp: ${e.code}',
        name: 'auth.repository',
        level: 1000,
      );

      String userMessage;
      switch (e.code) {
        case 'email-already-in-use':
          userMessage = 'Email already registered';
        case 'weak-password':
          userMessage = 'Password is too weak';
        case 'invalid-email':
          userMessage = 'Invalid email format';
        case 'operation-not-allowed':
          userMessage = 'Registration is currently disabled';
        default:
          userMessage = 'Registration failed';
      }
      return Left(ServerFailure(userMessage));
    } catch (e) {
      developer.log(
        'Unexpected error in signUp: $e',
        name: 'auth.repository',
        level: 1000,
      );
      return const Left(ServerFailure('Connection error. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await remoteDataSource.signOut();
      developer.log('User signed out successfully', name: 'auth.repository');
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      developer.log(
        'FirebaseAuth error in signOut: ${e.code}',
        name: 'auth.repository',
        level: 1000,
      );
      return const Left(ServerFailure('Sign out failed'));
    } catch (e) {
      developer.log(
        'Unexpected error in signOut: $e',
        name: 'auth.repository',
        level: 1000,
      );
      return const Left(ServerFailure('Connection error. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      developer.log('Retrieved current user: ${user.id}', name: 'auth.repository');
      return Right(user);
    } on FirebaseAuthException catch (e) {
      developer.log(
        'FirebaseAuth error in getCurrentUser: ${e.code}',
        name: 'auth.repository',
        level: 1000,
      );

      String userMessage;
      switch (e.code) {
        case 'user-not-found':
          userMessage = 'User session expired. Please sign in again';
        case 'network-request-failed':
          userMessage = 'Network error. Check your connection';
        default:
          userMessage = 'Failed to get user data';
      }
      return Left(ServerFailure(userMessage));
    } catch (e) {
      developer.log(
        'Unexpected error in getCurrentUser: $e',
        name: 'auth.repository',
        level: 1000,
      );
      return const Left(ServerFailure('Connection error. Please try again.'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;
}
