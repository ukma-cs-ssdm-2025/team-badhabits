import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating user profile
class UpdateUserProfileUseCase {
  final ProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  /// Execute the update user profile operation
  ///
  /// [userId] - ID of the user to update
  /// [name] - New name (optional)
  /// [bio] - New bio (optional)
  /// [avatarUrl] - New avatar URL (optional)
  ///
  /// Returns [UserEntity] on success or [Failure] on error
  Future<Either<Failure, UserEntity>> call({
    required String userId,
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    return await repository.updateUserProfile(
      userId: userId,
      name: name,
      bio: bio,
      avatarUrl: avatarUrl,
    );
  }
}
