import 'package:hive/hive.dart';
import '../../domain/entities/habit.dart';
import 'habit_field_hive_model.dart';

part 'habit_hive_model.g.dart';

/// Hive model for Habit with offline sync support
@HiveType(typeId: 0)
class HabitHiveModel extends HiveObject {

  HabitHiveModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isPendingSync = false,
  });

  /// Creates HabitHiveModel from Habit entity
  factory HabitHiveModel.fromEntity(Habit habit) => HabitHiveModel(
        id: habit.id,
        userId: habit.userId,
        name: habit.name,
        fields: habit.fields.map(HabitFieldHiveModel.fromEntity).toList(),
        createdAt: habit.createdAt,
        updatedAt: habit.updatedAt,
        lastSyncedAt: DateTime.now(),
      );
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final List<HabitFieldHiveModel> fields;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final DateTime? lastSyncedAt;

  @HiveField(7)
  final bool isPendingSync;

  /// Converts to Habit entity
  Habit toEntity() => Habit(
        id: id,
        userId: userId,
        name: name,
        fields: fields.map((f) => f.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Creates a copy with updated sync fields
  HabitHiveModel copyWith({
    bool? isPendingSync,
    DateTime? lastSyncedAt,
  }) =>
      HabitHiveModel(
        id: id,
        userId: userId,
        name: name,
        fields: fields,
        createdAt: createdAt,
        updatedAt: updatedAt,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        isPendingSync: isPendingSync ?? this.isPendingSync,
      );
}
