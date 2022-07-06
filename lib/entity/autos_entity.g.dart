// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autos_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AutosEntityAdapter extends TypeAdapter<AutosEntity> {
  @override
  final int typeId = 2;

  @override
  AutosEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AutosEntity()
      ..id = fields[0] as int
      ..anio = fields[1] as int
      ..isNac = fields[2] as bool
      ..marca = fields[3] as int
      ..modelo = fields[4] as int
      ..cant = fields[5] as int;
  }

  @override
  void write(BinaryWriter writer, AutosEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.anio)
      ..writeByte(2)
      ..write(obj.isNac)
      ..writeByte(3)
      ..write(obj.marca)
      ..writeByte(4)
      ..write(obj.modelo)
      ..writeByte(5)
      ..write(obj.cant);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutosEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
