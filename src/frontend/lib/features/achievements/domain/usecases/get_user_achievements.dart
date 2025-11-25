import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/achievements/domain/entities/achievement.dart';
import 'package:frontend/features/achievements/domain/entities/user_achievement.dart';
import 'package:frontend/features/achievements/domain/repositories/achievements_repository.dart';

/// Use case for getting user's achievements with achievement definitions
class GetUserAchievements {
  GetUserAchievements(this.repository);

  final AchievementsRepository repository;

  Future<Either<Failure, UserAchievementsResult>> call(String userId) async {
    // Get all achievement definitions
    final achievementsResult = await repository.getAchievements();

    // Get user's achievements
    final userAchievementsResult = await repository.getUserAchievements(userId);

    return achievementsResult.fold(
      Left.new,
      (achievements) => userAchievementsResult.fold(
        Left.new,
        (userAchievements) => Right(
          UserAchievementsResult(
            achievements: achievements,
            userAchievements: userAchievements,
          ),
        ),
      ),
    );
  }
}

/// Result containing both achievement definitions and user achievements
class UserAchievementsResult {
  const UserAchievementsResult({
    required this.achievements,
    required this.userAchievements,
  });

  final List<Achievement> achievements;
  final List<UserAchievement> userAchievements;

  /// Get achievement definition by ID
  Achievement? getAchievement(String achievementId) {
    try {
      return achievements.firstWhere((a) => a.id == achievementId);
    } catch (e) {
      return null;
    }
  }

  /// Get user achievement by achievement ID
  UserAchievement? getUserAchievement(String achievementId) {
    try {
      return userAchievements.firstWhere(
        (ua) => ua.achievementId == achievementId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get unlocked achievements
  List<Achievement> get unlockedAchievements {
    final unlockedIds = userAchievements
        .where((ua) => ua.isUnlocked)
        .map((ua) => ua.achievementId)
        .toSet();

    return achievements.where((a) => unlockedIds.contains(a.id)).toList();
  }

  /// Get locked achievements
  List<Achievement> get lockedAchievements {
    final unlockedIds = userAchievements
        .map((ua) => ua.achievementId)
        .toSet();

    return achievements.where((a) => !unlockedIds.contains(a.id)).toList();
  }

  /// Get in-progress achievements
  List<Achievement> get inProgressAchievements {
    final inProgressIds = userAchievements
        .where((ua) => !ua.isUnlocked && ua.progress > 0)
        .map((ua) => ua.achievementId)
        .toSet();

    return achievements.where((a) => inProgressIds.contains(a.id)).toList();
  }
}
