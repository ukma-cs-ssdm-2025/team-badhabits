import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up a new user
class SignUpUseCase {
  SignUpUseCase(this.repository);
  final AuthRepository repository;

  /// Execute the sign up operation
  ///
  /// [email] - User's email address
  /// [password] - User's password
  /// [name] - User's display name
  /// [userType] - Type of user (regular or trainer)
  ///
  /// Returns [UserEntity] on success or [Failure] on error
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String name,
    required UserType userType,
  }) async => repository.signUp(
    email: email,
    password: password,
    name: name,
    userType: userType,
  );
}
