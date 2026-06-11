import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'video_provider.dart';

class VideoPlayer extends ConsumerStatefulWidget {
  final Function(BuildContext context)? menu;
  const VideoPlayer({super.key, this.menu});

  @override
  ConsumerState<VideoPlayer> createState() => _VideoPlayerState();
}

// [✓] 关键点 1：State 混入 SingleTickerProviderStateMixin
// 这样 State 本身就变为了一个合格的 TickerProvider
class _VideoPlayerState extends ConsumerState<VideoPlayer>
    with SingleTickerProviderStateMixin {
  // [✓] 关键点 2：在 State 内部创建并持有 Controller
  late final AnimaController _controller;

  @override
  void initState() {
    super.initState();
    // vsync: this 表明用当前的 State 作为 TickerProvider
    _controller = AnimaController(
      vsync: this,
      animationBegin: 0,
      autoHide: true,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(videoControllerProvider);
    return ProviderScope(
      overrides: [
        videoAnimationControllerProvider.overrideWithValue(_controller),
      ],
      child: Align(
        alignment: Alignment.topCenter,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            alignment: AlignmentGeometry.center,
            children: [
              Video(controller: controller, controls: NoVideoControls),
              VideoAnimaController(menu: widget.menu),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoAnimaController extends ConsumerWidget {
  final Function(BuildContext context)? menu;
  const VideoAnimaController({super.key, this.menu});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final controlsManager = ref.watch(videoAnimationControllerProvider);
    return GestureDetector(
      onTap: controlsManager.toggleControls,
      child: Container(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: controlsManager.opacityAnimation,
          child: Column(
            children: [
              MouseRegionWidget(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        player.pause();
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(child: Text('AppBar')),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: menu != null
                          ? () => menu?.call(context)
                          : null,
                    ),
                  ],
                ),
              ),
              Expanded(child: Center(child: VideoPlayingButton(iconSize: 50))),
              MouseRegionWidget(
                child: Row(
                  children: [
                    //播放按钮
                    VideoPlayingButton(iconSize: 20),
                    Expanded(child: CustomProgressBar(player: player)),
                    VideoVolumeButton(),
                    // CustomVolume(player: player),
                    VideoDurationButton(),
                    VideoNativeFullButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayingButton extends ConsumerWidget {
  final double? iconSize;
  const VideoPlayingButton({super.key, this.iconSize});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听需要立即更新的状态
    final isPlaying = ref.watch(isPlayingProvider);
    return IconButton(
      iconSize: iconSize,
      onPressed: ref.read(videoProvider.notifier).playOrPause,
      icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
      color: Colors.white,
    );
  }
}

class VideoDurationButton extends ConsumerWidget {
  const VideoDurationButton({super.key});

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        '${formatDuration(position)}:${formatDuration(duration)}',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class VideoVolumeButton extends ConsumerWidget {
  const VideoVolumeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(volumeProvider);
    return IconButton(
      onPressed: ref.read(videoProvider.notifier).setVolume,
      icon: Icon(
        volume == 0 ? Icons.volume_off_outlined : Icons.volume_up_outlined,
      ),
      color: Colors.white,
    );
  }
}

class VideoNativeFullButton extends ConsumerWidget {
  const VideoNativeFullButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFull = ref.watch(isFullProvider);
    return IconButton(
      icon: Icon(isFull ? Icons.fullscreen_exit : Icons.fullscreen),
      onPressed: () async {
        ref.read(videoProvider.notifier).setFulling();
        if (isFull) {
          await defaultExitNativeFullscreen();
        } else {
          await defaultEnterNativeFullscreen();
        }
      },
    );
  }
}

class MouseRegionWidget extends ConsumerWidget {
  final Widget child;
  const MouseRegionWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final control = ref.read(videoAnimationControllerProvider);
    return Container(
      color: const Color.fromARGB(64, 211, 201, 201),
      height: 40,
      child: MouseRegion(
        cursor: SystemMouseCursors.click, // 改变光标样式
        onEnter: (_) {
          control.enterControls();
        },
        onExit: (_) {
          control.exitControls();
        },
        child: child,
      ),
    );
  }
}

class CustomProgressBar extends StatefulWidget {
  final Player player;

  const CustomProgressBar({super.key, required this.player});

  @override
  State<CustomProgressBar> createState() => _CustomProgressBarState();
}

class _CustomProgressBarState extends State<CustomProgressBar> {
  Duration _position = Duration.zero;
  Duration _buffered = Duration.zero;
  Duration _total = Duration.zero;

  late StreamSubscription<Duration> _positionSub;
  late StreamSubscription<Duration> _bufferedSub;
  late StreamSubscription<Duration> _durationSub;

  @override
  void initState() {
    super.initState();
    _total = widget.player.state.duration;
    _positionSub = widget.player.stream.position.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _bufferedSub = widget.player.stream.buffer.listen((b) {
      if (mounted) setState(() => _buffered = b);
    });
    _durationSub = widget.player.stream.duration.listen((d) {
      if (mounted) setState(() => _total = d);
    });
  }

  @override
  void dispose() {
    _positionSub.cancel();
    _bufferedSub.cancel();
    _durationSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onHorizontalDragUpdate: _handleDragUpdate,
      child: RepaintBoundary(
        child: SizedBox(
          height: 40.0, // 明确指定进度条的总高度（轨道+滑块的显示区域）
          // 隔离重绘区域，提升性能
          child: CustomPaint(
            // size: Size.infinite, // 宽度由父级约束决定，高度自定义
            painter: _ProgressPainter(
              progress: _position,
              buffered: _buffered,
              total: _total,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    // 如果总时长为0，不执行跳转，防止无效操作
    if (_total <= Duration.zero) return;
    final box = context.findRenderObject() as RenderBox;
    final localX = box.globalToLocal(details.globalPosition).dx;
    final percent = (localX / box.size.width).clamp(0.0, 1.0);
    widget.player.seek(
      Duration(milliseconds: (percent * _total.inMilliseconds).round()),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_total <= Duration.zero) return;
    final box = context.findRenderObject() as RenderBox;
    final localX = box.globalToLocal(details.globalPosition).dx;
    final percent = (localX / box.size.width).clamp(0.0, 1.0);
    widget.player.seek(
      Duration(milliseconds: (percent * _total.inMilliseconds).round()),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final Duration progress;
  final Duration buffered;
  final Duration total;

  _ProgressPainter({
    required this.progress,
    required this.buffered,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double trackHeight = 1.0; // 轨道高度
    final double thumbRadius = 8.0; // 滑块半径
    final double verticalCenter = height / 2;

    // 计算进度比例
    final totalMs = total.inMilliseconds.toDouble();
    if (totalMs <= 0) {
      // 绘制一个灰色背景条即可
      final backgroundPaint = Paint()..color = Colors.grey.shade300;
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, verticalCenter - trackHeight / 2, width, trackHeight),
        Radius.circular(trackHeight / 2),
      );
      canvas.drawRRect(trackRect, backgroundPaint);
      return;
    }

    final progressRatio = (totalMs <= 0)
        ? 0.0
        : progress.inMilliseconds / totalMs;
    final bufferedRatio = (totalMs <= 0)
        ? 0.0
        : buffered.inMilliseconds / totalMs;

    final progressX = width * progressRatio;
    final bufferedX = width * bufferedRatio;

    // 1. 绘制背景轨道（灰色圆角矩形）
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, verticalCenter - trackHeight / 2, width, trackHeight),
      Radius.circular(trackHeight / 2),
    );
    canvas.drawRRect(trackRect, backgroundPaint);

    // 2. 绘制缓冲进度（浅灰色）
    if (bufferedRatio > 0) {
      final bufferedPaint = Paint()
        ..color = Colors.grey.shade500
        ..style = PaintingStyle.fill;
      final bufferedRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          verticalCenter - trackHeight / 2,
          bufferedX,
          trackHeight,
        ),
        Radius.circular(trackHeight / 2),
      );
      canvas.drawRRect(bufferedRect, bufferedPaint);
    }

    // 3. 绘制已播放进度（主题色）
    if (progressRatio > 0) {
      final progressPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      final progressRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          verticalCenter - trackHeight / 2,
          progressX,
          trackHeight,
        ),
        Radius.circular(trackHeight / 2),
      );
      canvas.drawRRect(progressRect, progressPaint);
    }

    // 4. 绘制带阴影的圆形滑块
    // 4.1 首先，使用 Canvas.drawShadow 绘制阴影 (核心修正点)
    final thumbCenter = Offset(progressX, verticalCenter);
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: thumbCenter, radius: thumbRadius));
    canvas.drawShadow(
      shadowPath, // 阴影的路径 (Path)
      Colors.black, // 阴影颜色 (Color)
      4.0, // 模糊程度 (double)，值越大阴影越弥散
      true, // 是否遮挡 (bool)
    );

    // 4.2 最后，绘制白色圆形本体
    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    // 只有进度、缓冲或总时长变化时才重绘
    return oldDelegate.progress != progress ||
        oldDelegate.buffered != buffered ||
        oldDelegate.total != total;
  }
}

class CustomVolume extends StatefulWidget {
  final Player player;
  const CustomVolume({super.key, required this.player});

  @override
  State<CustomVolume> createState() => _CustomVolumeState();
}

class _CustomVolumeState extends State<CustomVolume> {
  double volume = 0;
  // Duration _total = Duration.zero;

  late StreamSubscription<double> _volumeSub;
  // late StreamSubscription<Duration> _durationSub;

  @override
  void initState() {
    super.initState();
    // _total = widget.player.state.duration;
    _volumeSub = widget.player.stream.volume.listen((v) {
      if (mounted) setState(() => volume = v);
    });
  }

  @override
  void dispose() {
    _volumeSub.cancel();
    // _bufferedSub.cancel();
    // _durationSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onHorizontalDragUpdate: _handleDragUpdate,
      child: RepaintBoundary(
        child: SizedBox(
          height: 40.0, // 明确指定进度条的总高度（轨道+滑块的显示区域）
          width: 100.0, // 明确指定进度条的总高度（轨道+滑块的显示区域）
          // 隔离重绘区域，提升性能
          child: CustomPaint(
            // size: Size.infinite, // 宽度由父级约束决定，高度自定义
            painter: _VolumePainter(volume: volume),
          ),
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    // 如果总时长为0，不执行跳转，防止无效操作
    final box = context.findRenderObject() as RenderBox;
    final localX = box.globalToLocal(details.globalPosition).dx;
    final percent = (localX / box.size.width).clamp(0.0, 1.0);
    widget.player.setVolume(percent);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final localX = box.globalToLocal(details.globalPosition).dx;
    final percent = (localX / box.size.width).clamp(0.0, 1.0);
    widget.player.setVolume(percent);
  }
}

class _VolumePainter extends CustomPainter {
  final double volume;

  _VolumePainter({required this.volume});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double trackHeight = 4.0; // 轨道高度
    final double thumbRadius = 8.0; // 滑块半径
    final double verticalCenter = height / 2;

    final progressX = width * volume;

    // 1. 绘制背景轨道（灰色圆角矩形）
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, verticalCenter - trackHeight / 2, width, trackHeight),
      Radius.circular(trackHeight / 2),
    );
    canvas.drawRRect(trackRect, backgroundPaint);

    // 2. 绘制已播放进度（主题色）
    if (progressX > 0) {
      final progressPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      final progressRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          verticalCenter - trackHeight / 2,
          progressX,
          trackHeight,
        ),
        Radius.circular(trackHeight / 2),
      );
      canvas.drawRRect(progressRect, progressPaint);
    }

    // 3. 绘制带阴影的圆形滑块
    // 3.1 首先，使用 Canvas.drawShadow 绘制阴影 (核心修正点)
    final thumbCenter = Offset(progressX, verticalCenter);
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: thumbCenter, radius: thumbRadius));
    canvas.drawShadow(
      shadowPath, // 阴影的路径 (Path)
      Colors.black, // 阴影颜色 (Color)
      4.0, // 模糊程度 (double)，值越大阴影越弥散
      true, // 是否遮挡 (bool)
    );

    // 3.2 最后，绘制白色圆形本体
    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _VolumePainter oldDelegate) {
    // 只有进度、缓冲或总时长变化时才重绘
    return oldDelegate.volume != volume;
  }
}
