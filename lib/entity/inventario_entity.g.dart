// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventario_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventarioEntityAdapter extends TypeAdapter<InventarioEntity> {
  @override
  final int typeId = 5;

  @override
  InventarioEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventarioEntity()
      ..marca = fields[0] as String
      ..modelo = fields[1] as String
      ..anio = fields[2] as int
      ..isNac = fields[3] as bool
      ..piezaName = fields[4] as String
      ..lado = fields[5] as String
      ..posicion = fields[6] as String
      ..costo = fields[7] as String
      ..observs = fields[8] as String
      ..fotos = (fields[9] as List).cast<String>()
      ..size = fields[10] as double;
  }

  @override
  void write(BinaryWriter writer, InventarioEntity obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.marca)
      ..writeByte(1)
      ..write(obj.modelo)
      ..writeByte(2)
      ..write(obj.anio)
      ..writeByte(3)
      ..write(obj.isNac)
      ..writeByte(4)
      ..write(obj.piezaName)
      ..writeByte(5)
      ..write(obj.lado)
      ..writeByte(6)
      ..write(obj.posicion)
      ..writeByte(7)
      ..write(obj.costo)
      ..writeByte(8)
      ..write(obj.observs)
      ..writeByte(9)
      ..write(obj.fotos)
      ..writeByte(10)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventarioEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
