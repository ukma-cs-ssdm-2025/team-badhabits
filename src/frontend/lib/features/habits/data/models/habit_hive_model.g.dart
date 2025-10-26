// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitHiveModelAdapter extends TypeAdapter<HabitHiveModel> {
  @override
  final int typeId = 0;

  @override
  HabitHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      fields: (fields[3] as List).cast<HabitFieldHiveModel>(),
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      lastSyncedAt: fields[6] as DateTime?,
      isPendingSync: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HabitHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.fields)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.lastSyncedAt)
      ..writeByte(7)
      ..write(obj.isPendingSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
