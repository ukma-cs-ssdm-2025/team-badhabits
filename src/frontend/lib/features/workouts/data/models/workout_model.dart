import 'package:frontend/features/workouts/data/models/exercise_model.dart';
import 'package:frontend/features/workouts/domain/entities/workout.dart';

/// Workout Model (data layer)
///
/// Handles JSON serialization/deserialization for Workout entity
class WorkoutModel extends Workout {
  const WorkoutModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.durationMinutes,
    required super.estimatedCalories,
    required super.difficulty,
    required super.difficultyScore,
    required super.isAdaptive,
    required super.isVerified,
    required super.isPublic,
    required super.accessType,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required super.exercises,
    required super.equipmentRequired,
    required super.targetMuscleGroups,
    super.price,
    super.tags,
  });

  /// Create WorkoutModel from domain entity
  factory WorkoutModel.fromEntity(Workout workout) => WorkoutModel(
        id: workout.id,
        userId: workout.userId,
        title: workout.title,
        description: workout.description,
        exercises: workout.exercises,
        durationMinutes: workout.durationMinutes,
        estimatedCalories: workout.estimatedCalories,
        difficulty: workout.difficulty,
        difficultyScore: workout.difficultyScore,
        isAdaptive: workout.isAdaptive,
        equipmentRequired: workout.equipmentRequired,
        targetMuscleGroups: workout.targetMuscleGroups,
        isVerified: workout.isVerified,
        isPublic: workout.isPublic,
        accessType: workout.accessType,
        price: workout.price,
        createdBy: workout.createdBy,
        createdAt: workout.createdAt,
        updatedAt: workout.updatedAt,
        tags: workout.tags,
      );

  /// Create WorkoutModel from JSON
  factory WorkoutModel.fromJson(Map<String, dynamic> json) => WorkoutModel(
        id: json['id'] as String,
        userId: json['user_id'] as String? ?? '', // Optional for public workouts
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        exercises: (json['exercises'] as List<dynamic>)
            .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        durationMinutes: json['duration_minutes'] as int? ??
            json['total_duration_minutes'] as int,
        estimatedCalories: json['estimated_calories'] as int,
        difficulty: json['difficulty'] as String,
        difficultyScore: json['difficulty_score'] as int? ?? 1, // Default to 1
        isAdaptive: json['is_adaptive'] as bool? ?? false,
        equipmentRequired: (json['equipment_required'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        targetMuscleGroups: (json['target_muscle_groups'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            (json['target_areas'] as List<dynamic>?) // Fallback to target_areas
                ?.map((e) => e as String)
                .toList() ??
            [],
        isVerified: json['is_verified'] as bool? ?? false,
        isPublic: json['is_public'] as bool? ?? true,
        accessType: json['access_type'] as String? ?? 'free',
        price: json['price'] != null ? (json['price'] as num).toDouble() : null,
        createdBy: json['created_by'] as String? ?? 'system', // Default to 'system' for public workouts
        createdAt: json['created_at'] is String
            ? DateTime.parse(json['created_at'] as String)
            : (json['created_at'] as DateTime),
        updatedAt: json['updated_at'] is String
            ? DateTime.parse(json['updated_at'] as String)
            : (json['updated_at'] as DateTime),
        tags: (json['tags'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
            (json['category'] != null ? [json['category'] as String] : null), // Fallback to category
      );

  /// Convert WorkoutModel to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'exercises': exercises
            .map((e) => ExerciseModel.fromEntity(e).toJson())
            .toList(),
        'duration_minutes': durationMinutes,
        'estimated_calories': estimatedCalories,
        'difficulty': difficulty,
        'difficulty_score': difficultyScore,
        'is_adaptive': isAdaptive,
        'equipment_required': equipmentRequired,
        'target_muscle_groups': targetMuscleGroups,
        'is_verified': isVerified,
        'is_public': isPublic,
        'access_type': accessType,
        if (price != null) 'price': price,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        if (tags != null) 'tags': tags,
      };

  /// Convert to domain entity
  Workout toEntity() => Workout(
        id: id,
        userId: userId,
        title: title,
        description: description,
        exercises: exercises,
        durationMinutes: durationMinutes,
        estimatedCalories: estimatedCalories,
        difficulty: difficulty,
        difficultyScore: difficultyScore,
        isAdaptive: isAdaptive,
        equipmentRequired: equipmentRequired,
        targetMuscleGroups: targetMuscleGroups,
        isVerified: isVerified,
        isPublic: isPublic,
        accessType: accessType,
        price: price,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: tags,
      );
}
