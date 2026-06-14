// playlist_provider.dart
import 'dart:async';

import 'package:rikka/screens/schedule/detail/video/silent_proxy_service.dart';
import 'package:rikka/screens/schedule/detail/video/silent_video_service.dart';
import 'package:rikka/screens/schedule/detail/detail_entity.dart';
import 'package:rikka/screens/schedule/detail/video/player/video_provider.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../detail_provider.dart';
import 'playlist_entity.dart';

part 'playlist_provider.g.dart';

@riverpod
Future<List<List<Map<String, String>>>> step3Map(
  Ref ref,
  DetailEntity detail,
) async {
  final notifier = ref.read(extractServiceProvider(detail.parser).notifier);
  return notifier.step3Map(detail.href);
}

@riverpod
class PlaylistNotifier extends _$PlaylistNotifier {
  @override
  PlaylistEntity build(DetailEntity detail) {
    final step3Map = ref.watch(step3MapProvider(detail)).value;
    return PlaylistEntity(step3Map: step3Map ?? [], detail: detail);
  }

  Future<void> playCurrent() async {
    final realUrl = await _fetchUrl(); // 模拟网络请求
    await ref.read(videoProvider.notifier).play(realUrl);
  }

  Future<String?> _fetchUrl() async {
    DetailEntity detail = state.detail;
    final eNotifier = ref.read(extractServiceProvider(detail.parser).notifier);
    final videoSilent = ref.watch(videoServiceProvider);
    final proxyService = ref.watch(proxyServiceProvider);
    try {
      String? href = state.step3Map[state.curIndex][state.selIndex]['href'];
      if (href == null) return null;
      String videoUrl = '${detail.parser.basisUrl}$href';
      Log.i('videoUrl:$videoUrl');
      String? iframeUrl = await eNotifier.httpGetIframe(videoUrl);
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
          String requestUrl = await proxyService.getMuUrl(extractorUrl.url);
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
      Log.e('_fetchUrl:$e');
      return null;
    }
  }

  Future<void> curIndex(int index) async {
    if (index < state.step3Map.length && index >= 0) {
      state = state.copyWith(curIndex: index);
      await playCurrent();
    }
  }

  Future<void> next() async {
    if (state.selIndex + 1 < state.step3Map[state.curIndex].length) {
      state = state.copyWith(selIndex: state.selIndex + 1);
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
