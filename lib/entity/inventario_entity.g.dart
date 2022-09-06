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
      ..id = fields[0] as int
      ..auto = fields[1] as int
      ..pieza = fields[2] as int
      ..costo = fields[3] as double
      ..deta = fields[4] as String
      ..fotos = (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList()
      ..shared = fields[6] as int
      ..created = fields[7] as String
      ..idOrden = fields[8] as int
      ..idPieza = fields[9] as int;
  }

  @override
  void write(BinaryWriter writer, InventarioEntity obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.auto)
      ..writeByte(2)
      ..write(obj.pieza)
      ..writeByte(3)
      ..write(obj.costo)
      ..writeByte(4)
      ..write(obj.deta)
      ..writeByte(5)
      ..write(obj.fotos)
      ..writeByte(6)
      ..write(obj.shared)
      ..writeByte(7)
      ..write(obj.created)
      ..writeByte(8)
      ..write(obj.idOrden)
      ..writeByte(9)
      ..write(obj.idPieza);
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
