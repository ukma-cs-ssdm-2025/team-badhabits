import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting the current authenticated user
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// Execute the get current user operation
  ///
  /// Returns [UserEntity] if authenticated or [Failure] if not
  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getCurrentUser();
  }
}
