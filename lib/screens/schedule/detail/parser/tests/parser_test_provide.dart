import 'dart:typed_data';

import 'package:browser_headers/browser_headers.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:rikka/screens/schedule/detail/parser/tests/silent_cookie_service.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../schedule_entity.dart';
import '../../detail_entity.dart';
import '../parser_entity.dart';

part 'parser_test_provide.g.dart';

@riverpod
class GetCodeNotifier extends _$GetCodeNotifier {
  @override
  String build() {
    return "";
  }

  Future<void> getCode(Uint8List prev) async {
    state = await CaptchaService.recognizeCaptcha(prev);
  }
}

@riverpod
class VerifyImgNotifier extends _$VerifyImgNotifier {
  late SilentCookieService cookie;

  @override
  Uint8List? build() {
    cookie = ref.read(cookieServiceProvider);
    cookie.initWebView();
    ref.onDispose(cookie.dispose);
    return null;
  }

  Future<void> loadingPage(String step1Url, String img) async {
    state = await cookie.captureScreenshot(step1Url, img);
  }

  Future<void> setScreenshot(String verifyPng) async {
    state = await cookie.getScreenshot(verifyPng);
  }

  Future<String?> parserCookie(String? code, {required ParserEntity entity}) {
    return cookie.submitCaptcha(
      code,
      input: entity.verifyInput,
      submit: entity.verifySubmit,
    );
  }
}

@Riverpod(keepAlive: true)
class ParserCookieNotifier extends _$ParserCookieNotifier {
  @override
  String build(String url) => '';
  void setState(String value) => state = value;
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

class ParserService {
  // 执行完整的三步解析
  Future<String> parseWithConfig(
    String step1Url, {
    required String? cookie,
    required ParserEntity entity,
    String? search,
  }) async {
    try {
      if (search != null) {
        step1Url = step1Url.replaceAll('@keyword', search);
      }
      return await fetchPage(
        uri: step1Url,
        parserEntity: entity,
        cookie: cookie ?? '',
      );
    } catch (e) {
      throw Exception('网络错误，请检查网络: $e');
    }
  }

  // 获取页面HTML
  Future<String> fetchPage({
    required String uri,
    required String cookie,
    required ParserEntity parserEntity,
  }) async {
    Log.i('请求URL: $uri');

    final headers = BrowserHeaders.generate();
    if (parserEntity.referer.isNotEmpty) {
      headers.addAll({'Referer': parserEntity.referer});
    }

    if (cookie.isNotEmpty) {
      headers.addAll({'Cookie': cookie});
    }

    Log.i('headers: $headers');

    final response = await http.get(Uri.parse(uri), headers: headers);

    if (response.statusCode == 200) {
      Log.i('请求URL: ${response.statusCode}');
      return response.body;
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  // 提取链接或内容
  List<Map<String, String?>> extractLinks1(
    String html, {
    required String hrefSelector,
    required String titleSelector,
  }) {
    if (hrefSelector.isEmpty || titleSelector.isEmpty) return [];
    final document = parser.parse(html);
    final elements = document.querySelectorAll(hrefSelector);
    return elements.map((element) {
      String? href = element.querySelector('a')?.attributes['href'];
      String? title;
      if (titleSelector.contains('@')) {
        List<String> list = titleSelector.split('@');
        title = element.querySelector(list[0])?.attributes[list[1]];
      } else {
        title = element.querySelector(titleSelector)?.text;
      }
      return {'href': href ?? '', 'title': title ?? ''};
    }).toList();
  }

  // 提取链接或内容
  List<List<Map<String, String>>> extractLinks2(
    String html, {
    required String selector,
    required String selectorValue,
  }) {
    if (selector.isEmpty || selectorValue.isEmpty) return [];
    final document = parser.parse(html);
    final elements = document.querySelectorAll(selector);
    return List.generate(elements.length, (index) {
      final elementsA = elements[index].querySelectorAll(selectorValue);
      return elementsA.map((element) {
        return {
          'href': element.attributes['href'].toString(),
          'value': element.text.trim(),
        };
      }).toList();
    });
  }

  // 提取链接或内容
  String? extractLinks3(String html, {required String selector}) {
    final document = parser.parse(html);
    final elements = document.querySelector('iframe');
    return elements?.attributes['src'].toString();
  }
}
