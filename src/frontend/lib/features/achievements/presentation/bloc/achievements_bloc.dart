import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/achievements/domain/usecases/get_user_achievements.dart';
import 'package:frontend/features/achievements/domain/usecases/unlock_achievement.dart'
    as usecase;
import 'package:frontend/features/achievements/domain/usecases/update_achievement_progress.dart'
    as usecase;
import 'package:frontend/features/achievements/presentation/bloc/achievements_event.dart';
import 'package:frontend/features/achievements/presentation/bloc/achievements_state.dart';

/// Achievements BLoC
///
/// Handles business logic for achievements feature (FR-008)
/// Coordinates between UI events and domain use cases
class AchievementsBloc extends Bloc<AchievementsEvent, AchievementsState> {
  AchievementsBloc({
    required this.getUserAchievements,
    required this.unlockAchievement,
    required this.updateAchievementProgress,
  }) : super(const AchievementsInitial()) {
    on<LoadAchievements>(_onLoadAchievements);
    on<UnlockAchievementEvent>(_onUnlockAchievement);
    on<UpdateAchievementProgressEvent>(_onUpdateAchievementProgress);
  }

  final GetUserAchievements getUserAchievements;
  final usecase.UnlockAchievement unlockAchievement;
  final usecase.UpdateAchievementProgress updateAchievementProgress;

  /// Handle LoadAchievements event
  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<AchievementsState> emit,
  ) async {
    emit(const AchievementsLoading());

    final result = await getUserAchievements(event.userId);

    result.fold(
      (failure) => emit(AchievementsError(message: _mapFailureToMessage(failure))),
      (achievements) => emit(AchievementsLoaded(result: achievements)),
    );
  }

  /// Handle UnlockAchievementEvent event
  Future<void> _onUnlockAchievement(
    UnlockAchievementEvent event,
    Emitter<AchievementsState> emit,
  ) async {
    emit(const AchievementsLoading());

    final result = await unlockAchievement(
      usecase.UnlockAchievementParams(
        userId: event.userId,
        achievementId: event.achievementId,
      ),
    );

    result.fold(
      (failure) => emit(AchievementsError(message: _mapFailureToMessage(failure))),
      (_) => emit(AchievementUnlocked(achievementId: event.achievementId)),
    );
  }

  /// Handle UpdateAchievementProgressEvent event
  Future<void> _onUpdateAchievementProgress(
    UpdateAchievementProgressEvent event,
    Emitter<AchievementsState> emit,
  ) async {
    emit(const AchievementsLoading());

    final result = await updateAchievementProgress(
      usecase.UpdateAchievementProgressParams(
        userId: event.userId,
        achievementId: event.achievementId,
        progress: event.progress,
      ),
    );

    result.fold(
      (failure) => emit(AchievementsError(message: _mapFailureToMessage(failure))),
      (_) => emit(
        AchievementProgressUpdated(
          achievementId: event.achievementId,
          progress: event.progress,
        ),
      ),
    );
  }

  /// Map Failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Unexpected error occurred';
  }
}
