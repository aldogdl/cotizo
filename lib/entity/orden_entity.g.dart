// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orden_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrdenEntityAdapter extends TypeAdapter<OrdenEntity> {
  @override
  final int typeId = 12;

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
      ..avo = fields[5] as int
      ..piezas = (fields[6] as List).cast<PiezaEntity>()
      ..obs = (fields[7] as Map).cast<int, String>()
      ..fotos = (fields[8] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as int, (v as List).cast<String>()))
      ..type = fields[9] as String;
  }

  @override
  void write(BinaryWriter writer, OrdenEntity obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.avo)
      ..writeByte(6)
      ..write(obj.piezas)
      ..writeByte(7)
      ..write(obj.obs)
      ..writeByte(8)
      ..write(obj.fotos)
      ..writeByte(9)
      ..write(obj.type);
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
