import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_entity.freezed.dart';
part 'schedule_entity.g.dart';

@freezed
abstract class ScheduleEntity with _$ScheduleEntity {
  @JsonSerializable(createFieldMap: true, fieldRename: FieldRename.snake)
  const factory ScheduleEntity({
    required String url,
    required int vodId,
    required String vodName,
    required String vodPic,
    String? vodPicThumb,
    String? vodClass,
    String? vodActor,
    String? vodTag,
    String? vodScore,
    String? vodDoubanScore,
    String? vodRemarks,
    String? vodSerial,
    String? vodBlurb,
  }) = _ScheduleEntity;

  factory ScheduleEntity.fromJson(Map<String, Object?> json) =>
      _$ScheduleEntityFromJson(json);

  static Map<String, String> get fieldMap => _$ScheduleEntityFieldMap;

  static List<String> get fieldList => _$ScheduleEntityFieldMap.values.toList();
}
