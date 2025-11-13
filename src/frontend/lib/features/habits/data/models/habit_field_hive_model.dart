import 'package:hive/hive.dart';
import '../../domain/entities/habit.dart';

part 'habit_field_hive_model.g.dart';

/// Hive model for HabitField with TypeAdapter for local storage
@HiveType(typeId: 2)
class HabitFieldHiveModel {

  HabitFieldHiveModel({
    required this.type,
    required this.label,
    this.unit,
  });

  /// Creates HabitFieldHiveModel from HabitField entity
  factory HabitFieldHiveModel.fromEntity(HabitField entity) =>
      HabitFieldHiveModel(
        type: entity.type,
        label: entity.label,
        unit: entity.unit,
      );
  @HiveField(0)
  final String type;

  @HiveField(1)
  final String label;

  @HiveField(2)
  final String? unit;

  /// Converts to HabitField entity
  HabitField toEntity() => HabitField(
        type: type,
        label: label,
        unit: unit,
      );
}
