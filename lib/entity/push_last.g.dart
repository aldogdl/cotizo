// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_last.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PushLastAdapter extends TypeAdapter<PushLast> {
  @override
  final int typeId = 10;

  @override
  PushLast read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PushLast()..pushIn = (fields[0] as Map).cast<String, dynamic>();
  }

  @override
  void write(BinaryWriter writer, PushLast obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.pushIn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushLastAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
