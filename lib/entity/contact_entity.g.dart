// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactEntityAdapter extends TypeAdapter<ContactEntity> {
  @override
  final int typeId = 3;

  @override
  ContactEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactEntity()
      ..id = fields[0] as int
      ..curc = fields[1] as String
      ..nombre = fields[2] as String
      ..celular = fields[3] as String
      ..empresa = fields[4] as String
      ..enombre = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, ContactEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.curc)
      ..writeByte(2)
      ..write(obj.nombre)
      ..writeByte(3)
      ..write(obj.celular)
      ..writeByte(4)
      ..write(obj.empresa)
      ..writeByte(5)
      ..write(obj.enombre);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
