import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing out the current user
class SignOutUseCase {
  SignOutUseCase(this.repository);
  final AuthRepository repository;

  /// Execute the sign out operation
  ///
  /// Returns [Unit] on success or [Failure] on error
  Future<Either<Failure, Unit>> call() async => repository.signOut();
}
