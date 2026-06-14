import 'dart:async';
import 'dart:typed_data';

import 'package:rikka/screens/schedule/detail/parser/parser_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../schedule_entity.dart';
import 'detail_entity.dart';
import 'silent_cookie_service.dart';

part 'detail_provider.g.dart';

@riverpod
class IsCookieNotifier extends _$IsCookieNotifier {
  @override
  bool build() => false;
  void setState(bool value) => state = value;
}

@riverpod
class VerifyImgNotifier extends _$VerifyImgNotifier {
  late final SilentCookieService cookie;

  @override
  Future<Uint8List?> build(VerifyEntity verify) async {
    cookie = ref.watch(cookieServiceProvider);
    return await loadingPage();
  }

  Future<Uint8List?> loadingPage() async {
    return cookie.captureScreenshot(verify.url, verify.parser.verifyPng);
  }

  Future<void> getScreenshot() async {
    final parser = verify.parser;
    state = await AsyncValue.guard(
      () => cookie.getScreenshot(parser.verifyPng),
    );
  }

  Future<String?> parserCookie(String? code, {required ParserEntity entity}) {
    return cookie.submitCaptcha(
      code,
      input: entity.verifyInput,
      submit: entity.verifySubmit,
    );
  }
}

@riverpod
Future<List<DetailEntity>> detailList(
  Ref ref,
  ParserEntity parser,
  ScheduleEntity comics,
) async {
  return ref.watch(extractServiceProvider(parser).notifier).detailList(comics);
}

@riverpod
class ParserCookieNotifier extends _$ParserCookieNotifier {
  @override
  String build(String url) {
    // 1. 获取这把“钥匙”
    // 注意：这里的 link 是 autoDispose 提供的特有方法
    final link = ref.keepAlive();

    // 2. 设置一个 5 分钟的计时器
    final timer = Timer(const Duration(minutes: 5), () {
      // 3. 计时结束，关闭钥匙，允许它在没有监听者时被销毁
      link.close();
    });

    // 当 Provider 自身被销毁时，务必取消计时器，防止内存泄漏
    ref.onDispose(() {
      timer.cancel();
    });
    return '';
  }

  void setState(String value) => state = value;
}

@riverpod
class GetCodeNotifier extends _$GetCodeNotifier {
  @override
  String build() => '';

  Future<void> setState(Uint8List prev) async {
    state = await CaptchaService.recognizeCaptcha(prev);
  }
}

@riverpod
class ExtractServiceNotifier extends _$ExtractServiceNotifier {
  late final ParserService parserService;
  late final String cookie;
  @override
  void build(ParserEntity entity) {
    parserService = ref.read(parserServiceProvider);
    cookie = ref.read(parserCookieProvider(entity.basisUrl));
  }

  Future<List<DetailEntity>> detailList(ScheduleEntity comics) async {
    String resultsStep1 = await parserService.parseWithConfig(
      entity.searchUrl,
      search: comics.vodName,
      cookie: cookie,
      entity: entity,
    );
    final results = parserService.extractLinks1(
      resultsStep1,
      titleSelector: entity.searchTitle,
      hrefSelector: entity.searchHref,
    );
    return results.map((e) {
      return DetailEntity(
        title: '${e['title']}',
        href: '${entity.basisUrl}${e['href']}',
        parser: entity,
        comics: comics,
      );
    }).toList();
  }

  Future<List<List<Map<String, String>>>> step3Map(String href) async {
    String step1Html = await parserService.parseWithConfig(
      href,
      entity: entity,
      cookie: cookie,
    );
    return parserService.extractLinks2(
      step1Html,
      selector: entity.chapterRoad,
      selectorValue: entity.chapterList,
    );
  }

  //获取视频界面面板
  Future<String?> httpGetIframe(String videoUrl) async {
    String step1Html = await parserService.parseWithConfig(
      videoUrl,
      entity: entity,
      cookie: cookie,
    );
    return parserService.extractLinks3(
      step1Html,
      selector: entity.selectorIframe,
    );
  }
}

@riverpod
ParserService parserService(Ref ref) {
  return ParserService();
}

@riverpod
SilentCookieService cookieService(Ref ref) {
  final silentCookieService = SilentCookieService();
  silentCookieService.initWebView();
  ref.onDispose(silentCookieService.dispose);
  return silentCookieService;
}
