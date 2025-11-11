// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanHistoryAdapter extends TypeAdapter<ScanHistory> {
  @override
  final int typeId = 0;

  @override
  ScanHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanHistory(
      id: fields[0] as String,
      content: fields[1] as String,
      type: fields[2] as String,
      timestamp: fields[3] as DateTime,
      isFavorite: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScanHistory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
