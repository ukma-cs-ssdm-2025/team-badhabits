// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_field_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitFieldHiveModelAdapter extends TypeAdapter<HabitFieldHiveModel> {
  @override
  final int typeId = 2;

  @override
  HabitFieldHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitFieldHiveModel(
      type: fields[0] as String,
      label: fields[1] as String,
      unit: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitFieldHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitFieldHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
