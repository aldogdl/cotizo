// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'no_tengo_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoTengoEntityAdapter extends TypeAdapter<NoTengoEntity> {
  @override
  final int typeId = 11;

  @override
  NoTengoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoTengoEntity()
      ..idCot = fields[0] as int
      ..idPza = fields[1] as int
      ..idOrd = fields[2] as int;
  }

  @override
  void write(BinaryWriter writer, NoTengoEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.idCot)
      ..writeByte(1)
      ..write(obj.idPza)
      ..writeByte(2)
      ..write(obj.idOrd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoTengoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
