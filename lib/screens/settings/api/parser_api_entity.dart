import 'package:freezed_annotation/freezed_annotation.dart';

part 'parser_api_entity.freezed.dart';

/// 字段映射配置：目标字段名 -> 源字段的取值规则
///
enum ApiType { comicsApi, movieApi }

enum ValueSourceType { direct, template }

enum TransFormType { trim, unescape, replace, removeWhitespace }

@freezed
abstract class ParserApiEntity with _$ParserApiEntity {
  const factory ParserApiEntity({
    String? basisUrl,
    String? method,
    String? dataRootPath,
    @Default([]) List<HeadersEntity> headers,
    @Default([]) List<FieldMapping> fieldMappings,
  }) = _ParserApiEntity;

  // factory ParserApiEntity.fromJson(Map<String, Object?> json) =>
  //     _$ParserApiEntityFromJson(json);

  factory ParserApiEntity.fromJson(Map<String, dynamic> json) {
    final fieldMappings = json['fieldMappings'];
    List<FieldMapping> fieldMappingList = [];
    if (fieldMappings is List) {
      fieldMappingList = fieldMappings.map((toElement) {
        return FieldMapping.fromJson(toElement);
      }).toList();
    }
    return ParserApiEntity(
      basisUrl: json['basisUrl'] ?? '',
      method: json['method'] ?? '',
      dataRootPath: json['dataRootPath'] ?? '',
      headers: json['headers'] ?? [],
      fieldMappings: fieldMappingList,
    );
  }
}

@freezed
abstract class HeadersEntity with _$HeadersEntity {
  const factory HeadersEntity({required String mKey, dynamic mValue}) =
      _HeadersEntity;
}

@freezed
abstract class FieldMapping with _$FieldMapping {
  const factory FieldMapping({
    String? targetField,
    String? sourcePath,
    ValueSourceType? type,
    @Default([]) List<DataTransForm> transforms,
  }) = _FieldMapping;

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

  factory FieldMapping.fromJson(Map<String, dynamic> json) {
    return FieldMapping.template(
      targetField: json['targetField'] ?? '',
      sourcePath: json['sourcePath'] ?? '',
    );
  }
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
}
