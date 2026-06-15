import 'dart:async';
import 'dart:typed_data';
import 'package:rikka/screens/auth_provider.dart';
import 'package:rikka/screens/schedule/detail/parser/parser_entity.dart';
import 'package:rikka/utils/logger.dart';
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
  void build(ParserEntity parser) {
    cookie = ref.watch(cookieServiceProvider);
    // cookie.initWebView();
    // ref.onDispose(cookie.dispose);
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
    Uint8List? verifyPng = await cookie.captureScreenshot(
      url,
      parser.verifyPng,
    );

    if (verifyPng == null) {
      return cookie.getCookieExpiry();
    }

    String code = await CaptchaService.recognizeCaptcha(verifyPng);

    if (code.length < 4) {
      verifyPng = await cookie.getScreenshot(parser.verifyPng);
      if (verifyPng == null) {
        return cookie.getCookieExpiry();
      }
      code = await CaptchaService.recognizeCaptcha(verifyPng);
    }

    return cookie.submitCaptcha(
      code,
      input: parser.verifyInput,
      submit: parser.verifySubmit,
    );
  }
}

@riverpod
Future<List<DetailEntity>> detailList(
  Ref ref,
  ParserEntity parser,
  ScheduleEntity comics,
) async {
  final parserService = ref.watch(parserServiceProvider);
  final cookie = ref.read(parserCookieProvider(parser.basisUrl));
  final headers = ref.read(browserHeadersProvider);
  if (cookie.isNotEmpty) {
    headers.addAll({'Cookie': cookie});
  }
  Log.i('detailList: $cookie');
  String resultsStep1 = await parserService.parseWithConfig(
    parser.searchUrl,
    search: comics.vodName,
    headers: headers,
    entity: parser,
  );

  if (parser.verify) {
    final List<String> verifyCookie = parserService.extractLinks4(
      resultsStep1,
      selector: parser.verifyPng,
    );

    Log.i('verifyCookie: $verifyCookie');
    if (verifyCookie.isNotEmpty) {
      final url = parser.searchUrl.replaceAll('@keyword', comics.vodName);
      // String? newCookie = '';
      final verifyNotifier = ref.watch(verifyImgProvider(parser).notifier);
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
