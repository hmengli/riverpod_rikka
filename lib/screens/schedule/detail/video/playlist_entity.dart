import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rikka/screens/schedule/detail/detail_entity.dart';

part 'playlist_entity.freezed.dart';

@freezed
abstract class PlaylistEntity with _$PlaylistEntity {
  factory PlaylistEntity({
    @Default(0) int curIndex,
    @Default(0) int selIndex,
    required DetailEntity detail,
    @Default([]) List<List<Map<String, String>>> step3Map,
  }) = _PlaylistEntity;
}
