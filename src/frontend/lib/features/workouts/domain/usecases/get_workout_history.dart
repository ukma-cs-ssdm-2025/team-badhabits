import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/entities/workout_session.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Use Case: Get Workout History
///
/// Returns list of completed workout sessions for current user
class GetWorkoutHistory {
  GetWorkoutHistory(this.repository);

  final WorkoutsRepository repository;

  Future<Either<Failure, List<WorkoutSession>>> call() async {
    return await repository.getWorkoutHistory();
  }
}
