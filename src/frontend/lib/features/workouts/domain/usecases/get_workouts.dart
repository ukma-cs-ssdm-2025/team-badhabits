import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/entities/workout.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Use case: Get all workouts for current user
///
/// Retrieves list of personalized workouts from repository
class GetWorkouts {
  GetWorkouts(this.repository);

  final WorkoutsRepository repository;

  Future<Either<Failure, List<Workout>>> call() async =>
      repository.getWorkouts();
}
