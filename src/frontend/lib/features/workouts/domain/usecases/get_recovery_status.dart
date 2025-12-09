import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/entities/recovery_status.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Use Case: Get Recovery Status (FR-006)
///
/// Returns personalized recovery recommendation based on training load.
/// Calls Railway backend API which analyzes workout sessions from last 7 days.
class GetRecoveryStatus {
  GetRecoveryStatus(this.repository);

  final WorkoutsRepository repository;

  Future<Either<Failure, RecoveryStatus>> call() =>
      repository.getRecoveryStatus();
}
