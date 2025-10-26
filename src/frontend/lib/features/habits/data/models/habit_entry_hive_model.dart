import 'package:hive/hive.dart';
import '../../domain/entities/habit.dart';

part 'habit_entry_hive_model.g.dart';

/// Hive model for HabitEntry with offline sync support
@HiveType(typeId: 1)
class HabitEntryHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String date;

  @HiveField(4)
  final Map<String, dynamic> values;

  @HiveField(5)
  final DateTime? lastSyncedAt;

  @HiveField(6)
  final bool isPendingSync;

  HabitEntryHiveModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.values,
    this.lastSyncedAt,
    this.isPendingSync = false,
  });

  /// Creates HabitEntryHiveModel from HabitEntry entity
  /// Requires habitId and userId which are not part of HabitEntry entity
  factory HabitEntryHiveModel.fromEntity({
    required String id,
    required String habitId,
    required String userId,
    required HabitEntry entry,
  }) =>
      HabitEntryHiveModel(
        id: id,
        habitId: habitId,
        userId: userId,
        date: entry.date,
        values: Map<String, dynamic>.from(entry.values),
        lastSyncedAt: DateTime.now(),
      );

  /// Converts to HabitEntry entity
  HabitEntry toEntity() => HabitEntry(
        date: date,
        values: Map<String, dynamic>.from(values),
      );

  /// Creates a copy with updated sync fields
  HabitEntryHiveModel copyWith({
    bool? isPendingSync,
    DateTime? lastSyncedAt,
  }) =>
      HabitEntryHiveModel(
        id: id,
        habitId: habitId,
        userId: userId,
        date: date,
        values: values,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        isPendingSync: isPendingSync ?? this.isPendingSync,
      );
}
