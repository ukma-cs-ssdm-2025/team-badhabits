// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_entry_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitEntryHiveModelAdapter extends TypeAdapter<HabitEntryHiveModel> {
  @override
  final int typeId = 1;

  @override
  HabitEntryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitEntryHiveModel(
      id: fields[0] as String,
      habitId: fields[1] as String,
      userId: fields[2] as String,
      date: fields[3] as String,
      values: (fields[4] as Map).cast<String, dynamic>(),
      lastSyncedAt: fields[5] as DateTime?,
      isPendingSync: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HabitEntryHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.values)
      ..writeByte(5)
      ..write(obj.lastSyncedAt)
      ..writeByte(6)
      ..write(obj.isPendingSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitEntryHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
