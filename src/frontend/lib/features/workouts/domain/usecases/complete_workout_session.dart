import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Use case: Complete workout session
///
/// Completes workout session with user rating (US-006)
class CompleteWorkoutSession {
  CompleteWorkoutSession(this.repository);

  final WorkoutsRepository repository;

  Future<Either<Failure, void>> call(Params params) async =>
      repository.completeWorkoutSession(
        sessionId: params.sessionId,
        difficultyRating: params.difficultyRating,
        enjoymentRating: params.enjoymentRating,
        notes: params.notes,
      );
}

/// Parameters for completing workout session
class Params extends Equatable {
  const Params({
    required this.sessionId,
    required this.difficultyRating,
    this.enjoymentRating,
    this.notes,
  });

  final String sessionId;
  final int difficultyRating; // 1-5
  final int? enjoymentRating; // 1-5 (optional)
  final String? notes;

  @override
  List<Object?> get props =>
      [sessionId, difficultyRating, enjoymentRating, notes];
}
