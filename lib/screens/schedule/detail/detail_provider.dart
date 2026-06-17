import 'dart:async';
import 'dart:typed_data';
import 'package:rikka/screens/auth_provider.dart';
import 'package:rikka/screens/schedule/detail/parser/parser_entity.dart';
import 'package:rikka/logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../schedule_entity.dart';
import 'detail_entity.dart';
import 'silent_cookie_service.dart';

part 'detail_provider.g.dart';

// ===================== 页面请求：返回数据列表 =====================

@riverpod
Future<List<DetailEntity>> detailList(
  Ref ref,
  ParserEntity parser,
  ScheduleEntity comics,
) async {
  // 依赖请求服务
  final parserService = ref.watch(parserServiceProvider);
  // 部分需要cookie
  final cookie = ref.read(parserCookieProvider(parser.basisUrl));
  // 动态请求头
  final headers = ref.read(browserHeadersProvider);
  if (cookie.isNotEmpty) {
    headers.addAll({'Cookie': cookie});
  }
  // 获取页面
  Log.i('detailList: $cookie');
  String resultsStep1 = await parserService.parseWithConfig(
    parser.searchUrl,
    search: comics.vodName,
    headers: headers,
    entity: parser,
  );
  //需要验证
  if (parser.verify) {
    //验证Cookie是否有效
    final List<String> verifyCookie = parserService.extractLinks4(
      resultsStep1,
      selector: parser.verifyPng,
    );

    Log.i('verifyCookie: $verifyCookie');
    // 无效Cookie
    if (verifyCookie.isNotEmpty) {
      final verifyNotifier = ref.watch(verifyImgProvider(parser).notifier);
      String url = parser.searchUrl.replaceAll('@keyword', comics.vodName);
      String? newCookie = await verifyNotifier.getVerifyCookie(url);

      final cookieNotifier = ref.read(
        parserCookieProvider(parser.basisUrl).notifier,
      );
      cookieNotifier.setState(newCookie ?? '');

      headers.addAll({'cookie': newCookie ?? ''});
      resultsStep1 = await parserService.parseWithConfig(
        parser.searchUrl,
        search: comics.vodName,
        headers: headers,
        entity: parser,
      );
    }
  }

  final results = parserService.extractLinks1(
    resultsStep1,
    titleSelector: parser.searchTitle,
    hrefSelector: parser.searchHref,
  );
  Log.i('detailList: $results');
  return results.map((e) {
    return DetailEntity(
      title: '${e['title']}',
      href: '${parser.basisUrl}${e['href']}',
      parser: parser,
      comics: comics,
    );
  }).toList();
}

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
  void build(ParserEntity parser) {
    cookie = ref.watch(cookieServiceProvider);
  }

  Future<Uint8List?> loadingPage(String url) async {
    return cookie.captureScreenshot(url, parser.verifyPng);
  }

  Future<Uint8List?> getScreenshot() async {
    return cookie.getScreenshot(parser.verifyPng);
  }

  Future<String?> parserCookie(String? code) {
    return cookie.submitCaptcha(
      code,
      input: parser.verifyInput,
      submit: parser.verifySubmit,
    );
  }

  Future<String?> getVerifyCookie(String url) async {
    Uint8List? verifyPng = await loadingPage(url);

    if (verifyPng == null) {
      return await cookie.getCookieExpiry();
    }
    String code = await CaptchaService.recognizeCaptcha(verifyPng);

    if (code.length < 4) {
      verifyPng = await getScreenshot();
      if (verifyPng == null) {
        return await cookie.getCookieExpiry();
      }
      code = await CaptchaService.recognizeCaptcha(verifyPng);
    }

    return await cookie.submitCaptcha(
      code,
      input: parser.verifyInput,
      submit: parser.verifySubmit,
    );
  }
}

@Riverpod(keepAlive: true)
class ParserCookieNotifier extends _$ParserCookieNotifier {
  @override
  String build(String url) {
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
  @override
  void build(ParserEntity entity) {
    parserService = ref.watch(parserServiceProvider);
  }

  Future<List<List<Map<String, String>>>> step3Map(String href) async {
    final headers = ref.read(browserHeadersProvider);
    String step1Html = await parserService.parseWithConfig(
      href,
      entity: entity,
      headers: headers,
    );
    return parserService.extractLinks2(
      step1Html,
      selector: entity.chapterRoad,
      selectorValue: entity.chapterList,
    );
  }

  //获取视频界面面板
  Future<String?> httpGetIframe(String videoUrl) async {
    final headers = ref.read(browserHeadersProvider);
    String step1Html = await parserService.parseWithConfig(
      videoUrl,
      entity: entity,
      headers: headers,
    );
    return parserService.extractLinks3(
      step1Html,
      selector: entity.selectorIframe,
    );
  }

  // Future<List<String>> verifyCookie(String videoUrl) async {
  //   final cookie = ref.read(parserCookieProvider(entity.basisUrl));
  //   String step1Html = await parserService.parseWithConfig(
  //     videoUrl,
  //     entity: entity,
  //     cookie: cookie,
  //   );
  //   return parserService.extractLinks4(step1Html, selector: entity.verifyPng);
  // }
}

@riverpod
ParserService parserService(Ref ref) {
  return ParserService();
}
