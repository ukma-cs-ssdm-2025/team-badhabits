import 'package:equatable/equatable.dart';

/// Base class for all workout events
abstract class WorkoutsEvent extends Equatable {
  const WorkoutsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all workouts for current user
class LoadWorkouts extends WorkoutsEvent {
  const LoadWorkouts();
}

/// Event to load specific workout by ID
class LoadWorkoutDetails extends WorkoutsEvent {
  const LoadWorkoutDetails({required this.workoutId});

  final String workoutId;

  @override
  List<Object?> get props => [workoutId];
}

/// Event to filter workouts by criteria
class FilterWorkouts extends WorkoutsEvent {
  const FilterWorkouts({
    this.duration,
    this.equipment,
    this.difficulty,
  });

  final int? duration;
  final List<String>? equipment;
  final String? difficulty;

  @override
  List<Object?> get props => [duration, equipment, difficulty];
}

/// Event to start a new workout session
class StartWorkoutSession extends WorkoutsEvent {
  const StartWorkoutSession({
    required this.workoutId,
    required this.workoutTitle,
  });

  final String workoutId;
  final String workoutTitle;

  @override
  List<Object?> get props => [workoutId, workoutTitle];
}

/// Event to load active workout session (FR-013)
class LoadActiveWorkoutSession extends WorkoutsEvent {
  const LoadActiveWorkoutSession();
}

/// Event to complete workout session with rating (US-006)
class CompleteWorkoutSession extends WorkoutsEvent {
  const CompleteWorkoutSession({
    required this.sessionId,
    required this.difficultyRating,
    this.enjoymentRating,
    this.notes,
  });

  final String sessionId;
  final int difficultyRating;
  final int? enjoymentRating;
  final String? notes;

  @override
  List<Object?> get props => [
        sessionId,
        difficultyRating,
        enjoymentRating,
        notes,
      ];
}

/// Event to get recommended workout based on difficulty rating (FR-014)
class GetRecommendedWorkout extends WorkoutsEvent {
  const GetRecommendedWorkout({
    required this.workoutId,
    required this.difficultyRating,
  });

  final String workoutId;
  final int difficultyRating;

  @override
  List<Object?> get props => [workoutId, difficultyRating];
}

/// Event to load workout history
class LoadWorkoutHistory extends WorkoutsEvent {
  const LoadWorkoutHistory();
}
