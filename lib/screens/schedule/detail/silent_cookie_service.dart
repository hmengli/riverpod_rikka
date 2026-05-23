import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/utils/logger.dart';
import 'package:rikka/utils/utils.dart';

final cookieSilentServiceProvider = Provider.autoDispose<CookieSilentService>((
  ref,
) {
  final cookie = CookieSilentService();
  cookie.init();
  ref.onDispose(cookie.dispose);
  return cookie;
});

class CookieSilentService {
  // 不再有静态实例，构造函数公开
  CookieSilentService();

  bool _initialized = false;
  bool _disposed = false; // 新增：标记是否已释放
  late Completer<void> _pageLoadCompleter = Completer();
  late Completer<Uint8List?> _capturedCompleter = Completer();
  // late Completer<void> _submitCompleter = Completer();
  late WebUri webUri;
  late Uint8List? capturedCaptchaBytes;
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
          userAgent: Utils.getRandomUA(),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
          controller.addJavaScriptHandler(
            handlerName: 'toFlutter',
            callback: (data) {
              // args 是一个 List<dynamic>，包含网页传来的参数
              if (!_capturedCompleter.isCompleted) {
                final pureBase64 = data.first;
                if (pureBase64 is String &&
                    pureBase64.startsWith("data:image/png")) {
                  Uint8List byte = base64.decode(pureBase64.split(',').last);
                  _capturedCompleter.complete(byte);
                }
              }
              Log.d('toFlutter:$data');
              return {'status': 'success', 'received': data};
            },
          );
          if (!_controllerCompleter.isCompleted) {
            Log.d('Created');
            _controllerCompleter.complete(controller);
          }
        },
        shouldInterceptRequest: (controller, request) async {
          final url = request.url.toString();
          if (url.contains('/verify/')) {
            Log.d('Request:$url');
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
      Log.d('_initialized: $_initialized');
    } catch (e) {
      _controllerCompleter.completeError(e);
      rethrow;
    }
  }

  Future<Uint8List?> captureScreenshot(String url) async {
    try {
      if (_disposed) throw StateError('Service already disposed');
      final controller = await controllerReady;
      webUri = WebUri(url);
      final currentUrl = await _webViewController.getUrl();
      if (currentUrl != null && currentUrl.path != webUri.path) {
        await controller.loadUrl(urlRequest: URLRequest(url: webUri));
        await _pageLoadCompleter.future.timeout(Duration(seconds: 10));
      }
      return null;
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
      _capturedCompleter = Completer();

      final submitJs =
          """
      (function() {
        // 1. 定位图片元素（请将 $img 替换为实际选择器，如 '#captcha' 或 '.captcha-img'）
        var selector = "$img";
        var img = document.querySelector(selector);
        if (!img) {
          console.error("[Captcha] 未找到图片元素:", selector);
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              window.flutter_inappwebview.callHandler('toFlutter', { error: "Element not found" });
          }
          return;
        }

        // 2. 发送数据到 Flutter（统一封装）
        function sendToFlutter(data) {
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('toFlutter', data)
              .catch(err => console.error("[Captcha] 调用失败:", err));
          } else {
            console.warn("[Captcha] callHandler 不可用");
          }
        }

        // 3. 截图（返回 Promise，避免跨域和加载问题）
        function captureImage(imageElement) {
          return new Promise((resolve, reject) => {
            // 确保图片已经加载完成且尺寸有效
            if (imageElement.complete && imageElement.naturalWidth > 0) {
              try {
                var canvas = document.createElement('canvas');
                canvas.width = imageElement.naturalWidth;
                canvas.height = imageElement.naturalHeight;
                var ctx = canvas.getContext('2d');
                ctx.drawImage(imageElement, 0, 0);
                var dataUrl = canvas.toDataURL('image/png');
                resolve(dataUrl);
              } catch (e) {
                reject(new Error("Canvas 截图失败: " + e.message));
              }
            } else {
              // 等待加载完成
              imageElement.addEventListener('load', function onLoad() {
                imageElement.removeEventListener('load', onLoad);
                captureImage(imageElement).then(resolve).catch(reject);
              });
              imageElement.addEventListener('error', function onError() {
                imageElement.removeEventListener('error', onError);
                reject(new Error("图片加载失败"));
              });
            }
          });
        }

        var originalSrc = img.src;
        img.click();  // 触发刷新（假设图片可点击刷新）

        // 设置超时（防止一直等待，例如图片未刷新）
        var timeoutId = setTimeout(function() {
          observer.disconnect();
          console.warn("[Captcha] 超时未检测到 src 变化，直接截图");
          captureImage(img).then(sendToFlutter).catch(err => sendToFlutter({ error: err.message }));
        }, 3000);

        // 监听 src 属性变化
        var observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            if (mutation.type === 'attributes' && mutation.attributeName === 'src') {
              var newSrc = img.src;
              if (newSrc !== originalSrc) {
                // 检测到刷新
                clearTimeout(timeoutId);
                observer.disconnect();
                // 等待新图片完全加载
                if (img.complete) {
                  captureImage(img).then(sendToFlutter).catch(err => sendToFlutter({ error: err.message }));
                } else {
                  img.addEventListener('load', function onLoad() {
                    img.removeEventListener('load', onLoad);
                    captureImage(img).then(sendToFlutter).catch(err => sendToFlutter({ error: err.message }));
                  });
                  img.addEventListener('error', function onError() {
                    img.removeEventListener('error', onError);
                    sendToFlutter({ error: "新图片加载失败" });
                  });
                }
              }
            }
          });
        });
        observer.observe(img, { attributes: true, attributeFilter: ['src'] });
      })();
      """;
      controller.evaluateJavascript(source: submitJs);
      capturedCaptchaBytes = await _capturedCompleter.future.timeout(
        Duration(seconds: 10),
      );
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
      Log.d('submitCaptcha: $code,$input,$submit');
      final controller = await controllerReady;
      _pageLoadCompleter = Completer();
      if (code != null) {
        final submitJs =
            """
          (function() {
          /**
           * 通过 XPath 获取第一个匹配的 DOM 节点
           * @param {string} xpath - XPath 表达式
           * @param {Node} [contextNode=document] - 上下文节点（默认 document）
           * @returns {Node|null} 第一个匹配的节点，未找到返回 null
           */
          function getElementByXPath(xpath, contextNode = document) {
            const result = document.evaluate(
              xpath,
              contextNode,
              null,
              XPathResult.FIRST_ORDERED_NODE_TYPE,
              null
            );
            return result.singleNodeValue;
          }
          const input = getElementByXPath("//$input");
          input.focus();
          const nativeSetter = Object.getOwnPropertyDescriptor(
              window.HTMLInputElement.prototype,
              'value'
          ).set;
          nativeSetter.call(input, "$code");
          input.dispatchEvent(new Event('input', { bubbles: true }));
          input.dispatchEvent(new Event('change', { bubbles: true }));

          const btnEl = getElementByXPath("//$submit");
          if (btnEl) {
            btnEl.click();
          }
          })();
        """;
        controller.evaluateJavascript(source: submitJs);
        await _pageLoadCompleter.future.timeout(Duration(seconds: 5));
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
