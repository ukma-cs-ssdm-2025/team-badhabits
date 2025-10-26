import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/entities/workout_session.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Use case: Get active workout session
///
/// Checks if user has an active workout session (for FR-013: parallel session blocking)
/// Returns null if no active session exists
class GetActiveWorkoutSession {
  GetActiveWorkoutSession(this.repository);

  final WorkoutsRepository repository;

  Future<Either<Failure, WorkoutSession?>> call() async =>
      repository.getActiveWorkoutSession();
}
