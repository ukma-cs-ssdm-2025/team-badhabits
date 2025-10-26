import 'package:equatable/equatable.dart';

/// Workout Session entity (domain layer)
///
/// Represents an active or completed workout session.
/// Tracks user's actual workout performance (FR-013: блокування паралельних сесій).
class WorkoutSession extends Equatable {
  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.workoutTitle,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.pausedAt,
    this.totalDurationSeconds,
    this.completedExercises,
    this.currentExerciseIndex,
    this.difficultyRating,
    this.enjoymentRating,
    this.notes,
    this.caloriesBurned,
  });

  /// Unique session identifier
  final String id;

  /// User ID who is doing the workout
  final String userId;

  /// Workout ID being performed
  final String workoutId;

  /// Workout title (for display)
  final String workoutTitle;

  /// Session status: active, paused, completed, cancelled
  final String status;

  /// Session start timestamp
  final DateTime startedAt;

  /// Session completion timestamp (null if not completed)
  final DateTime? completedAt;

  /// Session pause timestamp (null if not paused)
  final DateTime? pausedAt;

  /// Total duration in seconds (when completed)
  final int? totalDurationSeconds;

  /// Number of exercises completed
  final int? completedExercises;

  /// Current exercise index (for active sessions)
  final int? currentExerciseIndex;

  /// Difficulty rating (1-5) - US-006: оцінка складності
  final int? difficultyRating;

  /// Enjoyment rating (1-5) - optional
  final int? enjoymentRating;

  /// User notes about the session
  final String? notes;

  /// Actual calories burned (calculated)
  final int? caloriesBurned;

  @override
  List<Object?> get props => [
        id,
        userId,
        workoutId,
        workoutTitle,
        status,
        startedAt,
        completedAt,
        pausedAt,
        totalDurationSeconds,
        completedExercises,
        currentExerciseIndex,
        difficultyRating,
        enjoymentRating,
        notes,
        caloriesBurned,
      ];

  /// Copy session with updated parameters
  WorkoutSession copyWith({
    String? id,
    String? userId,
    String? workoutId,
    String? workoutTitle,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? pausedAt,
    int? totalDurationSeconds,
    int? completedExercises,
    int? currentExerciseIndex,
    int? difficultyRating,
    int? enjoymentRating,
    String? notes,
    int? caloriesBurned,
  }) =>
      WorkoutSession(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        workoutId: workoutId ?? this.workoutId,
        workoutTitle: workoutTitle ?? this.workoutTitle,
        status: status ?? this.status,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        pausedAt: pausedAt ?? this.pausedAt,
        totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
        completedExercises: completedExercises ?? this.completedExercises,
        currentExerciseIndex:
            currentExerciseIndex ?? this.currentExerciseIndex,
        difficultyRating: difficultyRating ?? this.difficultyRating,
        enjoymentRating: enjoymentRating ?? this.enjoymentRating,
        notes: notes ?? this.notes,
        caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      );

  /// Check if session is active
  bool get isActive => status == 'active';

  /// Check if session is completed
  bool get isCompleted => status == 'completed';

  /// Check if session is paused
  bool get isPaused => status == 'paused';
}
