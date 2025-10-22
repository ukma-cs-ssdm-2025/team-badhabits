import 'package:dartz/dartz.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/habits/domain/repositories/habits_repository.dart';

/// Use case for deleting a habit
class DeleteHabit {
  DeleteHabit(this.repository);
  final HabitsRepository repository;

  /// Execute the delete habit operation
  ///
  /// [habitId] - ID of the habit to delete
  ///
  /// Returns [void] on success or [Failure] on error
  Future<Either<Failure, void>> call(String habitId) async =>
      repository.deleteHabit(habitId);
}
