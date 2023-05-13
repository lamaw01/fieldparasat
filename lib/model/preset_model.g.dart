// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresetModelAdapter extends TypeAdapter<PresetModel> {
  @override
  final int typeId = 3;

  @override
  PresetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PresetModel(
      presetName: fields[0] as String,
      employeeId: (fields[1] as List).cast<String>(),
      department: fields[2] as String,
      team: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PresetModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.presetName)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.department)
      ..writeByte(3)
      ..write(obj.team);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
