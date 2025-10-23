import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in a user
class SignInUseCase {
  SignInUseCase(this.repository);
  final AuthRepository repository;

  /// Execute the sign in operation
  ///
  /// [email] - User's email address
  /// [password] - User's password
  ///
  /// Returns [UserEntity] on success or [Failure] on error
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async => repository.signIn(email: email, password: password);
}
