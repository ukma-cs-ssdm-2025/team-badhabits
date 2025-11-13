import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Use Case: Cancel Workout Session
///
/// Cancels active workout session and removes lock from Realtime Database
class CancelWorkoutSession {
  CancelWorkoutSession(this.repository);

  final WorkoutsRepository repository;

  Future<Either<Failure, void>> call(CancelWorkoutSessionParams params) =>
      repository.cancelWorkoutSession(sessionId: params.sessionId);
}

/// Parameters for CancelWorkoutSession use case
class CancelWorkoutSessionParams extends Equatable {
  const CancelWorkoutSessionParams({required this.sessionId});

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}
