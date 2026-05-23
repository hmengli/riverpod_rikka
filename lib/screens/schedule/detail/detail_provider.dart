import 'dart:typed_data';
import 'package:rikka/screens/settings/parser/parser_entity.dart';
import 'package:rikka/screens/settings/parser/parser_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'silent_cookie_service.dart';

part 'detail_provider.g.dart';

@riverpod
Future<List<DetailEntity>> detailList(
  Ref ref,
  ParserEntity parser,
  String vodName,
) async {
  final parserService = ref.read(parserServiceProvider);
  String resultsStep1 = await parserService.parseWithConfig(
    parser.searchUrl,
    search: vodName,
    entity: parser,
  );
  final results = parserService.extractLinks1(
    resultsStep1,
    titleSelector: parser.searchTitle,
    hrefSelector: parser.searchHref,
  );
  return results.map((e) {
    return DetailEntity(
      id: '${e['id']}',
      title: '${e['title']}',
      href: '${parser.basisUrl}${e['href']}',
      imageSrc: '',
      parser: parser,
    );
  }).toList();
}

@riverpod
class ImgNotifier extends _$ImgNotifier {
  late CookieSilentService cookie;

  @override
  Uint8List? build() {
    cookie = ref.read(cookieSilentServiceProvider);
    // 注册销毁回调：取消所有进行中的异步任务
    ref.onDispose(() {
      cookie.dispose();
    });
    return null;
  }

  Future<void> captureScreenshot(String step1Url) async {
    state = await cookie.captureScreenshot(step1Url);
  }

  Future<void> setScreenshot(String verifyPng) async {
    state = await cookie.getScreenshot(verifyPng);
  }

  Future<String?> parserCookie(
    String? code, {
    required String input,
    required String submit,
  }) {
    return cookie.submitCaptcha(code, input: input, submit: submit);
  }
}

@riverpod
class IsCookieNotifier extends _$IsCookieNotifier {
  @override
  bool build() {
    return false; // 初始状态为 false
  }

  void setIsCookie(bool value) {
    state = value; // 更新状态，会通知所有监听者
  }
}
