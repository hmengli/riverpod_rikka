import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:rikka/logger/logger.dart';

part 'parser_entity.freezed.dart';
part 'parser_entity.g.dart';

class ParserRepository {
  final Box<ParserEntity> box;

  ParserRepository(this.box);

  List<ParserEntity> getAll() => box.values.toList();

  Future<void> upsert(ParserEntity todo) => box.put(todo.basisUrl, todo);

  Future<void> delete(String basisUrl) => box.delete(basisUrl);

  // Stream<void> watch() => box.watch().map((event) => null);
}

enum VideoType { movie, comics }

enum FromType { cloud, local }

enum SyncStatus {
  synced, // 本地与云端一致（已同步）
  localOnly, // 仅本地存在，云端无（待上传）
  cloudOnly, // 仅云端存在，本地无（待下载）
  conflict, // 双方都有但内容不一致（需解决冲突）
}

@freezed
abstract class ParserSyncItem with _$ParserSyncItem {
  const factory ParserSyncItem({
    required String name, // 云端唯一标识
    required String basisUrl,
    required ParserEntity entity,
    required SyncStatus status,
    DateTime? localUpdatedAt,
  }) = _ParserSyncItem;

  factory ParserSyncItem.fromJson(Map<String, dynamic> json) =>
      _$ParserSyncItemFromJson(json);
}

class CreatedDateConverter implements JsonConverter<DateTime?, String> {
  const CreatedDateConverter();
  @override
  DateTime fromJson(String json) => DateTime.parse(json);
  @override
  String toJson(DateTime? object) {
    Log.i('toJson: $object');
    if (object == null) return DateTime.now().toIso8601String();
    return object.toIso8601String();
  }
}

class UpdatedDateConverter implements JsonConverter<DateTime?, String> {
  const UpdatedDateConverter();
  @override
  DateTime fromJson(String json) => DateTime.parse(json);
  @override
  String toJson(DateTime? object) => DateTime.now().toIso8601String();
}

@freezed
abstract class ParserEntity with _$ParserEntity {
  const factory ParserEntity({
    @Default('') String name,
    @Default('') String basisUrl,
    @Default('') String searchUrl,
    @Default('') String searchHref,
    @Default('') String searchTitle,
    @Default('') String chapterRoad,
    @Default('') String chapterList,
    @Default('iframe') String selectorIframe,
    @Default('') String selectorM3u8,
    @Default('') String selectorVideo,
    @Default('') String referer,
    @Default(false) bool verify,
    @Default('') String verifyPng,
    @Default('') String verifyInput,
    @Default('') String verifySubmit,

    @JsonKey(includeToJson: false) @Default(false) bool delete,
    @JsonKey(name: 'created_at') @CreatedDateConverter() DateTime? createdAt,
    @JsonKey(name: 'updated_at') @UpdatedDateConverter() DateTime? updatedAt,
    @JsonKey(includeToJson: false) VideoType? videoType,
    @Default(FromType.local) FromType fromType,
    @JsonKey(includeToJson: false) SyncStatus? syncStatus,
  }) = _ParserEntity;

  factory ParserEntity.fromJson(Map<String, dynamic> json) =>
      _$ParserEntityFromJson(json);
}
