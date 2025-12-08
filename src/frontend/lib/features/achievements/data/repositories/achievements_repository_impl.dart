import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/achievements/data/datasources/achievements_firestore_datasource.dart';
import 'package:frontend/features/achievements/domain/entities/achievement.dart';
import 'package:frontend/features/achievements/domain/entities/user_achievement.dart';
import 'package:frontend/features/achievements/domain/repositories/achievements_repository.dart';

/// Achievements Repository Implementation (data layer)
///
/// Implements AchievementsRepository interface using Firestore data source
class AchievementsRepositoryImpl implements AchievementsRepository {
  AchievementsRepositoryImpl({
    required this.firestoreDataSource,
  });

  final AchievementsFirestoreDataSource firestoreDataSource;

  @override
  Future<Either<Failure, List<Achievement>>> getAchievements() async {
    try {
      final achievementModels = await firestoreDataSource.getAchievements();
      final achievements =
          achievementModels.map((model) => model.toEntity()).toList();
      return Right(achievements);
    } catch (e) {
      return Left(ServerFailure('Failed to get achievements: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserAchievement>>> getUserAchievements(
    String userId,
  ) async {
    try {
      final userAchievementModels =
          await firestoreDataSource.getUserAchievements(userId);
      final userAchievements =
          userAchievementModels.map((model) => model.toEntity()).toList();
      return Right(userAchievements);
    } catch (e) {
      return Left(ServerFailure('Failed to get user achievements: $e'));
    }
  }

  @override
  Future<Either<Failure, UserAchievement>> unlockAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      final userAchievementModel = await firestoreDataSource.unlockAchievement(
        userId: userId,
        achievementId: achievementId,
      );
      return Right(userAchievementModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to unlock achievement: $e'));
    }
  }

  @override
  Future<Either<Failure, UserAchievement>> updateAchievementProgress({
    required String userId,
    required String achievementId,
    required double progress,
  }) async {
    try {
      final userAchievementModel =
          await firestoreDataSource.updateAchievementProgress(
        userId: userId,
        achievementId: achievementId,
        progress: progress,
      );
      return Right(userAchievementModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to update achievement progress: $e'));
    }
  }
}
