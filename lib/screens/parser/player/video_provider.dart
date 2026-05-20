import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// ==================== 提供器定义 ====================
/// 全局播放器状态提供器（需在应用根使用 ProviderScope）
final videoProvider = StateNotifierProvider<VideoNotifier, VideoState>((ref) {
  final notifier = VideoNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// 单独暴露位置（避免无关重建）
final positionProvider = Provider<Duration>((ref) {
  return ref.watch(videoProvider).position;
});

/// 单独暴露总时长
final durationProvider = Provider<Duration>((ref) {
  return ref.watch(videoProvider).duration;
});

/// 单独暴露播放状态
final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(videoProvider).isPlaying;
});

/// 单独暴露音量
final volumeProvider = Provider<double>((ref) {
  return ref.watch(videoProvider).volume;
});

/// 单独暴露全屏状态
final isFullProvider = Provider<bool>((ref) {
  return ref.watch(videoProvider).isFull;
});

/// 暴露 VideoController 实例（供 media_kit_video 的 Video 组件使用）
final videoControllerProvider = Provider<VideoController>((ref) {
  return ref.watch(videoProvider.notifier).controller;
});

/// 暴露 Player 实例（可选）
final playerProvider = Provider<Player>((ref) {
  return ref.watch(videoProvider.notifier).player;
});

/// 辅助类，用于封装 ProgressBar 需要的状态
class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    required this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration total;
}

// ==================== 播放器状态类 ====================
class VideoState {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final double volume;
  final bool isFull; // 全屏状态（UI 控制，不依赖播放器）

  const VideoState({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.volume = 0.0,
    this.isFull = false,
  });

  VideoState copyWith({
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    double? volume,
    bool? isFull,
  }) {
    return VideoState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      isFull: isFull ?? this.isFull,
    );
  }
}

class VideoNotifier extends StateNotifier<VideoState> {
  final _controller = VideoController(Player());
  Player get player => _controller.player;
  VideoController get controller => _controller;

  VideoNotifier() : super(VideoState()) {
    _init();
  }

  // 初始状态：未登录，加载完成
  void _init() {
    player.stream.position.listen((v) {
      state = state.copyWith(position: v);
    });
    player.stream.duration.listen((v) {
      state = state.copyWith(duration: v);
    });
    player.stream.playing.listen((v) {
      state = state.copyWith(isPlaying: v);
    });
    player.stream.volume.listen((v) {
      state = state.copyWith(volume: v);
    });
  }

  /// 播放或暂停
  void playOrPause() {
    player.playOrPause();
  }

  /// 静音切换
  double _lastVolume = 0.0; // 记忆静音前的音量
  void setVolume() {
    if (player.state.volume != 0) {
      _lastVolume = player.state.volume;
      player.setVolume(0);
    } else {
      player.setVolume(_lastVolume == 0 ? 1.0 : _lastVolume);
    }
  }

  /// 切换全屏（只改变 UI 状态，不涉及播放器）
  void setFulling() {
    state = state.copyWith(isFull: !state.isFull);
  }

  /// 暂停（外部调用）
  void pause() {
    player.pause();
  }

  /// 打开并播放视频
  Future<void> play(String? realUrl) async {
    if (realUrl != null) {
      await player.open(Media(realUrl));
    }
  }

  // bool isSelected(int index) {
  //   return _selectedIndex == index;
  // }
  /// 资源释放
  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
