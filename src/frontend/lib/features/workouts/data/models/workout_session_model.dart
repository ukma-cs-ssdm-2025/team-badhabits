import 'package:frontend/features/workouts/domain/entities/workout_session.dart';

/// Workout Session Model (data layer)
///
/// Handles JSON serialization/deserialization for WorkoutSession entity
class WorkoutSessionModel extends WorkoutSession {
  const WorkoutSessionModel({
    required super.id,
    required super.userId,
    required super.workoutId,
    required super.workoutTitle,
    required super.status,
    required super.startedAt,
    super.completedAt,
    super.pausedAt,
    super.totalDurationSeconds,
    super.completedExercises,
    super.currentExerciseIndex,
    super.difficultyRating,
    super.enjoymentRating,
    super.notes,
    super.caloriesBurned,
  });

  /// Create WorkoutSessionModel from domain entity
  factory WorkoutSessionModel.fromEntity(WorkoutSession session) =>
      WorkoutSessionModel(
        id: session.id,
        userId: session.userId,
        workoutId: session.workoutId,
        workoutTitle: session.workoutTitle,
        status: session.status,
        startedAt: session.startedAt,
        completedAt: session.completedAt,
        pausedAt: session.pausedAt,
        totalDurationSeconds: session.totalDurationSeconds,
        completedExercises: session.completedExercises,
        currentExerciseIndex: session.currentExerciseIndex,
        difficultyRating: session.difficultyRating,
        enjoymentRating: session.enjoymentRating,
        notes: session.notes,
        caloriesBurned: session.caloriesBurned,
      );

  /// Create WorkoutSessionModel from JSON
  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) =>
      WorkoutSessionModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        workoutId: json['workout_id'] as String,
        workoutTitle: json['workout_title'] as String,
        status: json['status'] as String,
        startedAt: json['started_at'] is String
            ? DateTime.parse(json['started_at'] as String)
            : (json['started_at'] as DateTime),
        completedAt: json['completed_at'] != null
            ? (json['completed_at'] is String
                ? DateTime.parse(json['completed_at'] as String)
                : (json['completed_at'] as DateTime))
            : null,
        pausedAt: json['paused_at'] != null
            ? (json['paused_at'] is String
                ? DateTime.parse(json['paused_at'] as String)
                : (json['paused_at'] as DateTime))
            : null,
        totalDurationSeconds: json['total_duration_seconds'] as int?,
        completedExercises: json['completed_exercises'] as int?,
        currentExerciseIndex: json['current_exercise_index'] as int?,
        difficultyRating: json['difficulty_rating'] as int?,
        enjoymentRating: json['enjoyment_rating'] as int?,
        notes: json['notes'] as String?,
        caloriesBurned: json['calories_burned'] as int?,
      );

  /// Convert WorkoutSessionModel to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'workout_id': workoutId,
        'workout_title': workoutTitle,
        'status': status,
        'started_at': startedAt.toIso8601String(),
        if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
        if (pausedAt != null) 'paused_at': pausedAt!.toIso8601String(),
        if (totalDurationSeconds != null)
          'total_duration_seconds': totalDurationSeconds,
        if (completedExercises != null) 'completed_exercises': completedExercises,
        if (currentExerciseIndex != null)
          'current_exercise_index': currentExerciseIndex,
        if (difficultyRating != null) 'difficulty_rating': difficultyRating,
        if (enjoymentRating != null) 'enjoyment_rating': enjoymentRating,
        if (notes != null) 'notes': notes,
        if (caloriesBurned != null) 'calories_burned': caloriesBurned,
      };

  /// Convert to domain entity
  WorkoutSession toEntity() => WorkoutSession(
        id: id,
        userId: userId,
        workoutId: workoutId,
        workoutTitle: workoutTitle,
        status: status,
        startedAt: startedAt,
        completedAt: completedAt,
        pausedAt: pausedAt,
        totalDurationSeconds: totalDurationSeconds,
        completedExercises: completedExercises,
        currentExerciseIndex: currentExerciseIndex,
        difficultyRating: difficultyRating,
        enjoymentRating: enjoymentRating,
        notes: notes,
        caloriesBurned: caloriesBurned,
      );
}
