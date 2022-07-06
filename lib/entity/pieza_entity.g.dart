// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pieza_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PiezaEntityAdapter extends TypeAdapter<PiezaEntity> {
  @override
  final int typeId = 9;

  @override
  PiezaEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PiezaEntity()
      ..id = fields[0] as int
      ..piezaName = fields[1] as String
      ..origen = fields[2] as String
      ..lado = fields[3] as String
      ..posicion = fields[4] as String
      ..cant = fields[5] as int;
  }

  @override
  void write(BinaryWriter writer, PiezaEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.piezaName)
      ..writeByte(2)
      ..write(obj.origen)
      ..writeByte(3)
      ..write(obj.lado)
      ..writeByte(4)
      ..write(obj.posicion)
      ..writeByte(5)
      ..write(obj.cant);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PiezaEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
