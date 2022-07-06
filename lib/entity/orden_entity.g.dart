// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orden_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrdenEntityAdapter extends TypeAdapter<OrdenEntity> {
  @override
  final int typeId = 8;

  @override
  OrdenEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrdenEntity()
      ..id = fields[0] as int
      ..createdAt = fields[1] as DateTime
      ..est = fields[2] as String
      ..stt = fields[3] as String
      ..auto = fields[4] as int
      ..piezas = (fields[5] as List).cast<int>()
      ..obs = (fields[6] as Map).cast<int, String>()
      ..fotos = (fields[7] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as int, (v as List).cast<String>()));
  }

  @override
  void write(BinaryWriter writer, OrdenEntity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.est)
      ..writeByte(3)
      ..write(obj.stt)
      ..writeByte(4)
      ..write(obj.auto)
      ..writeByte(5)
      ..write(obj.piezas)
      ..writeByte(6)
      ..write(obj.obs)
      ..writeByte(7)
      ..write(obj.fotos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrdenEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
