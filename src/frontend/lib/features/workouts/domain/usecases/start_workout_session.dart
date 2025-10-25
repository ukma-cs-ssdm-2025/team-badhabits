import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/entities/workout_session.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Use case: Start workout session
///
/// Starts a new workout session and implements FR-013 (parallel session blocking)
class StartWorkoutSession {
  StartWorkoutSession(this.repository);

  final WorkoutsRepository repository;

  Future<Either<Failure, WorkoutSession>> call(Params params) async =>
      repository.startWorkoutSession(
        workoutId: params.workoutId,
        workoutTitle: params.workoutTitle,
      );
}

/// Parameters for starting workout session
class Params extends Equatable {
  const Params({required this.workoutId, required this.workoutTitle});

  final String workoutId;
  final String workoutTitle;

  @override
  List<Object> get props => [workoutId, workoutTitle];
}
