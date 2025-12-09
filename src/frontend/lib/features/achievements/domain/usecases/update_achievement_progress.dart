import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/achievements/domain/entities/user_achievement.dart';
import 'package:frontend/features/achievements/domain/repositories/achievements_repository.dart';

/// Use case for updating achievement progress for a user
class UpdateAchievementProgress {
  UpdateAchievementProgress(this.repository);

  final AchievementsRepository repository;

  Future<Either<Failure, UserAchievement>> call(
    UpdateAchievementProgressParams params,
  ) =>
      repository.updateAchievementProgress(
        userId: params.userId,
        achievementId: params.achievementId,
        progress: params.progress,
      );
}

/// Parameters for UpdateAchievementProgress use case
class UpdateAchievementProgressParams {
  const UpdateAchievementProgressParams({
    required this.userId,
    required this.achievementId,
    required this.progress,
  });

  final String userId;
  final String achievementId;
  final double progress;
}
