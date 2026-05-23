import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:rikka/utils/logger.dart';
import 'package:rikka/utils/utils.dart';

/// 提供 CookieSilentWebView 实例的 Provider（以便在外部调用其方法）
// final cookieSilentWebViewProvider = Provider<CookieSilentWebViewState?>((ref) {
//   return null; // 实际值需要在 Widget 构建时通过 State 提供
// });

class MyCaptchaPage extends StatefulWidget {
  const MyCaptchaPage({super.key});

  @override
  State<MyCaptchaPage> createState() => _MyCaptchaPageState();
}

class _MyCaptchaPageState extends State<MyCaptchaPage> {
  final GlobalKey<CookieSilentWebViewState> _webViewKey = GlobalKey();
  Uint8List? _imgCaptcha;
  String showCode = '';

  Future<void> _fetchCaptcha() async {
    final webViewState = _webViewKey.currentState;
    if (webViewState != null) {
      await webViewState.captureScreenshot(
        'https://dm.xifanacg.com/search.html?wd=%E4%BB%8E%E9%9B%B6',
      );
      setState(() {});
      // 显示验证码图片...
    }
  }

  Future<void> _reSetCookie() async {
    final webViewState = _webViewKey.currentState;
    if (webViewState != null) {
      _imgCaptcha = await webViewState.getScreenshot('.ds-verify-img');
      setState(() {});
      // 显示验证码图片...
    }
  }

  Future<void> _setCookie() async {
    final webViewState = _webViewKey.currentState;
    if (webViewState != null) {
      await webViewState.submitCaptcha(
        showCode,
        input: "input[@name='verify']",
        submit: '.verify-submit',
      );
      setState(() {});
      // 显示验证码图片...
    }
  }

  // Future<void> _submit(String code) async {
  //   final webViewState = _webViewKey.currentState;
  //   final cookies = await webViewState?.submitCaptcha(code, input: '...', submit: '...');
  //   // 处理 cookies...
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('验证码识别')),
      body: Column(
        children: [
          // 显示 WebView（可以设置高度或直接全屏）
          Expanded(child: CookieSilentWebView(key: _webViewKey)),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _fetchCaptcha(),
                child: Text('读取'),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () => _reSetCookie(),
                  child: _imgCaptcha != null
                      ? Image.memory(_imgCaptcha!)
                      : CircularProgressIndicator(),
                ),
              ),
              Expanded(
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(hintText: "验证码"),
                  onChanged: (value) {
                    showCode = value;
                  },
                ),
              ),
              ElevatedButton(onPressed: () => _setCookie(), child: Text('写入')),
              // ElevatedButton(
              //   onPressed: () => _parserCookie(),
              //   child: Text('提交'),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 有头的 WebView 组件，封装了原 CookieSilentService 的所有逻辑
class CookieSilentWebView extends StatefulWidget {
  const CookieSilentWebView({super.key});

  @override
  CookieSilentWebViewState createState() => CookieSilentWebViewState();
}

class CookieSilentWebViewState extends State<CookieSilentWebView> {
  // 保留原有服务的所有成员变量
  bool _initialized = false;
  bool _disposed = false;
  late Completer<void> _pageLoadCompleter = Completer();
  // late Completer<void> _submitCompleter = Completer();
  late Completer<Uint8List> _capturedCompleter = Completer();
  late WebUri webUri;
  late Uint8List capturedCaptchaBytes;
  late InAppWebViewController _webViewController;
  final Completer<InAppWebViewController> _controllerCompleter = Completer();
  final _cookieManager = CookieManager.instance();

  Future<InAppWebViewController> get controllerReady =>
      _controllerCompleter.future;

  @override
  void initState() {
    super.initState();
    // 注意：WebView 的初始化现在交给 onWebViewCreated 回调
    _init();
  }

  void _init() {
    // 不再在这里创建 HeadlessWebView，只做标记
    _initialized = true;
    Log.d('CookieSilentWebView initialized');
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    if (_disposed) return;
    _disposed = true;
    _initialized = false;
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.completeError(
        StateError('Service disposed before initialization'),
      );
    }
    _webViewController.dispose();
  }

  // ---------- 以下方法与原 CookieSilentService 完全一致 ----------
  Future<void> captureScreenshot(String url) async {
    Log.d('captureScreenshot: $_initialized');
    try {
      if (_disposed) throw StateError('Service already disposed');
      final controller = await controllerReady;
      webUri = WebUri(url);
      final currentUrl = await _webViewController.getUrl();
      if (currentUrl != null && currentUrl.path != webUri.path) {
        await controller.loadUrl(urlRequest: URLRequest(url: webUri));
        // await _submitCompleter.future.timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      Log.e('获取验证码失败: $e');
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
      final controller = await controllerReady;
      _pageLoadCompleter = Completer();
      if (code != null) {
        final submitJs =
            """
          (function() {
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
            var btnEl = document.querySelector("$submit");
            if (btnEl) {
              btnEl.click();
            }
          })();
        """;
        controller.evaluateJavascript(source: submitJs);
        await _pageLoadCompleter.future.timeout(const Duration(seconds: 5));
      }
      final currentUrl = await _webViewController.getUrl();
      final cookies = await _cookieManager.getCookies(url: currentUrl!);
      return cookies.map((c) => '${c.name}=${c.value}').join('; ');
    } catch (e) {
      Log.e('submitCaptcha: $e');
      return null;
    }
  }

  // ---------- 构建可见的 WebView ----------
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
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
              String pureBase64 = data.first.split(',').last;
              Uint8List bytes = base64.decode(pureBase64);
              _capturedCompleter.complete(bytes);
            }
            return {'status': 'success', 'received': data};
          },
        );
        if (!_controllerCompleter.isCompleted) {
          Log.d('WebView Created');
          _controllerCompleter.complete(controller);
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        // 打印网页中 console.log 的内容
        Log.i("JS Console: ${consoleMessage.message}");
      },
      shouldInterceptRequest: (controller, request) async {
        final url = request.url.toString();
        if (url.contains('/verify/')) {
          Log.d('Request: $url');
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
  }
}
