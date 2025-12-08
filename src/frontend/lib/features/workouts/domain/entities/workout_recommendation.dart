import 'package:equatable/equatable.dart';
import 'package:frontend/features/workouts/domain/entities/workout.dart';

/// Workout recommendation entity with reason (FR-014)
///
/// Contains the recommended workout and explanation of why it was chosen
class WorkoutRecommendation extends Equatable {
  const WorkoutRecommendation({
    required this.workout,
    required this.reason,
    required this.basedOnSessions,
    required this.targetDifficulty,
    required this.userFitnessLevel,
    this.averageRating,
  });

  /// The recommended workout
  final Workout workout;

  /// Human-readable explanation of why this workout was recommended
  final String reason;

  /// Number of past sessions used to calculate recommendation
  final int basedOnSessions;

  /// Average difficulty rating from past sessions (1-5)
  final double? averageRating;

  /// Target difficulty level (beginner, intermediate, advanced)
  final String targetDifficulty;

  /// User's current fitness level
  final String userFitnessLevel;

  @override
  List<Object?> get props => [
        workout,
        reason,
        basedOnSessions,
        averageRating,
        targetDifficulty,
        userFitnessLevel,
      ];
}
