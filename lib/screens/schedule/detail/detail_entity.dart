import 'package:freezed_annotation/freezed_annotation.dart';

import '../schedule_entity.dart';
import 'parser/parser_entity.dart';

part 'detail_entity.freezed.dart';

// @freezed
// abstract class VerifyEntity with _$VerifyEntity {
//   const factory VerifyEntity({
//     required String url,
//     required ParserEntity parser,
//   }) = _VerifyEntity;
// }

@freezed
abstract class DetailEntity with _$DetailEntity {
  const factory DetailEntity({
    required String title,
    required String href,
    required ParserEntity parser,
    ScheduleEntity? comics,
    String? imageSrc,
  }) = _DetailEntity;
}
