import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/entities/workout.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Use Case: Get Filtered Workouts (US-005)
///
/// Returns workouts filtered by duration, equipment, and difficulty
class GetFilteredWorkouts {
  GetFilteredWorkouts(this.repository);

  final WorkoutsRepository repository;

  Future<Either<Failure, List<Workout>>> call(
          GetFilteredWorkoutsParams params) =>
      repository.getFilteredWorkouts(
        duration: params.duration,
        equipment: params.equipment,
        difficulty: params.difficulty,
      );
}

/// Parameters for filtering workouts
class GetFilteredWorkoutsParams extends Equatable {
  const GetFilteredWorkoutsParams({
    this.duration,
    this.equipment,
    this.difficulty,
  });

  final int? duration;
  final List<String>? equipment;
  final String? difficulty;

  @override
  List<Object?> get props => [duration, equipment, difficulty];
}
