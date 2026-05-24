import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/settings/parser/parser_entity.dart';
import 'package:rikka/component/player/video_player.dart';
import 'package:rikka/screens/schedule/schedule_page.dart';

import 'playlist_provider.dart';

class VideoPlayerPage extends ConsumerStatefulWidget {
  final DetailEntity detail;
  const VideoPlayerPage({super.key, required this.detail});

  @override
  ConsumerState<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends ConsumerState<VideoPlayerPage>
    with TickerProviderStateMixin {
  static const double _animationTabHigh = 300;
  late AnimaController _controlsManagerTab;

  @override
  void initState() {
    super.initState();
    ref.read(playlistProvider.notifier).playList(widget.detail);
    _controlsManagerTab = AnimaController(
      vsync: this,
      animationBegin: _animationTabHigh,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controlsManagerTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlist = ref.watch(playlistProvider);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double aspect = width / height;
    if (aspect > 1.4) {
      return Scaffold(
        body: VideoPlayer(
          // animatedTab: getAnimatedTabControls(),
          // controlsManagerTab: _controlsManagerTab,
        ),
      );
    } else {
      return Scaffold(
        body: Column(
          children: [
            VideoPlayer(),
            Expanded(child: VideoPlayerWidget(playlist: playlist.step3Map)),
          ],
        ),
      );
    }
  }

  /*
  *   播放列表
  */
  Widget getAnimatedTabControls() {
    final playlist = ref.watch(step3MapProvider);
    return AnimatedBuilder(
      animation: _controlsManagerTab.opacityAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          right: _controlsManagerTab.opacityAnimation.value,
          bottom: 0,
          child: Container(
            width: _animationTabHigh,
            decoration: BoxDecoration(boxShadow: [BoxShadow(blurRadius: 5)]),
            child: Center(child: VideoPlayerWidget(playlist: playlist)),
          ),
        );
      },
    );
  }
}

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final List<List<Map<String, String>>> playlist;
  const VideoPlayerWidget({super.key, required this.playlist});

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(playlistProvider.notifier);
    final selIndex = ref.watch(selIndexProvider);

    if (widget.playlist.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return TabBarWidget(
        // onTap: (p0) => service.tabIndex(p0),
        isScrollable: true,
        tabList: widget.playlist,
        tabs: (p1) {
          return List.generate(p1.length, (i) {
            return Tab(text: '播放列表$i');
          });
        },
        children: widget.playlist
            .map(
              (e) => LayoutBuilder(
                builder: (context, box) {
                  double parentWidth = box.maxWidth;
                  return GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (parentWidth / 100)
                          .toInt(), // 每行2个item（竖向滚动时）
                      mainAxisSpacing: 10, // 主轴方向间距（竖向滚动时为垂直间距）
                      crossAxisSpacing: 10, // 交叉轴方向间距（竖向滚动时为水平间距）
                      childAspectRatio: 3.0, // 子组件宽高比（宽度/高度）
                    ),
                    children: List.generate(e.length, (index) {
                      final selected = selIndex == index;
                      return Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          TextButton(
                            onPressed: selected
                                ? null
                                : () => notifier.playIndex(index),
                            child: Text(e[index]['value'].toString()),
                          ),
                          if (selected) Icon(Icons.check_circle),
                        ],
                      );
                    }),
                  );
                },
              ),
            )
            .toList(),
      );
    }
  }
}
