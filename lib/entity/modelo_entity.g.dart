// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modelo_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModeloEntityAdapter extends TypeAdapter<ModeloEntity> {
  @override
  final int typeId = 7;

  @override
  ModeloEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModeloEntity()
      ..id = fields[0] as int
      ..marca = fields[1] as int
      ..nombre = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, ModeloEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.marca)
      ..writeByte(2)
      ..write(obj.nombre);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModeloEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
