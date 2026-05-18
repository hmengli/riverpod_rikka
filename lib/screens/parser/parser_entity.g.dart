// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parser_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParserEntityAdapter extends TypeAdapter<ParserEntity> {
  @override
  final typeId = 0;

  @override
  ParserEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParserEntity(
      id: fields[0] == null ? 0 : (fields[0] as num).toInt(),
      name: fields[1] == null ? '' : fields[1] as String,
      basisUrl: fields[2] == null ? '' : fields[2] as String,
      searchUrl: fields[3] == null ? '' : fields[3] as String,
      searchHref: fields[4] == null ? '' : fields[4] as String,
      searchTitle: fields[5] == null ? '' : fields[5] as String,
      chapterRoad: fields[6] == null ? '' : fields[6] as String,
      chapterList: fields[7] == null ? '' : fields[7] as String,
      selectorIframe: fields[8] == null ? '' : fields[8] as String,
      selectorM3u8: fields[9] == null ? '' : fields[9] as String,
      selectorVideo: fields[10] == null ? '' : fields[10] as String,
      referer: fields[11] == null ? '' : fields[11] as String,
      verify: fields[12] == null ? false : fields[12] as bool,
      verifyPng: fields[13] == null ? '' : fields[13] as String,
      verifyInput: fields[14] == null ? '' : fields[14] as String,
      verifySubmit: fields[15] == null ? '' : fields[15] as String,
      createdAt: fields[20] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ParserEntity obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.basisUrl)
      ..writeByte(3)
      ..write(obj.searchUrl)
      ..writeByte(4)
      ..write(obj.searchHref)
      ..writeByte(5)
      ..write(obj.searchTitle)
      ..writeByte(6)
      ..write(obj.chapterRoad)
      ..writeByte(7)
      ..write(obj.chapterList)
      ..writeByte(8)
      ..write(obj.selectorIframe)
      ..writeByte(9)
      ..write(obj.selectorM3u8)
      ..writeByte(10)
      ..write(obj.selectorVideo)
      ..writeByte(11)
      ..write(obj.referer)
      ..writeByte(12)
      ..write(obj.verify)
      ..writeByte(13)
      ..write(obj.verifyPng)
      ..writeByte(14)
      ..write(obj.verifyInput)
      ..writeByte(15)
      ..write(obj.verifySubmit)
      ..writeByte(20)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParserEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
