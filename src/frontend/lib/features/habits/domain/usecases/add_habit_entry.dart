import 'package:dartz/dartz.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/domain/repositories/habits_repository.dart';

/// Use case for adding a tracking entry to a habit
class AddHabitEntry {
  AddHabitEntry(this.repository);
  final HabitsRepository repository;

  /// Execute the add habit entry operation
  ///
  /// [habitId] - ID of the habit to track
  /// [entry] - The entry containing date and field values
  ///
  /// Returns [HabitEntry] on success or [Failure] on error
  Future<Either<Failure, HabitEntry>> call(
    String habitId,
    HabitEntry entry,
  ) async => repository.addEntry(habitId, entry);
}
