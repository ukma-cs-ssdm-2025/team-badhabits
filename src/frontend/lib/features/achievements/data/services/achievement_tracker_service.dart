import 'package:frontend/features/achievements/domain/repositories/achievements_repository.dart';

/// Service for tracking and unlocking achievements automatically
///
/// This service checks user actions and unlocks/updates achievements accordingly
class AchievementTrackerService {
  AchievementTrackerService({
    required this.repository,
  });

  final AchievementsRepository repository;

  // ============================================
  // Achievement IDs (must match Firestore document IDs)
  // ============================================

  // Habit achievements
  static const String habitStarterId = 'habit_starter';
  static const String habitBuilderId = 'habit_builder';
  static const String habitExpertId = 'habit_expert';
  static const String habitMasterId = 'habit_master';

  // Streak achievements
  static const String streakBeginnerId = 'streak_beginner';
  static const String streakWarriorId = 'streak_warrior';
  static const String streakMasterId = 'streak_master';
  static const String streakLegendId = 'streak_legend';

  // Workout achievements
  static const String workoutRookieId = 'workout_rookie';
  static const String workoutWarriorId = 'workout_warrior';
  static const String workoutChampionId = 'workout_champion';
  static const String fitnessChampionId = 'fitness_champion';

  // Milestone achievements
  static const String gettingStartedId = 'getting_started';
  static const String firstWeekId = 'first_week';
  static const String firstMonthId = 'first_month';
  static const String dedicatedUserId = 'dedicated_user';

  // Special achievements
  static const String earlyBirdId = 'early_bird';
  static const String nightOwlId = 'night_owl';
  static const String perfectionistId = 'perfectionist';

  // ============================================
  // HABIT ACHIEVEMENTS
  // ============================================

  /// Check and update achievements after creating a habit
  Future<List<String>> onHabitCreated({
    required String userId,
    required int totalHabits,
  }) async {
    final unlockedAchievements = <String>[];

    // Habit Starter - Create your first habit (1)
    if (totalHabits >= 1) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: habitStarterId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Habit Starter');
      }
    }

    // Habit Builder - Create 5 habits
    if (totalHabits >= 5) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: habitBuilderId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Habit Builder');
      }
    } else if (totalHabits > 1) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: habitBuilderId,
        progress: totalHabits / 5,
      );
    }

    // Habit Master - Create 10 habits
    if (totalHabits >= 10) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: habitMasterId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Habit Master');
      }
    } else if (totalHabits > 1) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: habitMasterId,
        progress: totalHabits / 10,
      );
    }

    return unlockedAchievements;
  }

  // ============================================
  // WORKOUT ACHIEVEMENTS
  // ============================================

  /// Check and update achievements after completing a workout
  Future<List<String>> onWorkoutCompleted({
    required String userId,
    required int totalWorkouts,
    DateTime? completedAt,
  }) async {
    final unlockedAchievements = <String>[];

    // Workout Rookie - Complete your first workout (1)
    if (totalWorkouts >= 1) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: workoutRookieId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Workout Rookie');
      }
    }

    // Workout Warrior - Complete 10 workouts
    if (totalWorkouts >= 10) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: workoutWarriorId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Workout Warrior');
      }
    } else if (totalWorkouts > 1) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: workoutWarriorId,
        progress: totalWorkouts / 10,
      );
    }

    // Workout Champion - Complete 25 workouts
    if (totalWorkouts >= 25) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: workoutChampionId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Workout Champion');
      }
    } else if (totalWorkouts > 1) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: workoutChampionId,
        progress: totalWorkouts / 25,
      );
    }

    // Fitness Champion - Complete 50 workouts
    if (totalWorkouts >= 50) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: fitnessChampionId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Fitness Champion');
      }
    } else if (totalWorkouts > 1) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: fitnessChampionId,
        progress: totalWorkouts / 50,
      );
    }

    // Night Owl - Complete a workout after 10 PM
    if (completedAt != null && completedAt.hour >= 22) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: nightOwlId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Night Owl');
      }
    }

    return unlockedAchievements;
  }

  // ============================================
  // STREAK ACHIEVEMENTS
  // ============================================

  /// Check and update achievements after tracking a habit entry
  Future<List<String>> onHabitEntryAdded({
    required String userId,
    required int currentStreak,
    required int totalTrackingDays,
    DateTime? completedAt,
  }) async {
    final unlockedAchievements = <String>[];

    // Streak Beginner - 7 day streak
    if (currentStreak >= 7) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: streakBeginnerId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Streak Beginner');
      }
    } else if (currentStreak > 0) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: streakBeginnerId,
        progress: currentStreak / 7,
      );
    }

    // Streak Warrior - 14 day streak
    if (currentStreak >= 14) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: streakWarriorId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Streak Warrior');
      }
    } else if (currentStreak > 0) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: streakWarriorId,
        progress: currentStreak / 14,
      );
    }

    // Streak Master - 30 day streak
    if (currentStreak >= 30) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: streakMasterId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Streak Master');
      }
    } else if (currentStreak > 0) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: streakMasterId,
        progress: currentStreak / 30,
      );
    }

    // Streak Legend - 100 day streak
    if (currentStreak >= 100) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: streakLegendId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Streak Legend');
      }
    } else if (currentStreak > 0) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: streakLegendId,
        progress: currentStreak / 100,
      );
    }

    // Habit Expert - Track a habit for 30 days total
    if (totalTrackingDays >= 30) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: habitExpertId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Habit Expert');
      }
    } else if (totalTrackingDays > 0) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: habitExpertId,
        progress: totalTrackingDays / 30,
      );
    }

    // Early Bird - Complete a habit before 7 AM
    if (completedAt != null && completedAt.hour < 7) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: earlyBirdId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Early Bird');
      }
    }

    return unlockedAchievements;
  }

  // ============================================
  // SPECIAL ACHIEVEMENTS
  // ============================================

  /// Check perfectionist achievement - all habits completed in a day
  Future<List<String>> onAllHabitsCompletedForDay({
    required String userId,
  }) async {
    final unlockedAchievements = <String>[];

    final result = await repository.unlockAchievement(
      userId: userId,
      achievementId: perfectionistId,
    );
    if (result.isRight()) {
      unlockedAchievements.add('Perfectionist');
    }

    return unlockedAchievements;
  }

  // ============================================
  // MILESTONE ACHIEVEMENTS
  // ============================================

  /// Check and unlock getting started achievement after completing profile
  Future<List<String>> onProfileCompleted({
    required String userId,
  }) async {
    final unlockedAchievements = <String>[];

    final result = await repository.unlockAchievement(
      userId: userId,
      achievementId: gettingStartedId,
    );
    if (result.isRight()) {
      unlockedAchievements.add('Getting Started');
    }

    return unlockedAchievements;
  }

  /// Check app usage milestones
  Future<List<String>> onAppUsageUpdated({
    required String userId,
    required int totalDaysUsed,
  }) async {
    final unlockedAchievements = <String>[];

    // First Week - Use the app for 7 days
    if (totalDaysUsed >= 7) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: firstWeekId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('First Week');
      }
    } else if (totalDaysUsed > 0) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: firstWeekId,
        progress: totalDaysUsed / 7,
      );
    }

    // First Month - Use the app for 30 days
    if (totalDaysUsed >= 30) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: firstMonthId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('First Month');
      }
    } else if (totalDaysUsed > 0) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: firstMonthId,
        progress: totalDaysUsed / 30,
      );
    }

    // Dedicated User - Use the app for 100 days
    if (totalDaysUsed >= 100) {
      final result = await repository.unlockAchievement(
        userId: userId,
        achievementId: dedicatedUserId,
      );
      if (result.isRight()) {
        unlockedAchievements.add('Dedicated User');
      }
    } else if (totalDaysUsed > 0) {
      await repository.updateAchievementProgress(
        userId: userId,
        achievementId: dedicatedUserId,
        progress: totalDaysUsed / 100,
      );
    }

    return unlockedAchievements;
  }

  // ============================================
  // LEGACY METHODS (for backwards compatibility)
  // ============================================

  /// Legacy method - use onHabitEntryAdded instead
  Future<List<String>> onStreakUpdated({
    required String userId,
    required int currentStreak,
    required int trackingDays,
  }) =>
      onHabitEntryAdded(
        userId: userId,
        currentStreak: currentStreak,
        totalTrackingDays: trackingDays,
      );
}
