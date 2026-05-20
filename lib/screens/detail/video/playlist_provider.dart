// playlist_provider.dart
import 'dart:async';

import 'package:rikka/screens/parser/parser_entity.dart';
import 'package:rikka/screens/parser/parser_repository.dart';
import 'package:rikka/screens/parser/player/video_provider.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'proxy_service.dart';
import 'silent_video_service.dart';

part 'playlist_provider.g.dart';

@riverpod
class PlaylistNotifier extends _$PlaylistNotifier {
  late final VideoNotifier video;
  late final ParserService parserService;
  @override
  late final DetailEntity detail;
  List<List<Map<String, String>>> step3Map = [];
  int curIndex = 0;
  int selIndex = 0;

  // 初始状态：未登录，加载完成
  @override
  Future<List<List<Map<String, String>>>> build(DetailEntity detail) {
    // 如果希望初始为未登录且不显示加载，可以直接返回 AsyncValue.data(null)
    video = ref.watch(videoProvider.notifier);
    parserService = ref.read(parserServiceProvider);
    detail = detail;
    return _startParseHtml();
  }

  Future<List<List<Map<String, String>>>> _startParseHtml() async {
    try {
      String step1Html = await parserService.parseWithConfig(
        detail.href,
        entity: detail.parser,
      );
      step3Map = parserService.extractLinks2(
        step1Html,
        selector: detail.parser.chapterRoad,
        selectorValue: detail.parser.chapterList,
      );
      Log.i('_testParseHtml:$step3Map');
      return step3Map;
    } catch (e) {
      Log.e('_testParseHtml:$e');
      return [];
    }
  }

  Future<void> playCurrent({
    required List<Map<String, String>> token,
    required int? index,
    required DetailEntity detail,
  }) async {
    state = const AsyncValue.loading();
    final realUrl = await _fetchUrl(
      token: token,
      index: index,
      detail: detail,
    ); // 模拟网络请求
    await video.play(realUrl);
  }

  Future<String?> _fetchUrl({
    required List<Map<String, String>> token,
    required int? index,
    required DetailEntity detail,
  }) async {
    String videoUrl = '${detail.parser.basisUrl}${token[selIndex]['href']}';
    Log.i('videoUrl:$videoUrl');
    try {
      String? iframeUrl = await _httpGetIframe(detail, videoUrl);
      Log.i('_httpGetIframe:$iframeUrl');
      if (iframeUrl != null) {
        videoUrl = iframeUrl;
      }
      final Extractor? extractorUrl = await VideoSilentService().extract(
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
  Future<String?> _httpGetIframe(DetailEntity detail, String videoUrl) async {
    try {
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
    if (selIndex + 1 < step3Map[curIndex].length) {
      selIndex++;
      await playCurrent(
        token: step3Map[curIndex],
        index: selIndex,
        detail: detail,
      );
    }
  }

  Future<void> tabIndex(int index) async {
    if (index < step3Map.length && index >= 0) {
      curIndex = index;
      await playCurrent(
        token: step3Map[curIndex],
        index: selIndex,
        detail: detail,
      );
    }
  }

  Future<void> playIndex(int index) async {
    if (index < step3Map[curIndex].length && index >= 0) {
      selIndex = index;
      await playCurrent(
        token: step3Map[curIndex],
        index: selIndex,
        detail: detail,
      );
    }
  }
}
