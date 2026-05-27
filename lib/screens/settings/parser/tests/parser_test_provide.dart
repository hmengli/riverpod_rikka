import 'dart:typed_data';

import 'package:rikka/screens/schedule/detail/silent_cookie_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
class CookieNotifier extends _$CookieNotifier {
  late CookieSilentService cookie;

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

  Future<String?> parserCookie(
    String? code, {
    required String input,
    required String submit,
  }) {
    return cookie.submitCaptcha(code, input: input, submit: submit);
  }
}
