import 'package:equatable/equatable.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/domain/usecases/get_habit_statistics.dart';

/// Base class for habits states
abstract class HabitsState extends Equatable {
  const HabitsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any habits are loaded
class HabitsInitial extends HabitsState {
  const HabitsInitial();
}

/// Loading state while fetching/creating/updating/deleting habits
class HabitsLoading extends HabitsState {
  const HabitsLoading();
}

/// Successfully loaded habits state
class HabitsLoaded extends HabitsState {
  const HabitsLoaded(this.habits);
  final List<Habit> habits;

  @override
  List<Object?> get props => [habits];
}

/// Successfully loaded entries state
class EntriesLoaded extends HabitsState {
  const EntriesLoaded(this.entries);
  final List<HabitEntry> entries;

  @override
  List<Object?> get props => [entries];
}

/// Successfully loaded entry for date state
class EntryForDateLoaded extends HabitsState {
  const EntryForDateLoaded(this.entry);
  final HabitEntry? entry;

  @override
  List<Object?> get props => [entry];
}

/// Error state with error message
class HabitsError extends HabitsState {
  const HabitsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Successfully loaded habit statistics state
class HabitStatisticsLoaded extends HabitsState {
  const HabitStatisticsLoaded({
    required this.statistics,
    required this.habit,
    required this.entries,
  });
  final HabitStatistics statistics;
  final Habit habit;
  final List<HabitEntry> entries;

  @override
  List<Object?> get props => [statistics, habit, entries];
}
