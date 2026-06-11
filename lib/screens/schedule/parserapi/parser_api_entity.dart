import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'parser_api_entity.freezed.dart';
part 'parser_api_entity.g.dart';

class ParserApiRepository {
  final Box<ParserApiEntity> box;

  ParserApiRepository(this.box);

  List<ParserApiEntity> getAll() => box.values.toList();

  Future<void> add(ParserApiEntity todo) => box.put(todo.basisUrl, todo);

  Future<void> update(ParserApiEntity todo) => box.put(todo.basisUrl, todo);

  Future<void> delete(String basisUrl) => box.delete(basisUrl);

  // Stream<void> watch() => box.watch().map((event) => null);
}

enum Methods { get, post }

enum ApiType { comicsApi, movieApi }

enum ValueSourceType { none, direct, template }

enum TransFormType { trim, unescape, replace, removeWhitespace }

@freezed
abstract class ParserApiEntity with _$ParserApiEntity {
  const factory ParserApiEntity({
    @Default('https://www.mwcy.net/index.php/ds_api/weekday') String basisUrl,
    @Default(Methods.post) Methods method,
    @Default('list') String dataRootPath,
    @Default([]) @JsonKey(name: 'headers') List<HeadersEntity> headers,
    @Default([]) List<FieldMapping> fieldMappings,
  }) = _ParserApiEntity;

  factory ParserApiEntity.fromJson(Map<String, dynamic> json) =>
      _$ParserApiEntityFromJson(json);
}

@freezed
abstract class HeadersEntity with _$HeadersEntity {
  const factory HeadersEntity({required String mKey, dynamic mValue}) =
      _HeadersEntity;
  factory HeadersEntity.fromJson(Map<String, dynamic> json) =>
      _$HeadersEntityFromJson(json);
}

@freezed
abstract class FieldMapping with _$FieldMapping {
  const factory FieldMapping({
    String? targetField,
    String? sourcePath,
    @Default([]) List<DataTransForm> transforms,
    @Default(ValueSourceType.none) ValueSourceType type,
  }) = _NoneFieldMapping;

  const factory FieldMapping.direct({
    String? targetField,
    String? sourcePath,
    @Default([]) List<DataTransForm> transforms,
    @Default(ValueSourceType.direct) ValueSourceType type,
  }) = _DirectFieldMapping;

  const factory FieldMapping.template({
    String? targetField,
    String? sourcePath,
    @Default([]) List<DataTransForm> transforms,
    @Default(ValueSourceType.template) ValueSourceType type,
  }) = _TemplateFieldMapping;

  factory FieldMapping.fromJson(Map<String, dynamic> json) =>
      _$FieldMappingFromJson(json);
}

@freezed
abstract class DataTransForm with _$DataTransForm {
  const factory DataTransForm({
    String? pattern,
    String? replacement,
    required TransFormType type,
  }) = _DataTransform;

  const factory DataTransForm.trim({
    String? pattern,
    String? replacement,
    @Default(TransFormType.trim) TransFormType type,
  }) = _TrimDataTransForm;

  const factory DataTransForm.unescape({
    String? pattern,
    String? replacement,
    @Default(TransFormType.unescape) TransFormType type,
  }) = _UnescapeDataTransForm;

  const factory DataTransForm.removeWhitespace({
    String? pattern,
    String? replacement,
    @Default(TransFormType.removeWhitespace) TransFormType type,
  }) = _RmoveDataTransForm;

  const factory DataTransForm.replace({
    required String pattern,
    required String replacement,
    @Default(TransFormType.replace) TransFormType type,
  }) = _ReplaceDataTransForm;

  factory DataTransForm.fromJson(Map<String, dynamic> json) =>
      _$DataTransFormFromJson(json);
}
