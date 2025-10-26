import 'package:hive/hive.dart';
import '../models/habit_entry_hive_model.dart';
import '../models/habit_hive_model.dart';
import '../models/habit_model.dart';

/// Local data source for habits using Hive for offline storage
abstract class HabitsLocalDataSource {
  // Habits CRUD
  Future<List<HabitModel>> getCachedHabits(String userId);
  Future<void> cacheHabit(HabitModel habit, {bool isPending = false});
  Future<void> cacheHabits(List<HabitModel> habits);
  Future<void> deleteCachedHabit(String habitId);
  Future<HabitModel?> getCachedHabit(String habitId);

  // Habit Entries CRUD
  Future<List<HabitEntryHiveModel>> getCachedEntries(String habitId);
  Future<void> cacheEntry(
    HabitEntryHiveModel entry, {
    bool isPending = false,
  });
  Future<void> cacheEntries(List<HabitEntryHiveModel> entries);
  Future<HabitEntryHiveModel?> getCachedEntryForDate(
    String habitId,
    String date,
  );

  // Sync management
  Future<List<HabitModel>> getPendingSyncHabits();
  Future<List<HabitEntryHiveModel>> getPendingSyncEntries();
  Future<void> markHabitAsSynced(String habitId);
  Future<void> markEntryAsSynced(String entryId);
  Future<void> clearAllCache();
}

/// Implementation of HabitsLocalDataSource using Hive
class HabitsLocalDataSourceImpl implements HabitsLocalDataSource {
  final Box<HabitHiveModel> habitsBox;
  final Box<HabitEntryHiveModel> entriesBox;

  HabitsLocalDataSourceImpl({
    required this.habitsBox,
    required this.entriesBox,
  });

  @override
  Future<List<HabitModel>> getCachedHabits(String userId) async {
    final habits = habitsBox.values.where((h) => h.userId == userId).toList();

    return habits.map((h) => HabitModel.fromEntity(h.toEntity())).toList();
  }

  @override
  Future<void> cacheHabit(HabitModel habit, {bool isPending = false}) async {
    final hiveModel =
        HabitHiveModel.fromEntity(habit).copyWith(isPendingSync: isPending);
    await habitsBox.put(habit.id, hiveModel);
  }

  @override
  Future<void> cacheHabits(List<HabitModel> habits) async {
    final map = {
      for (final habit in habits) habit.id: HabitHiveModel.fromEntity(habit),
    };
    await habitsBox.putAll(map);
  }

  @override
  Future<void> deleteCachedHabit(String habitId) async {
    await habitsBox.delete(habitId);

    // Also delete related entries
    final entriesToDelete = entriesBox.values
        .where((entry) => entry.habitId == habitId)
        .map((entry) => entry.id)
        .toList();

    for (final entryId in entriesToDelete) {
      await entriesBox.delete(entryId);
    }
  }

  @override
  Future<HabitModel?> getCachedHabit(String habitId) async {
    final hiveModel = habitsBox.get(habitId);
    if (hiveModel == null) {
      return null;
    }
    return HabitModel.fromEntity(hiveModel.toEntity());
  }

  @override
  Future<List<HabitEntryHiveModel>> getCachedEntries(String habitId) async {
    final entries = entriesBox.values
        .where((entry) => entry.habitId == habitId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return entries;
  }

  @override
  Future<void> cacheEntry(
    HabitEntryHiveModel entry, {
    bool isPending = false,
  }) async {
    final entryToSave = entry.copyWith(isPendingSync: isPending);
    await entriesBox.put(entry.id, entryToSave);
  }

  @override
  Future<void> cacheEntries(List<HabitEntryHiveModel> entries) async {
    final map = {
      for (final entry in entries) entry.id: entry,
    };
    await entriesBox.putAll(map);
  }

  @override
  Future<HabitEntryHiveModel?> getCachedEntryForDate(
    String habitId,
    String date,
  ) async {
    final entries = entriesBox.values
        .where((entry) => entry.habitId == habitId && entry.date == date);

    return entries.isEmpty ? null : entries.first;
  }

  @override
  Future<List<HabitModel>> getPendingSyncHabits() async {
    final pendingHabits =
        habitsBox.values.where((h) => h.isPendingSync).toList();

    return pendingHabits
        .map((h) => HabitModel.fromEntity(h.toEntity()))
        .toList();
  }

  @override
  Future<List<HabitEntryHiveModel>> getPendingSyncEntries() async {
    final pendingEntries =
        entriesBox.values.where((e) => e.isPendingSync).toList();

    return pendingEntries.toList();
  }

  @override
  Future<void> markHabitAsSynced(String habitId) async {
    final habit = habitsBox.get(habitId);
    if (habit != null) {
      final updated = habit.copyWith(
        isPendingSync: false,
        lastSyncedAt: DateTime.now(),
      );
      await habitsBox.put(habitId, updated);
    }
  }

  @override
  Future<void> markEntryAsSynced(String entryId) async {
    final entry = entriesBox.get(entryId);
    if (entry != null) {
      final updated = entry.copyWith(
        isPendingSync: false,
        lastSyncedAt: DateTime.now(),
      );
      await entriesBox.put(entryId, updated);
    }
  }

  @override
  Future<void> clearAllCache() async {
    await habitsBox.clear();
    await entriesBox.clear();
  }
}
