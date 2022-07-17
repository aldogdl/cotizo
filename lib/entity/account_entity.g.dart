// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountEntityAdapter extends TypeAdapter<AccountEntity> {
  @override
  final int typeId = 10;

  @override
  AccountEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountEntity()
      ..id = fields[0] as int
      ..displayName = fields[1] as String
      ..email = fields[2] as String
      ..photoUrl = fields[3] as String?
      ..serverToken = fields[4] as String
      ..msgToken = fields[5] as String
      ..curc = fields[6] as String
      ..roles = (fields[7] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, AccountEntity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.serverToken)
      ..writeByte(5)
      ..write(obj.msgToken)
      ..writeByte(6)
      ..write(obj.curc)
      ..writeByte(7)
      ..write(obj.roles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
