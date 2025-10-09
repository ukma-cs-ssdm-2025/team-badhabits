import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/user_entity.dart';

/// Authentication repository interface
///
/// Defines the contract for authentication operations.
/// Implementation is in the data layer.
abstract class AuthRepository {
  /// Sign in with email and password
  ///
  /// Returns [UserEntity] on success or [Failure] on error
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Sign up with email, password, name, and user type
  ///
  /// Returns [UserEntity] on success or [Failure] on error
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required UserType userType,
  });

  /// Sign out the current user
  ///
  /// Returns [Unit] on success or [Failure] on error
  Future<Either<Failure, Unit>> signOut();

  /// Get the current authenticated user
  ///
  /// Returns [UserEntity] if user is authenticated or [Failure] if not
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Stream of authentication state changes
  ///
  /// Emits [UserEntity] when user is authenticated or null when not
  Stream<UserEntity?> get authStateChanges;
}
