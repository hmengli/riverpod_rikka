import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:rikka/logger/logger.dart';
import 'package:rikka/utils/utils.dart';

import 'parser/parser_entity.dart';

final cookieServiceProvider = Provider.autoDispose<SilentCookieService>((ref) {
  final silentCookieService = SilentCookieService();
  silentCookieService.initWebView();
  ref.onDispose(silentCookieService.dispose);
  return silentCookieService;
});

class SilentCookieService extends Disposable {
  bool _initialized = false;
  late Completer<bool> _verifyLoadCompleter = Completer();
  late Completer<void> _pageLoadCompleter = Completer();
  late Completer<Uint8List?> _capturedCompleter = Completer();
  late WebUri webUri;
  late HeadlessInAppWebView _headlessWebView;

  final Completer<InAppWebViewController> _controllerCompleter = Completer();
  Future<InAppWebViewController> get controllerReady =>
      _controllerCompleter.future.timeout(Duration(seconds: 10));

  final _cookieManager = CookieManager.instance();

  Future<void> initWebView() async {
    if (_initialized) return;
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
                } else {
                  _capturedCompleter.complete(null);
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
            Log.i('Request:$url');
            if (!_verifyLoadCompleter.isCompleted) {
              _verifyLoadCompleter.complete(false);
            }
          }
          return null;
        },
        onLoadStop: (controller, url) {
          Log.i('onLoadStop');
          if (!_pageLoadCompleter.isCompleted) {
            _pageLoadCompleter.complete();
          }
          if (!_verifyLoadCompleter.isCompleted) {
            _verifyLoadCompleter.complete(true);
          }
        },
      );

      await _headlessWebView.run();
      _initialized = true;
      Log.i('_initialized: $_initialized');
    } catch (e) {
      _controllerCompleter.completeError(e);
      rethrow;
    }
  }

  Future<Uint8List?> captureScreenshot(String url, String img) async {
    try {
      Log.i('加载页面: $url');
      final controller = await controllerReady;
      webUri = WebUri(url);
      final currentUrl = await controller.getUrl();
      if (currentUrl != null && currentUrl.path != webUri.path) {
        _pageLoadCompleter = Completer();
        await controller.loadUrl(urlRequest: URLRequest(url: webUri));
        await _pageLoadCompleter.future.timeout(Duration(seconds: 10));
      }
      Log.i('加载成功: $url');
      return getScreenshot(img);
    } catch (e) {
      Log.e('获取验证码失败: $e');
      return null;
    }
  }

  Future<Uint8List?> getScreenshot(String img) async {
    Log.d('getScreenshot: $img');
    try {
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
      return await _capturedCompleter.future.timeout(
        Duration(seconds: 10),
        onTimeout: () => null,
      );
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
      Log.i('submitCaptcha: $code,$input,$submit');
      final controller = await controllerReady;
      _verifyLoadCompleter = Completer();
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

          const btnEl = document.querySelector("$submit");
          if (btnEl) {
            btnEl.click();
          }
          })();
        """;
        controller.evaluateJavascript(source: submitJs);
        final verifyLoad = await _verifyLoadCompleter.future.timeout(
          Duration(seconds: 5),
          onTimeout: () => false,
        );
        Log.d('verifyLoad: $verifyLoad');
        if (!verifyLoad) return null;
      }
      await Future.delayed(Duration(seconds: 3));
      return getCookieExpiry();
    } catch (e) {
      Log.e('submitCaptcha: $e');
      return null;
    }
  }

  Future<String> getCookieExpiry() async {
    final controller = await controllerReady;
    final currentUrl = await controller.getUrl();
    final cookies = await _cookieManager.getCookies(url: currentUrl!);
    return cookies.map((c) => '${c.name}=${c.value}').join('; ');
  }

  Future<String> checkCookieExpiry() async {
    final controller = await controllerReady;
    final url = await controller.getUrl();
    // 获取该 URL 下所有 Cookie
    List<Cookie> cookies = await _cookieManager.getCookies(url: url!);
    if (checkCookie(cookies)) return "";
    return cookies.map((c) => '${c.name}=${c.value}').join('; ');
  }

  bool checkCookie(List<Cookie> cookies) {
    final now = DateTime.now();
    for (var cookie in cookies) {
      Log.d('Cookie: ${cookie.name} = ${cookie.value}');
      // 检查是否过期
      if (cookie.expiresDate != null) {
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(
          cookie.expiresDate!,
        );
        return expiresAt.isBefore(now);
      }
    }
    return false;
  }

  @override
  void dispose() {
    if (!_initialized) return;
    _initialized = false;
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.completeError(
        StateError('Service disposed before initialization'),
      );
    }
    // _webViewController.dispose();
    Log.i('message: _headlessWebView正常关闭');
    _headlessWebView.dispose();
  }
}

class CaptchaService {
  static final String apiUrl = "http://192.168.2.3:8000/ocr";

  static Future<String> recognizeCaptcha(Uint8List compressedBytes) async {
    final String base64Image = base64Encode(compressedBytes);
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      // 4. 解析服务器返回的 JSON 数据
      final Map<String, dynamic> result = json.decode(response.body);
      Log.i('message: $result');
      if (result.containsKey('result')) {
        return result['result']; // 识别出的数字字符串
      } else {
        throw Exception('识别失败: ${result['message']}');
      }
    } else {
      throw Exception('HTTP 请求失败，状态码: ${response.statusCode}');
    }
  }

  // Future<Uint8List> _compressImage(File imageFile) async {
  //   // 读取原始图片
  //   final originalBytes = await imageFile.readAsBytes();
  //   final originalImage = img.decodeImage(originalBytes);

  //   if (originalImage == null) {
  //     throw Exception('无法解码图片');
  //   }

  //   // 缩放图片，将宽度限制为 500 像素，高度按比例缩放
  //   final resizedImage = img.copyResize(originalImage, width: 500);

  //   // 可选：添加灰度化等预处理步骤以提升识别准确率
  //   // final grayscaleImage = img.grayscale(resizedImage);

  //   // 以 JPEG 格式编码，质量为 85%，进一步减小体积
  //   final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
  //   return Uint8List.fromList(compressedBytes);
  // }
}

class ParserService {
  // 执行完整的三步解析
  Future<String> parseWithConfig(
    String step1Url, {
    required Map<String, String> headers,
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
        headers: headers,
      );
    } catch (e) {
      throw Exception('网络错误，请检查网络: $e');
    }
  }

  // 获取页面HTML
  Future<String> fetchPage({
    required String uri,
    required Map<String, String> headers,
    required ParserEntity parserEntity,
  }) async {
    Log.i('请求URL: $uri');
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

  List<String> extractLinks4(String html, {required String selector}) {
    final document = parser.parse(html);
    final elements = document.querySelectorAll(selector);
    return elements.map((toElement) => toElement.innerHtml).toList();
  }
}
