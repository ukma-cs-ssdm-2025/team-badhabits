import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/achievements/domain/entities/user_achievement.dart';
import 'package:frontend/features/achievements/domain/repositories/achievements_repository.dart';

/// Use case for unlocking an achievement for a user
class UnlockAchievement {
  UnlockAchievement(this.repository);

  final AchievementsRepository repository;

  Future<Either<Failure, UserAchievement>> call(
    UnlockAchievementParams params,
  ) =>
      repository.unlockAchievement(
        userId: params.userId,
        achievementId: params.achievementId,
      );
}

/// Parameters for UnlockAchievement use case
class UnlockAchievementParams {
  const UnlockAchievementParams({
    required this.userId,
    required this.achievementId,
  });

  final String userId;
  final String achievementId;
}
