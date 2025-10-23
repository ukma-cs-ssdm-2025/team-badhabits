import 'package:dartz/dartz.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';

/// Habits repository interface
///
/// Defines the contract for habits operations.
/// Implementation is in the data layer.
abstract class HabitsRepository {
  /// Get all habits for a specific user
  ///
  /// Parameters:
  /// - [userId]: The ID of the user whose habits to retrieve
  ///
  /// Returns [List<Habit>] on success or [Failure] on error
  Future<Either<Failure, List<Habit>>> getHabits(String userId);

  /// Create a new habit
  ///
  /// Parameters:
  /// - [habit]: The habit entity to create
  ///
  /// Returns [Habit] on success or [Failure] on error
  Future<Either<Failure, Habit>> createHabit(Habit habit);

  /// Update an existing habit
  ///
  /// Parameters:
  /// - [habit]: The habit entity with updated data
  ///
  /// Returns [Habit] on success or [Failure] on error
  Future<Either<Failure, Habit>> updateHabit(Habit habit);

  /// Delete a habit by ID
  ///
  /// Parameters:
  /// - [habitId]: The ID of the habit to delete
  ///
  /// Returns [void] on success or [Failure] on error
  Future<Either<Failure, void>> deleteHabit(String habitId);

  /// Add a tracking entry for a specific habit
  ///
  /// Parameters:
  /// - [habitId]: The ID of the habit to track
  /// - [entry]: The entry containing date and field values
  ///
  /// Returns [HabitEntry] on success or [Failure] on error
  Future<Either<Failure, HabitEntry>> addEntry(
    String habitId,
    HabitEntry entry,
  );

  /// Get all entries for a habit within a date range
  ///
  /// Parameters:
  /// - [habitId]: The ID of the habit
  /// - [startDate]: Start of the date range (inclusive)
  /// - [endDate]: End of the date range (inclusive)
  ///
  /// Returns [List<HabitEntry>] on success or [Failure] on error
  Future<Either<Failure, List<HabitEntry>>> getEntries(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get a specific entry for a habit on a given date
  ///
  /// Parameters:
  /// - [habitId]: The ID of the habit
  /// - [date]: The date in YYYY-MM-DD format
  ///
  /// Returns [HabitEntry?] on success (null if no entry exists) or [Failure] on error
  Future<Either<Failure, HabitEntry?>> getEntryForDate(
    String habitId,
    String date,
  );
}
