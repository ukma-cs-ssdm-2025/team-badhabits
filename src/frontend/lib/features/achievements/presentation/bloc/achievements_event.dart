import 'package:equatable/equatable.dart';

/// Base class for all achievement events
abstract class AchievementsEvent extends Equatable {
  const AchievementsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user's achievements
class LoadAchievements extends AchievementsEvent {
  const LoadAchievements({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event to unlock an achievement
class UnlockAchievementEvent extends AchievementsEvent {
  const UnlockAchievementEvent({
    required this.userId,
    required this.achievementId,
  });

  final String userId;
  final String achievementId;

  @override
  List<Object?> get props => [userId, achievementId];
}

/// Event to update achievement progress
class UpdateAchievementProgressEvent extends AchievementsEvent {
  const UpdateAchievementProgressEvent({
    required this.userId,
    required this.achievementId,
    required this.progress,
  });

  final String userId;
  final String achievementId;
  final double progress;

  @override
  List<Object?> get props => [userId, achievementId, progress];
}
