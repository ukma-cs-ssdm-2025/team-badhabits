import 'package:equatable/equatable.dart';
import 'package:frontend/features/workouts/domain/entities/exercise.dart';

/// Workout entity (domain layer)
///
/// Represents a complete workout plan with exercises.
/// Can be adaptive (parameters change based on user ratings) or static.
class Workout extends Equatable {
  const Workout({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.exercises,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.difficulty,
    required this.difficultyScore,
    required this.isAdaptive,
    required this.equipmentRequired,
    required this.targetMuscleGroups,
    required this.isVerified,
    required this.isPublic,
    required this.accessType,
    this.price,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.tags,
  });

  /// Unique workout identifier
  final String id;

  /// User ID (for personalized workouts)
  final String userId;

  /// Workout title (e.g., "Morning HIIT", "Beginner Strength")
  final String title;

  /// Workout description
  final String description;

  /// List of exercises in this workout
  final List<Exercise> exercises;

  /// Total duration in minutes
  final int durationMinutes;

  /// Estimated calories burned
  final int estimatedCalories;

  /// Difficulty level: beginner, intermediate, advanced, expert
  final String difficulty;

  /// Numeric difficulty score (1-10)
  final int difficultyScore;

  /// Whether this workout has adaptive parameters (FR-014)
  final bool isAdaptive;

  /// Required equipment (e.g., ['dumbbells', 'resistance_bands'])
  final List<String> equipmentRequired;

  /// Target muscle groups (e.g., ['chest', 'legs', 'core'])
  final List<String> targetMuscleGroups;

  /// Whether this workout is verified (FR-011)
  final bool isVerified;

  /// Whether this workout is public
  final bool isPublic;

  /// Access type: free, paid, invite_only (FR-012)
  final String accessType;

  /// Price for paid workouts (optional)
  final double? price;

  /// Creator user ID (trainer)
  final String createdBy;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Tags for filtering (e.g., ['beginner', 'fat-burn', 'bodyweight'])
  final List<String>? tags;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        exercises,
        durationMinutes,
        estimatedCalories,
        difficulty,
        difficultyScore,
        isAdaptive,
        equipmentRequired,
        targetMuscleGroups,
        isVerified,
        isPublic,
        accessType,
        price,
        createdBy,
        createdAt,
        updatedAt,
        tags,
      ];

  /// Copy workout with updated parameters
  Workout copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<Exercise>? exercises,
    int? durationMinutes,
    int? estimatedCalories,
    String? difficulty,
    int? difficultyScore,
    bool? isAdaptive,
    List<String>? equipmentRequired,
    List<String>? targetMuscleGroups,
    bool? isVerified,
    bool? isPublic,
    String? accessType,
    double? price,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) =>
      Workout(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description ?? this.description,
        exercises: exercises ?? this.exercises,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        estimatedCalories: estimatedCalories ?? this.estimatedCalories,
        difficulty: difficulty ?? this.difficulty,
        difficultyScore: difficultyScore ?? this.difficultyScore,
        isAdaptive: isAdaptive ?? this.isAdaptive,
        equipmentRequired: equipmentRequired ?? this.equipmentRequired,
        targetMuscleGroups: targetMuscleGroups ?? this.targetMuscleGroups,
        isVerified: isVerified ?? this.isVerified,
        isPublic: isPublic ?? this.isPublic,
        accessType: accessType ?? this.accessType,
        price: price ?? this.price,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        tags: tags ?? this.tags,
      );
}
