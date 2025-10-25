import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/entities/workout.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Use case: Get workout by ID
///
/// Retrieves specific workout details by workout ID
class GetWorkoutById {
  GetWorkoutById(this.repository);

  final WorkoutsRepository repository;

  Future<Either<Failure, Workout>> call(String workoutId) async =>
      repository.getWorkoutById(workoutId);
}
