// ignore_for_file: avoid_print
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/habits/domain/usecases/add_habit_entry.dart';
import 'package:frontend/features/habits/domain/usecases/create_habit.dart';
import 'package:frontend/features/habits/domain/usecases/delete_habit.dart';
import 'package:frontend/features/habits/domain/usecases/get_entry_for_date.dart';
import 'package:frontend/features/habits/domain/usecases/get_habit_entries.dart';
import 'package:frontend/features/habits/domain/usecases/get_habit_statistics.dart';
import 'package:frontend/features/habits/domain/usecases/get_habits.dart';
import 'package:frontend/features/habits/domain/usecases/update_habit.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_event.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_state.dart';

/// BLoC for managing habits state
class HabitsBloc extends Bloc<HabitsEvent, HabitsState> {
  HabitsBloc({
    required this.getHabits,
    required this.createHabit,
    required this.updateHabit,
    required this.deleteHabit,
    required this.addHabitEntry,
    required this.getHabitEntries,
    required this.getEntryForDate,
    required this.getHabitStatistics,
  }) : super(const HabitsInitial()) {
    on<LoadHabitsEvent>(_onLoadHabits);
    on<CreateHabitEvent>(_onCreateHabit);
    on<UpdateHabitEvent>(_onUpdateHabit);
    on<DeleteHabitEvent>(_onDeleteHabit);
    on<AddEntryEvent>(_onAddEntry);
    on<LoadEntriesEvent>(_onLoadEntries);
    on<LoadEntryForDateEvent>(_onLoadEntryForDate);
    on<LoadHabitStatisticsEvent>(_onLoadHabitStatistics);
  }
  final GetHabits getHabits;
  final CreateHabit createHabit;
  final UpdateHabit updateHabit;
  final DeleteHabit deleteHabit;
  final AddHabitEntry addHabitEntry;
  final GetHabitEntries getHabitEntries;
  final GetEntryForDate getEntryForDate;
  final GetHabitStatistics getHabitStatistics;

  /// Handle load habits request
  Future<void> _onLoadHabits(
    LoadHabitsEvent event,
    Emitter<HabitsState> emit,
  ) async {
    print('🔵 HabitsBloc: Loading habits for user ${event.userId}...');
    emit(const HabitsLoading());

    final result = await getHabits(event.userId);

    result.fold(
      (failure) {
        print('🔴 HabitsBloc: Load failed - ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (habits) {
        print('🟢 HabitsBloc: Loaded ${habits.length} habits');
        emit(HabitsLoaded(habits));
      },
    );
  }

  /// Handle create habit request
  Future<void> _onCreateHabit(
    CreateHabitEvent event,
    Emitter<HabitsState> emit,
  ) async {
    print('🔵 HabitsBloc: Creating habit...');
    emit(const HabitsLoading());

    final result = await createHabit(event.habit);

    result.fold(
      (failure) {
        print('🔴 HabitsBloc: Create failed - ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (createdHabit) {
        print(
          '🟢 HabitsBloc: Habit created successfully with ID: ${createdHabit.id}',
        );
        // Emit success state - parent page will reload
        emit(const HabitsLoaded([]));
      },
    );
  }

  /// Handle update habit request
  Future<void> _onUpdateHabit(
    UpdateHabitEvent event,
    Emitter<HabitsState> emit,
  ) async {
    print('🔵 HabitsBloc: Updating habit...');
    emit(const HabitsLoading());

    final result = await updateHabit(event.habit);

    result.fold(
      (failure) {
        print('🔴 HabitsBloc: Update failed - ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (updatedHabit) {
        print('🟢 HabitsBloc: Habit updated successfully');
        // Emit success state - parent page will reload
        emit(const HabitsLoaded([]));
      },
    );
  }

  /// Handle delete habit request
  Future<void> _onDeleteHabit(
    DeleteHabitEvent event,
    Emitter<HabitsState> emit,
  ) async {
    // Get current userId from state
    String? userId;
    if (state is HabitsLoaded) {
      final currentState = state as HabitsLoaded;
      if (currentState.habits.isNotEmpty) {
        userId = currentState.habits.first.userId;
      }
    }

    emit(const HabitsLoading());

    final result = await deleteHabit(event.habitId);

    await result.fold((failure) async => emit(HabitsError(failure.message)), (
      _,
    ) async {
      // Reload habits after successful deletion
      if (userId != null) {
        final habitsResult = await getHabits(userId);
        habitsResult.fold(
          (failure) => emit(HabitsError(failure.message)),
          (habits) => emit(HabitsLoaded(habits)),
        );
      } else {
        emit(const HabitsError('Unable to reload habits: user ID not found'));
      }
    });
  }

  /// Handle add entry request
  Future<void> _onAddEntry(
    AddEntryEvent event,
    Emitter<HabitsState> emit,
  ) async {
    print('🔵 HabitsBloc: Adding entry for habit ${event.habitId}...');
    emit(const HabitsLoading());

    final result = await addHabitEntry(event.habitId, event.entry);

    result.fold(
      (failure) {
        print('🔴 HabitsBloc: Add entry failed - ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (addedEntry) {
        print(
          '🟢 HabitsBloc: Entry added successfully for date ${addedEntry.date}',
        );
        // Emit success state - parent page will reload
        emit(const HabitsLoaded([]));
      },
    );
  }

  /// Handle load entries request
  Future<void> _onLoadEntries(
    LoadEntriesEvent event,
    Emitter<HabitsState> emit,
  ) async {
    print('🔵 HabitsBloc: Loading entries for habit ${event.habitId}...');
    emit(const HabitsLoading());

    final result = await getHabitEntries(
      event.habitId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) {
        print('🔴 HabitsBloc: Load entries failed - ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (entries) {
        print('🟢 HabitsBloc: Loaded ${entries.length} entries');
        emit(EntriesLoaded(entries));
      },
    );
  }

  /// Handle load entry for date request
  Future<void> _onLoadEntryForDate(
    LoadEntryForDateEvent event,
    Emitter<HabitsState> emit,
  ) async {
    print(
      '🔵 HabitsBloc: Loading entry for habit ${event.habitId} on ${event.date}...',
    );
    emit(const HabitsLoading());

    final result = await getEntryForDate(event.habitId, event.date);

    result.fold(
      (failure) {
        print('🔴 HabitsBloc: Load entry for date failed - ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (entry) {
        if (entry != null) {
          print('🟢 HabitsBloc: Entry found for date ${event.date}');
        } else {
          print('🟡 HabitsBloc: No entry found for date ${event.date}');
        }
        emit(EntryForDateLoaded(entry));
      },
    );
  }

  /// Handle load habit statistics request
  Future<void> _onLoadHabitStatistics(
    LoadHabitStatisticsEvent event,
    Emitter<HabitsState> emit,
  ) async {
    print('🔵 HabitsBloc: Loading statistics for habit ${event.habitId}...');
    emit(const HabitsLoading());

    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: event.days));

    final statisticsResult = await getHabitStatistics(
      event.userId,
      event.habitId,
      startDate,
      endDate,
    );

    await statisticsResult.fold(
      (failure) async {
        print('🔴 HabitsBloc: Load statistics failed - ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (statistics) async {
        print('🟢 HabitsBloc: Statistics loaded successfully');

        // Load entries for charts
        final entriesResult = await getHabitEntries(
          event.habitId,
          startDate,
          endDate,
        );

        entriesResult.fold(
          (failure) {
            print('🔴 HabitsBloc: Load entries failed - ${failure.message}');
            emit(HabitsError(failure.message));
          },
          (entries) {
            print('🟢 HabitsBloc: Loaded ${entries.length} entries');
            emit(
              HabitStatisticsLoaded(
                statistics: statistics,
                habit: statistics.habit,
                entries: entries,
              ),
            );
          },
        );
      },
    );
  }
}
