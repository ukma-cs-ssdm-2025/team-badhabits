import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/achievements/domain/entities/achievement.dart';
import 'package:frontend/features/achievements/domain/entities/user_achievement.dart';

/// Achievements Repository Interface
///
/// Defines the contract for achievements data operations
abstract class AchievementsRepository {
  /// Get all available achievements
  Future<Either<Failure, List<Achievement>>> getAchievements();

  /// Get user's achievements (both unlocked and in-progress)
  Future<Either<Failure, List<UserAchievement>>> getUserAchievements(
    String userId,
  );

  /// Unlock an achievement for a user
  Future<Either<Failure, UserAchievement>> unlockAchievement({
    required String userId,
    required String achievementId,
  });

  /// Update achievement progress
  Future<Either<Failure, UserAchievement>> updateAchievementProgress({
    required String userId,
    required String achievementId,
    required double progress,
  });
}
