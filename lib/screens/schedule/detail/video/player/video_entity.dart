import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_entity.freezed.dart';

// ==================== 播放器状态类 ====================
@freezed
abstract class VideoEntity with _$VideoEntity {
  const factory VideoEntity({
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(false) bool isPlaying,
    @Default(false) bool isFull,
    @Default(0) double volume,
  }) = _VideoEntity;
}

/// 辅助类，用于封装 ProgressBar 需要的状态
// class DurationState {
//   const DurationState({
//     required this.progress,
//     required this.buffered,
//     required this.total,
//   });
//   final Duration progress;
//   final Duration buffered;
//   final Duration total;
// }
