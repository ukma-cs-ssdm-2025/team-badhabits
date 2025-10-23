import 'package:equatable/equatable.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';

/// Base class for habits events
abstract class HabitsEvent extends Equatable {
  const HabitsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all habits for a user
class LoadHabitsEvent extends HabitsEvent {
  const LoadHabitsEvent(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event to create a new habit
class CreateHabitEvent extends HabitsEvent {
  const CreateHabitEvent(this.habit);
  final Habit habit;

  @override
  List<Object?> get props => [habit];
}

/// Event to update an existing habit
class UpdateHabitEvent extends HabitsEvent {
  const UpdateHabitEvent(this.habit);
  final Habit habit;

  @override
  List<Object?> get props => [habit];
}

/// Event to delete a habit
class DeleteHabitEvent extends HabitsEvent {
  const DeleteHabitEvent(this.habitId);
  final String habitId;

  @override
  List<Object?> get props => [habitId];
}

/// Event to add a tracking entry to a habit
class AddEntryEvent extends HabitsEvent {
  const AddEntryEvent(this.habitId, this.entry);
  final String habitId;
  final HabitEntry entry;

  @override
  List<Object?> get props => [habitId, entry];
}

/// Event to load entries for a habit within a date range
class LoadEntriesEvent extends HabitsEvent {
  const LoadEntriesEvent(this.habitId, this.startDate, this.endDate);
  final String habitId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [habitId, startDate, endDate];
}

/// Event to load a specific entry for a habit on a given date
class LoadEntryForDateEvent extends HabitsEvent {
  const LoadEntryForDateEvent(this.habitId, this.date);
  final String habitId;
  final String date;

  @override
  List<Object?> get props => [habitId, date];
}
