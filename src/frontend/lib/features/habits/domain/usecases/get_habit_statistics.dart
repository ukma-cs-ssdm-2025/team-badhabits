import 'package:dartz/dartz.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/domain/repositories/habits_repository.dart';

/// Statistics for a habit field
class HabitFieldStatistics {
  const HabitFieldStatistics({
    required this.fieldLabel,
    required this.fieldType,
    this.average,
    this.min,
    this.max,
    this.total,
    this.count,
    this.completionRate,
  });

  final String fieldLabel;
  final String fieldType;
  final double? average; // For number/rating fields
  final double? min; // For number/rating fields
  final double? max; // For number/rating fields
  final double? total; // For number fields
  final int? count; // Total entries
  final double? completionRate; // Percentage of days completed
}

/// Overall habit statistics
class HabitStatistics {
  const HabitStatistics({
    required this.habit,
    required this.fieldStatistics,
    required this.totalEntries,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastEntryDate,
  });

  final Habit habit;
  final List<HabitFieldStatistics> fieldStatistics;
  final int totalEntries;
  final int currentStreak; // Days in a row
  final int longestStreak;
  final DateTime? lastEntryDate;
}

/// Use case for calculating habit statistics
class GetHabitStatistics {
  GetHabitStatistics(this.repository);
  final HabitsRepository repository;

  /// Calculate statistics for a habit within a date range
  ///
  /// [userId] - ID of the user who owns the habit
  /// [habitId] - ID of the habit
  /// [startDate] - Start of the period
  /// [endDate] - End of the period
  ///
  /// Returns [HabitStatistics] on success or [Failure] on error
  Future<Either<Failure, HabitStatistics>> call(
    String userId,
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Get entries for the period
    final entriesResult = await repository.getEntries(
      habitId,
      startDate,
      endDate,
    );

    return entriesResult.fold(
      Left.new,
      (entries) async {
        // Get habit details
        final habitsResult = await repository.getHabits(userId);

        return habitsResult.fold(
          Left.new,
          (habits) {
            // Find the specific habit
            final habit = habits.firstWhere(
              (h) => h.id == habitId,
              orElse: () => throw Exception('Habit not found'),
            );

            // Calculate statistics for each field
            final fieldStats = <HabitFieldStatistics>[];

            for (final field in habit.fields) {
              final values = <dynamic>[];
              for (final entry in entries) {
                if (entry.values.containsKey(field.label)) {
                  values.add(entry.values[field.label]);
                }
              }

              if (field.type == 'number' || field.type == 'rating') {
                final numericValues = values
                    .whereType<num>()
                    .map<double>((v) => v.toDouble())
                    .toList();

                if (numericValues.isNotEmpty) {
                  final avg = numericValues.reduce((a, b) => a + b) /
                      numericValues.length;
                  final min = numericValues.reduce(
                    (a, b) => a < b ? a : b,
                  );
                  final max = numericValues.reduce(
                    (a, b) => a > b ? a : b,
                  );
                  final total = field.type == 'number'
                      ? numericValues.reduce((a, b) => a + b)
                      : null;

                  fieldStats.add(
                    HabitFieldStatistics(
                      fieldLabel: field.label,
                      fieldType: field.type,
                      average: avg,
                      min: min,
                      max: max,
                      total: total,
                      count: numericValues.length,
                    ),
                  );
                }
              }
            }

            // Calculate streaks
            final sortedEntries = entries.toList()
              ..sort((a, b) => b.date.compareTo(a.date));

            var currentStreak = 0;
            var longestStreak = 0;
            var tempStreak = 0;
            DateTime? lastDate;

            for (final entry in sortedEntries) {
              final entryDate = DateTime.parse(entry.date);

              if (lastDate == null) {
                tempStreak = 1;
                lastDate = entryDate;
              } else {
                final daysDiff = lastDate.difference(entryDate).inDays;

                if (daysDiff == 1) {
                  tempStreak++;
                } else {
                  if (tempStreak > longestStreak) {
                    longestStreak = tempStreak;
                  }
                  tempStreak = 1;
                }

                lastDate = entryDate;
              }
            }

            // Check if streak is current
            if (sortedEntries.isNotEmpty) {
              final mostRecentDate = DateTime.parse(sortedEntries.first.date);
              final today = DateTime.now();
              final daysSinceLastEntry = today.difference(mostRecentDate).inDays;

              if (daysSinceLastEntry <= 1) {
                currentStreak = tempStreak;
              }
            }

            if (tempStreak > longestStreak) {
              longestStreak = tempStreak;
            }

            return Right(
              HabitStatistics(
                habit: habit,
                fieldStatistics: fieldStats,
                totalEntries: entries.length,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastEntryDate: sortedEntries.isNotEmpty
                    ? DateTime.parse(sortedEntries.first.date)
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
