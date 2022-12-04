// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_app.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigAppAdapter extends TypeAdapter<ConfigApp> {
  @override
  final int typeId = 1;

  @override
  ConfigApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfigApp()
      ..isInit = fields[0] as bool
      ..modoCot = fields[1] as int
      ..inLast = fields[2] as String
      ..invalidToken = fields[3] as bool
      ..desaPushInt = fields[4] as bool
      ..lastCheckNt = fields[5] as String
      ..showAvisoAparta = fields[6] as bool;
  }

  @override
  void write(BinaryWriter writer, ConfigApp obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.isInit)
      ..writeByte(1)
      ..write(obj.modoCot)
      ..writeByte(2)
      ..write(obj.inLast)
      ..writeByte(3)
      ..write(obj.invalidToken)
      ..writeByte(4)
      ..write(obj.desaPushInt)
      ..writeByte(5)
      ..write(obj.lastCheckNt)
      ..writeByte(6)
      ..write(obj.showAvisoAparta);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigAppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
