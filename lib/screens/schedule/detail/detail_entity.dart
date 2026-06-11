import 'package:freezed_annotation/freezed_annotation.dart';

import '../schedule_entity.dart';
import 'parser/parser_entity.dart';

part 'detail_entity.freezed.dart';

@freezed
abstract class DetailEntity with _$DetailEntity {
  const factory DetailEntity({
    required String title,
    required String href,
    required ScheduleEntity comics,
    required ParserEntity parser,
    String? imageSrc,
  }) = _DetailEntity;
}
