import 'package:frontend/features/workouts/domain/entities/exercise.dart';

/// Exercise Model (data layer)
///
/// Handles JSON serialization/deserialization for Exercise entity
class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.name,
    required super.description,
    required super.sets,
    required super.reps,
    super.weight,
    super.durationSeconds,
    required super.restSeconds,
    required super.difficulty,
    required super.affectedAreas,
    super.equipment,
    super.caloriesBurned,
    super.videoUrl,
    super.imageUrl,
    super.instructions,
  });

  /// Create ExerciseModel from JSON
  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
        id: json['id'] as String? ?? '', // Auto-generate if missing
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        sets: json['sets'] as int? ?? 1,
        reps: json['reps'] as int? ?? 0, // 0 for time-based exercises
        weight: json['weight_kg'] != null
            ? (json['weight_kg'] as num).toDouble()
            : null,
        durationSeconds: json['duration_seconds'] as int?,
        restSeconds: json['rest_seconds'] as int? ?? 60, // Default 60 seconds rest
        difficulty: json['difficulty'] as int? ?? 1, // Default difficulty 1
        affectedAreas: (json['affected_areas'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [], // Empty list if not specified
        equipment: json['equipment'] as String?,
        caloriesBurned: json['calories_burned'] as int?,
        videoUrl: json['video_url'] as String?,
        imageUrl: json['image_url'] as String?,
        instructions: json['instructions'] != null
            ? (json['instructions'] as List<dynamic>)
                .map((e) => e as String)
                .toList()
            : null,
      );

  /// Convert ExerciseModel to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'sets': sets,
        'reps': reps,
        if (weight != null) 'weight_kg': weight,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
        'rest_seconds': restSeconds,
        'difficulty': difficulty,
        'affected_areas': affectedAreas,
        if (equipment != null) 'equipment': equipment,
        if (caloriesBurned != null) 'calories_burned': caloriesBurned,
        if (videoUrl != null) 'video_url': videoUrl,
        if (imageUrl != null) 'image_url': imageUrl,
        if (instructions != null) 'instructions': instructions,
      };

  /// Create ExerciseModel from domain entity
  factory ExerciseModel.fromEntity(Exercise exercise) => ExerciseModel(
        id: exercise.id,
        name: exercise.name,
        description: exercise.description,
        sets: exercise.sets,
        reps: exercise.reps,
        weight: exercise.weight,
        durationSeconds: exercise.durationSeconds,
        restSeconds: exercise.restSeconds,
        difficulty: exercise.difficulty,
        affectedAreas: exercise.affectedAreas,
        equipment: exercise.equipment,
        caloriesBurned: exercise.caloriesBurned,
        videoUrl: exercise.videoUrl,
        imageUrl: exercise.imageUrl,
        instructions: exercise.instructions,
      );

  /// Convert to domain entity
  Exercise toEntity() => Exercise(
        id: id,
        name: name,
        description: description,
        sets: sets,
        reps: reps,
        weight: weight,
        durationSeconds: durationSeconds,
        restSeconds: restSeconds,
        difficulty: difficulty,
        affectedAreas: affectedAreas,
        equipment: equipment,
        caloriesBurned: caloriesBurned,
        videoUrl: videoUrl,
        imageUrl: imageUrl,
        instructions: instructions,
      );
}
