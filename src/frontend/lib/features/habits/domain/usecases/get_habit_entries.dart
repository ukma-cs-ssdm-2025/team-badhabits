import 'package:dartz/dartz.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/domain/repositories/habits_repository.dart';

/// Use case for retrieving habit entries within a date range
class GetHabitEntries {
  GetHabitEntries(this.repository);
  final HabitsRepository repository;

  /// Execute the get habit entries operation
  ///
  /// [habitId] - ID of the habit
  /// [startDate] - Start of the date range (inclusive)
  /// [endDate] - End of the date range (inclusive)
  ///
  /// Returns [List<HabitEntry>] on success or [Failure] on error
  Future<Either<Failure, List<HabitEntry>>> call(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async => repository.getEntries(habitId, startDate, endDate);
}
