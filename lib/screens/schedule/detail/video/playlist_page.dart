import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/schedule/schedule_page.dart';
import 'package:rikka/screens/settings/parser/tests/detail_entity.dart';
import 'package:rikka/screens/settings/player/video_player.dart';

import 'playlist_provider.dart';

class VideoPlayerPage extends ConsumerStatefulWidget {
  final DetailEntity detail;

  const VideoPlayerPage({super.key, required this.detail});

  @override
  ConsumerState<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends ConsumerState<VideoPlayerPage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    ref.read(playlistProvider.notifier).playList(widget.detail);
  }

  @override
  Widget build(BuildContext context) {
    final playlist = ref.watch(playlistProvider);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double aspect = width / height;
    if (aspect > 1.4) {
      return Scaffold(body: VideoPlayer(menu: _showMenu));
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

  void _showMenu(BuildContext context) {
    final playlist = ref.watch(playlistProvider);
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // 让遮罩层透明
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent, // 让对话框背景透明
          content: Container(
            width: 400,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.transparent, // 半透明白色背景
              borderRadius: BorderRadius.circular(10),
            ),
            child: VideoPlayerWidget(playlist: playlist.step3Map),
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
