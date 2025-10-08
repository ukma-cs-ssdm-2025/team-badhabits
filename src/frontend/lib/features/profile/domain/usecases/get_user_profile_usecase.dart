import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

/// Use case for getting user profile
class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  /// Execute the get user profile operation
  ///
  /// [userId] - ID of the user to get profile for
  ///
  /// Returns [UserEntity] on success or [Failure] on error
  Future<Either<Failure, UserEntity>> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}
