import 'package:equatable/equatable.dart';
import 'package:frontend/features/achievements/domain/usecases/get_user_achievements.dart';

/// Base class for all achievement states
abstract class AchievementsState extends Equatable {
  const AchievementsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AchievementsInitial extends AchievementsState {
  const AchievementsInitial();
}

/// Loading state
class AchievementsLoading extends AchievementsState {
  const AchievementsLoading();
}

/// State when achievements are successfully loaded
class AchievementsLoaded extends AchievementsState {
  const AchievementsLoaded({required this.result});

  final UserAchievementsResult result;

  @override
  List<Object?> get props => [result];
}

/// State when achievement is unlocked
class AchievementUnlocked extends AchievementsState {
  const AchievementUnlocked({required this.achievementId});

  final String achievementId;

  @override
  List<Object?> get props => [achievementId];
}

/// State when achievement progress is updated
class AchievementProgressUpdated extends AchievementsState {
  const AchievementProgressUpdated({
    required this.achievementId,
    required this.progress,
  });

  final String achievementId;
  final double progress;

  @override
  List<Object?> get props => [achievementId, progress];
}

/// Error state
class AchievementsError extends AchievementsState {
  const AchievementsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
