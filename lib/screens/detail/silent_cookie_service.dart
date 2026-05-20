import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:rikka/screens/parser/api_service.dart';
// import 'package:http/http.dart' as http;
import 'package:rikka/utils/logger.dart';
import 'package:rikka/utils/utils.dart';

class CookieSilentService {
  // 不再有静态实例，构造函数公开
  CookieSilentService();

  bool _initialized = false;
  bool _disposed = false; // 新增：标记是否已释放
  late Completer<void> _pageLoadCompleter = Completer();
  late Completer<void> _submitCompleter = Completer();
  late WebUri webUri;
  late Uint8List capturedCaptchaBytes;
  late HeadlessInAppWebView _headlessWebView;
  late InAppWebViewController _webViewController;

  final Completer<InAppWebViewController> _controllerCompleter = Completer();
  Future<InAppWebViewController> get controllerReady =>
      _controllerCompleter.future;

  final _cookieManager = CookieManager.instance();

  Future<void> init() async {
    if (_initialized) return;
    if (_disposed) throw StateError('Service already disposed');
    // if (_controllerCompleter.isCompleted) return;

    try {
      _headlessWebView = HeadlessInAppWebView(
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          javaScriptCanOpenWindowsAutomatically: true,
          cacheEnabled: true,
          supportZoom: false,
          useShouldInterceptRequest: true,
          userAgent: Utils.userAgent,
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
          if (!_controllerCompleter.isCompleted) {
            _controllerCompleter.complete(controller);
          }
        },
        shouldInterceptRequest: (controller, request) async {
          final url = request.url.toString();
          if (url.contains('/verify/')) {
            Log.d('Request:$url');
            final response = await Http().get(url);
            capturedCaptchaBytes = response.data;
            _submitCompleter.complete();

            return WebResourceResponse(
              data: capturedCaptchaBytes,
              statusCode: 200,
              headers: Map.from(response.headers.map)
                ..remove('content-length')
                ..remove('transfer-encoding'),
            );
          }
          return null;
        },
        onLoadStop: (controller, url) {
          Log.d('onLoadStop');
          if (!_pageLoadCompleter.isCompleted) {
            _pageLoadCompleter.complete();
          }
        },
      );

      await _headlessWebView.run();
      _initialized = true;
    } catch (e) {
      _controllerCompleter.completeError(e);
      rethrow;
    }
  }

  Future<Uint8List?> captureScreenshot(String url) async {
    Log.d('getScreenshot: $url');
    try {
      if (_disposed) throw StateError('Service already disposed');
      final controller = await controllerReady;
      webUri = WebUri(url);
      final currentUrl = await _webViewController.getUrl();

      if (currentUrl != null && currentUrl.path != webUri.path) {
        await controller.loadUrl(urlRequest: URLRequest(url: webUri));
        Log.d('currentUrl: $currentUrl');
        Log.d('webUri: $webUri');
        await _submitCompleter.future.timeout(Duration(seconds: 5));
      }
      return capturedCaptchaBytes;
    } catch (e) {
      Log.e('获取验证码失败: $e');
      return null;
    }
  }

  Future<Uint8List?> getScreenshot(String img) async {
    Log.d('getScreenshot: $img');
    try {
      if (_disposed) throw StateError('Service already disposed');
      final controller = await controllerReady;
      _submitCompleter = Completer();

      final submitJs =
          """
          (function() {
            const img = document.querySelector('$img');
            if (img) img.click();
          })();
        """;
      controller.evaluateJavascript(source: submitJs);
      await _submitCompleter.future.timeout(Duration(seconds: 3));
      return capturedCaptchaBytes;
    } catch (e) {
      Log.e('获取验证码失败: $e');
      return null;
    }
  }

  Future<String?> submitCaptcha(
    String? code, {
    required String input,
    required String submit,
  }) async {
    try {
      if (_disposed) throw StateError('Service already disposed');
      Log.d('submitCaptcha: $code');
      final controller = await controllerReady;
      _pageLoadCompleter = Completer();
      if (code != null) {
        final submitJs =
            """
          (function() {
            const input = document.querySelector('$input');
            if (input) {
              input.value = '$code';
            }
            const submit = document.querySelector('$submit');
            if (submit) submit.click();
          })();
        """;
        controller.evaluateJavascript(source: submitJs);
        await _pageLoadCompleter.future.timeout(Duration(seconds: 10));
      }
      final currentUrl = await _webViewController.getUrl();
      final cookies = await _cookieManager.getCookies(url: currentUrl!);
      return cookies.map((c) => '${c.name}=${c.value}').join('; ');
    } catch (e) {
      Log.e('submitCaptcha: $e');
      return null;
    }
  }

  void dispose() {
    if (!_initialized) return;
    if (_disposed) return;
    _disposed = true;
    _initialized = false;
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.completeError(
        StateError('Service disposed before initialization'),
      );
    }
    // _webViewController.dispose();
    _headlessWebView.dispose();
  }
}
