// playlist_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/schedule/detail/video/proxy_service.dart';
import 'package:rikka/screens/schedule/detail/video/silent_video_service.dart';
import 'package:rikka/screens/settings/parser/tests/detail_entity.dart';
import 'package:rikka/screens/settings/parser/tests/parser_repository.dart';
import 'package:rikka/screens/settings/player/video_provider.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'playlist_provider.g.dart';

/// 单独暴露位置（避免无关重建）
final step3MapProvider = Provider<List<List<Map<String, String>>>>((ref) {
  return ref.watch(playlistProvider).step3Map;
});

final selIndexProvider = Provider<int>((ref) {
  return ref.watch(playlistProvider).selIndex;
});

// ==================== 播放器状态类 ====================

class PlaylistState {
  final List<List<Map<String, String>>> step3Map;
  final int curIndex;
  final int selIndex;
  final DetailEntity? detail;

  PlaylistState({
    this.curIndex = 0,
    this.selIndex = 0,
    this.step3Map = const [],
    this.detail,
  });

  PlaylistState copyWith({
    int? curIndex,
    int? selIndex,
    List<List<Map<String, String>>>? step3Map,
  }) {
    return PlaylistState(
      curIndex: curIndex ?? this.curIndex,
      selIndex: selIndex ?? this.selIndex,
      step3Map: step3Map ?? this.step3Map,
      detail: detail,
    );
  }
}

@riverpod
class PlaylistNotifier extends _$PlaylistNotifier {
  late final VideoNotifier video;
  late final ParserService parserService;
  late final VideoSilentService videoSilent;

  @override
  PlaylistState build() {
    videoSilent = ref.watch(videoServiceProvider);
    videoSilent.initWebView();
    ref.onDispose(() {
      videoSilent.dispose();
    });
    parserService = ref.read(parserServiceProvider);
    video = ref.read(videoProvider.notifier);
    return PlaylistState();
  }

  Future<void> playList(DetailEntity detail) async {
    String step1Html = await parserService.parseWithConfig(
      detail.href,
      entity: detail.parser,
    );
    final step3Map = parserService.extractLinks2(
      step1Html,
      selector: detail.parser.chapterRoad,
      selectorValue: detail.parser.chapterList,
    );

    state = PlaylistState(step3Map: step3Map, detail: detail);
  }

  Future<void> playCurrent() async {
    final realUrl = await _fetchUrl(); // 模拟网络请求
    await video.play(realUrl);
  }

  Future<String?> _fetchUrl() async {
    try {
      DetailEntity detail = state.detail!;
      String? href = state.step3Map[state.curIndex][state.selIndex]['href'];
      if (href == null) return null;
      String videoUrl = '${detail.parser.basisUrl}$href';
      Log.i('videoUrl:$videoUrl');
      String? iframeUrl = await _httpGetIframe(videoUrl);
      Log.i('_httpGetIframe:$iframeUrl');
      if (iframeUrl != null) {
        videoUrl = iframeUrl;
      }
      final Extractor? extractorUrl = await videoSilent.extract(
        videoUrl,
        selectorMp: detail.parser.selectorVideo,
        selectorUm: detail.parser.selectorM3u8,
      );
      if (extractorUrl != null) {
        if (Extractor.m3u8.contains(extractorUrl.type)) {
          String requestUrl = await ProxyService().getMuUrl(extractorUrl.url);
          if (extractorUrl.url.contains('url=')) {
            Uri uri = Uri.parse(extractorUrl.url);
            requestUrl = uri.queryParameters['url'] ?? requestUrl;
          }
          Log.i('_fetchUrl:$requestUrl');
          return requestUrl;
        } else if (Extractor.mp4.contains(extractorUrl.type)) {
          String requestUrl = extractorUrl.url;
          if (extractorUrl.url.contains('url=')) {
            Uri uri = Uri.parse(extractorUrl.url);
            requestUrl = uri.queryParameters['url'] ?? requestUrl;
          }
          Log.i('_fetchUrl:$requestUrl');
          return requestUrl;
        }
      }
      return null;
    } catch (e) {
      Log.e('_httpGetIframe:$e');
      return null;
    }
  }

  //获取视频界面面板
  Future<String?> _httpGetIframe(String videoUrl) async {
    try {
      DetailEntity detail = state.detail!;
      String step1Html = await parserService.parseWithConfig(
        videoUrl,
        entity: detail.parser,
      );
      return parserService.extractLinks3(
        step1Html,
        selector: detail.parser.selectorIframe,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> next() async {
    if (state.selIndex + 1 < state.step3Map[state.curIndex].length) {
      state = state.copyWith(selIndex: state.selIndex + 1);
      await playCurrent();
    }
  }

  Future<void> tabIndex(int index) async {
    if (index < state.step3Map.length && index >= 0) {
      state = state.copyWith(selIndex: index);
      await playCurrent();
    }
  }

  Future<void> playIndex(int index) async {
    if (index < state.step3Map[state.curIndex].length && index >= 0) {
      state = state.copyWith(selIndex: index);
      await playCurrent();
    }
  }
}
