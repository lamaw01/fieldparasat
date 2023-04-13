// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdleModelAdapter extends TypeAdapter<IdleModel> {
  @override
  final int typeId = 1;

  @override
  IdleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdleModel(
      image: fields[0] as String,
      imageName: fields[1] as String,
      name: fields[2] as String,
      employeeId: fields[3] as String,
      latlng: fields[4] as String,
      address: fields[5] as String,
      imageScreenshot: fields[6] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, IdleModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.image)
      ..writeByte(1)
      ..write(obj.imageName)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.employeeId)
      ..writeByte(4)
      ..write(obj.latlng)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.imageScreenshot);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
