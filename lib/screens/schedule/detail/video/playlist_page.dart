import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/schedule/schedule_page.dart';
import 'package:rikka/screens/schedule/detail/detail_entity.dart';
import 'package:rikka/screens/schedule/detail/video/player/video_player.dart';

import 'playlist_entity.dart';
import 'playlist_provider.dart';

class VideoPlayerPage extends ConsumerStatefulWidget {
  final DetailEntity detail;

  const VideoPlayerPage({super.key, required this.detail});

  @override
  ConsumerState<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends ConsumerState<VideoPlayerPage> {
  @override
  Widget build(BuildContext context) {
    final playlist = ref.watch(playlistProvider(widget.detail));
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
            Expanded(child: VideoPlayerWidget(playlist: playlist)),
          ],
        ),
      );
    }
  }

  void _showMenu(BuildContext context) {
    final playlist = ref.watch(playlistProvider(widget.detail));
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
            child: VideoPlayerWidget(playlist: playlist),
          ),
        );
      },
    );
  }
}

class VideoPlayerWidget extends ConsumerWidget {
  final PlaylistEntity playlist;
  const VideoPlayerWidget({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(playlistProvider(playlist.detail).notifier);

    if (playlist.step3Map.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return TabBarWidget(
        onTap: (p0) => notifier.curIndex(p0),
        isScrollable: true,
        tabList: playlist.step3Map,
        tabs: (p1) {
          return List.generate(p1.length, (i) {
            return Tab(text: '播放列表$i');
          });
        },
        children: List.generate(playlist.step3Map.length, (index) {
          final element = playlist.step3Map[index];
          return LayoutBuilder(
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
                children: List.generate(element.length, (index) {
                  final selected = playlist.selIndex == index;
                  return Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      TextButton(
                        onPressed: selected
                            ? null
                            : () => notifier.playIndex(index),
                        child: Text(element[index]['value'].toString()),
                      ),
                      if (selected) Icon(Icons.check_circle),
                    ],
                  );
                }),
              );
            },
          );
        }),
      );
    }
  }
}
