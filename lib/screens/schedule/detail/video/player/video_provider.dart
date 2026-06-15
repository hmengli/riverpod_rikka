import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'video_entity.dart';

part 'video_provider.g.dart';

// ==================== 提供器定义 ====================
/// 全局播放器状态提供器（需在应用根使用 ProviderScope）
final videoProvider = StateNotifierProvider<VideoNotifier, VideoEntity>((ref) {
  final notifier = VideoNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

class VideoNotifier extends StateNotifier<VideoEntity> {
  final _controller = VideoController(Player());
  Player get player => _controller.player;
  VideoController get controller => _controller;

  VideoNotifier() : super(VideoEntity()) {
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

  /// 资源释放
  @override
  void dispose() {
    player.dispose();
    super.dispose();
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
}

/// 单独暴露位置（避免无关重建）
@riverpod
Duration position(Ref ref) {
  return ref.watch(videoProvider).position;
}

/// 单独暴露总时长
@riverpod
Duration duration(Ref ref) {
  return ref.watch(videoProvider).duration;
}

/// 单独暴露播放状态
@riverpod
bool isPlaying(Ref ref) {
  return ref.watch(videoProvider).isPlaying;
}

/// 单独暴露音量
@riverpod
final volumeProvider = Provider<double>((ref) {
  return ref.watch(videoProvider).volume;
});

/// 单独暴露全屏状态
@riverpod
bool isFull(Ref ref) {
  return ref.watch(videoProvider).isFull;
}

/// 暴露 VideoController 实例（供 media_kit_video 的 Video 组件使用）
@riverpod
VideoController videoController(Ref ref) {
  return ref.read(videoProvider.notifier).controller;
}

/// 暴露 Player 实例（可选）
@riverpod
Player player(Ref ref) {
  return ref.read(videoProvider.notifier).player;
}

// 定义一个普通的 Provider 来暴露 Controller
final videoAnimationControllerProvider = Provider<AnimaController>((ref) {
  // 这里无需实现，实际值会在 VideoPlayer 的 build 方法中被覆盖
  throw UnimplementedError('此 Provider 必须在 VideoPlayer 中被覆盖');
});

/// 动画控制器管理类
/// 用于统一管理控制栏的淡入淡出动画
class AnimaController {
  /// 动画控制器
  late final AnimationController _controller;

  /// 透明度动画
  late final Animation<double> _opacityAnimation;

  /// 当前是否可见
  bool _isVisible = true;

  bool _autoHide = true;
  VoidCallback? _onAutoHide;

  /// 获取当前透明度动画
  Animation<double> get opacityAnimation => _opacityAnimation;

  /// 获取当前是否可见
  bool get isVisible => _isVisible;

  /// 构造函数
  AnimaController({
    required TickerProvider vsync,
    double animationBegin = 0,
    autoHide = false,
    VoidCallback? onAutoHide,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    // 在构造函数体内初始化，而不是初始化列表
    _controller = AnimationController(vsync: vsync, duration: duration);
    _opacityAnimation = Tween<double>(
      begin: -animationBegin,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _autoHide = autoHide;
    _onAutoHide = onAutoHide;

    // 初始状态为可见
    _controller.value = 1.0;
  }

  /// 显示控制栏
  void showControls() {
    if (!_isVisible) {
      _controller.forward();
      _isVisible = true;
      if (_autoHide) {
        autoHide(onAutoHide: _onAutoHide);
      }
    }
  }

  void enterControls() {
    _autoHideTimer?.cancel();
    if (!_isVisible) {
      _controller.forward();
      _isVisible = true;
    }
  }

  void exitControls() {
    if (_autoHide) {
      autoHide(onAutoHide: _onAutoHide);
    }
  }

  /// 隐藏控制栏
  void hideControls() {
    if (_isVisible) {
      _controller.reverse();
      _isVisible = false;
    }
  }

  /// 切换控制栏显示/隐藏
  void toggleControls() {
    if (_isVisible) {
      hideControls();
    } else {
      showControls();
    }
  }

  /// 重置动画（用于视频切换或重新初始化）
  void reset() {
    _controller.stop();
    _controller.value = 1.0;
    _isVisible = true;
  }

  /// 设置自动隐藏定时器
  /// [duration] 自动隐藏前等待时间，默认3秒
  /// [onAutoHide] 自动隐藏时的回调
  void autoHide({
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAutoHide,
  }) {
    // 取消之前的定时器
    _autoHideTimer?.cancel();

    // 如果当前是可见状态，则启动新的定时器
    if (_isVisible) {
      _autoHideTimer = Timer(duration, () {
        if (_isVisible) {
          hideControls();
          onAutoHide?.call();
        }
      });
    }
  }

  Timer? _autoHideTimer;

  /// 取消自动隐藏定时器
  void cancelAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
  }

  /// 显示控制栏并重置自动隐藏
  void showWithAutoHide({
    Duration autoHideDuration = const Duration(seconds: 3),
    VoidCallback? onAutoHide,
  }) {
    showControls();
    autoHide(duration: autoHideDuration, onAutoHide: onAutoHide);
  }

  /// 释放资源
  void dispose() {
    cancelAutoHide();
    _controller.dispose();
  }
}
