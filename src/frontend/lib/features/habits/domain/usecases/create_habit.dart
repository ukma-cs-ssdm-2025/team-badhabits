import 'package:dartz/dartz.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/domain/repositories/habits_repository.dart';

/// Use case for creating a new habit
class CreateHabit {
  CreateHabit(this.repository);
  final HabitsRepository repository;

  /// Execute the create habit operation
  ///
  /// [habit] - The habit to create
  ///
  /// Returns [Habit] on success or [Failure] on error
  Future<Either<Failure, Habit>> call(Habit habit) async =>
      repository.createHabit(habit);
}
