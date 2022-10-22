// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marca_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarcaEntityAdapter extends TypeAdapter<MarcaEntity> {
  @override
  final int typeId = 5;

  @override
  MarcaEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarcaEntity()
      ..id = fields[0] as int
      ..nombre = fields[1] as String
      ..logo = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, MarcaEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.logo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarcaEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
