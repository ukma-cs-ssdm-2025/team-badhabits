import 'package:dartz/dartz.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/domain/repositories/habits_repository.dart';

/// Use case for updating an existing habit
class UpdateHabit {
  UpdateHabit(this.repository);
  final HabitsRepository repository;

  /// Execute the update habit operation
  ///
  /// [habit] - The habit with updated data
  ///
  /// Returns [Habit] on success or [Failure] on error
  Future<Either<Failure, Habit>> call(Habit habit) async =>
      repository.updateHabit(habit);
}
