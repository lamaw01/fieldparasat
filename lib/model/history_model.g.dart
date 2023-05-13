// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryModelAdapter extends TypeAdapter<HistoryModel> {
  @override
  final int typeId = 2;

  @override
  HistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryModel(
      image: fields[0] as String,
      employeeId: (fields[1] as List).cast<String>(),
      latlng: fields[2] as String,
      address: fields[3] as String,
      imageScreenshot: fields[4] as Uint8List,
      department: fields[5] as String,
      selfieTimestamp: fields[6] as String,
      logType: fields[7] as String,
      uploaded: fields[8] as bool,
      team: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.image)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.latlng)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.imageScreenshot)
      ..writeByte(5)
      ..write(obj.department)
      ..writeByte(6)
      ..write(obj.selfieTimestamp)
      ..writeByte(7)
      ..write(obj.logType)
      ..writeByte(8)
      ..write(obj.uploaded)
      ..writeByte(9)
      ..write(obj.team);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
