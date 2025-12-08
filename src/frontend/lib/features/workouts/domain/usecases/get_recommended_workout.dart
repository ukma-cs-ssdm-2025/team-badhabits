import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/entities/workout_recommendation.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Use case: Get recommended workout
///
/// Gets adaptive workout recommendation from Railway backend API (FR-014)
/// Backend adapts workout based on user's workout history and ratings
class GetRecommendedWorkout {
  GetRecommendedWorkout(this.repository);

  final WorkoutsRepository repository;

  Future<Either<Failure, WorkoutRecommendation>> call() async =>
      repository.getRecommendedWorkout();
}
