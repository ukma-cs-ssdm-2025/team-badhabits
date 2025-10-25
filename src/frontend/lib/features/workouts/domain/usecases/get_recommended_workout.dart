import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/entities/workout.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Use case: Get recommended workout
///
/// Gets adaptive workout recommendation from Railway backend API (FR-014)
/// Backend adapts workout based on user's difficulty rating
class GetRecommendedWorkout {
  GetRecommendedWorkout(this.repository);

  final WorkoutsRepository repository;

  Future<Either<Failure, Workout>> call(Params params) async =>
      repository.getRecommendedWorkout(
        workoutId: params.workoutId,
        difficultyRating: params.difficultyRating,
      );
}

/// Parameters for getting recommended workout
class Params extends Equatable {
  const Params({required this.workoutId, required this.difficultyRating});

  final String workoutId;
  final int difficultyRating; // 1-5 (1=too easy, 5=too hard)

  @override
  List<Object> get props => [workoutId, difficultyRating];
}
