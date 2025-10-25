import 'package:equatable/equatable.dart';

/// Exercise entity (domain layer)
///
/// Represents a single exercise within a workout.
/// Contains both static parameters (name, description) and
/// adaptive parameters (sets, reps, weight) that can change based on user feedback.
class Exercise extends Equatable {
  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    this.weight,
    this.durationSeconds,
    required this.restSeconds,
    required this.difficulty,
    required this.affectedAreas,
    this.equipment,
    this.caloriesBurned,
    this.videoUrl,
    this.imageUrl,
    this.instructions,
  });

  /// Unique exercise identifier
  final String id;

  /// Exercise name (e.g., "Push-ups", "Squats")
  final String name;

  /// Description of the exercise technique
  final String description;

  /// Number of sets (can be adaptive)
  final int sets;

  /// Number of repetitions per set (can be adaptive)
  final int reps;

  /// Weight in kg (optional, can be adaptive for weighted exercises)
  final double? weight;

  /// Duration in seconds (for exercises like plank, wall sits)
  final int? durationSeconds;

  /// Rest time between sets in seconds
  final int restSeconds;

  /// Difficulty level (1-10)
  final int difficulty;

  /// Muscle groups affected (e.g., ['chest', 'triceps', 'core'])
  final List<String> affectedAreas;

  /// Required equipment (e.g., 'dumbbells', 'resistance_bands', 'bodyweight')
  final String? equipment;

  /// Estimated calories burned for this exercise
  final int? caloriesBurned;

  /// URL to video demonstration (optional)
  final String? videoUrl;

  /// URL to image demonstration (optional)
  final String? imageUrl;

  /// Step-by-step instructions (optional)
  final List<String>? instructions;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        sets,
        reps,
        weight,
        durationSeconds,
        restSeconds,
        difficulty,
        affectedAreas,
        equipment,
        caloriesBurned,
        videoUrl,
        imageUrl,
        instructions,
      ];

  /// Copy exercise with updated parameters (for adaptation)
  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    int? sets,
    int? reps,
    double? weight,
    int? durationSeconds,
    int? restSeconds,
    int? difficulty,
    List<String>? affectedAreas,
    String? equipment,
    int? caloriesBurned,
    String? videoUrl,
    String? imageUrl,
    List<String>? instructions,
  }) =>
      Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        sets: sets ?? this.sets,
        reps: reps ?? this.reps,
        weight: weight ?? this.weight,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        restSeconds: restSeconds ?? this.restSeconds,
        difficulty: difficulty ?? this.difficulty,
        affectedAreas: affectedAreas ?? this.affectedAreas,
        equipment: equipment ?? this.equipment,
        caloriesBurned: caloriesBurned ?? this.caloriesBurned,
        videoUrl: videoUrl ?? this.videoUrl,
        imageUrl: imageUrl ?? this.imageUrl,
        instructions: instructions ?? this.instructions,
      );
}
