import 'package:dartz/dartz.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/domain/repositories/habits_repository.dart';

/// Use case for retrieving a specific habit entry for a given date
class GetEntryForDate {
  GetEntryForDate(this.repository);
  final HabitsRepository repository;

  /// Execute the get entry for date operation
  ///
  /// [habitId] - ID of the habit
  /// [date] - The date in YYYY-MM-DD format
  ///
  /// Returns [HabitEntry?] on success (null if no entry exists) or [Failure] on error
  Future<Either<Failure, HabitEntry?>> call(
    String habitId,
    String date,
  ) async => repository.getEntryForDate(habitId, date);
}
