import 'dart:async';
import 'dart:collection';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/utils/logger.dart';

final videoServiceProvider = Provider.autoDispose<SilentVideoService>((ref) {
  final silentVideoService = SilentVideoService();
  if (ref.mounted) {
    ref.onDispose(silentVideoService.dispose);
  }
  return silentVideoService;
});

class Extractor {
  static const String mp4 = 'mp4';
  static const String m3u8 = 'm3u8';
  final String type;
  final String url;

  Extractor({required this.type, required this.url});
  @override
  String toString() => 'Extractor($type, $url)';
}

/// 全局单例的视频提取器
/// - 内部维护一个 WebView 实例，复用而不是每次都新建销毁
/// - 任务队列串行执行，避免并发冲突
class SilentVideoService implements Disposable {
  HeadlessInAppWebView? _headlessWebView;
  bool _isInitialized = false;
  bool _isDisposed = false;

  // 任务队列
  final Queue<_ExtractTask> _taskQueue = Queue();
  bool _isProcessing = false;

  // 当前活动任务
  _ExtractTask? _currentTask;

  // 初始化 WebView（只做一次）
  Future<void> _initWebView() async {
    if (_isInitialized) return;
    // if (_isDisposed) throw Exception('VideoSilentExtractor 已释放');

    _headlessWebView = HeadlessInAppWebView(
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        useShouldInterceptRequest: true,
        cacheEnabled: false,
        supportZoom: false,
        mediaPlaybackRequiresUserGesture: false,
      ),
      onReceivedError: (controller, request, error) {
        // 全局错误处理，交给当前任务
        if (_currentTask != null && !_currentTask!.completer.isCompleted) {
          Log.e('❌ 全局 WebView 错误: ${error.description}');
          _currentTask!.completer.completeError(
            ExtractException('加载错误: ${error.description}'),
          );
          _finishCurrentTask();
        }
      },
      shouldInterceptRequest: (controller, request) async {
        if (_currentTask == null) return null;
        final url = request.url.toString();
        if (url.endsWith('.js') ||
            url.contains('.js?') ||
            url.endsWith('.gif') ||
            url.endsWith('.png') ||
            url.endsWith('.html') ||
            url.endsWith('.jpg') ||
            url.contains('.css?') ||
            url.endsWith('.css')) {
          return null;
        }
        Log.i('url: $url');

        // 匹配 selector
        if (_currentTask!.selectorMp.isNotEmpty &&
            url.contains(_currentTask!.selectorMp)) {
          Log.i('🎯 [Extractor] 匹配到mp4视频: $url');
          _onUrlFound(url, Extractor.mp4);
        } else if (_currentTask!.selectorUm.isNotEmpty &&
            url.contains(_currentTask!.selectorUm)) {
          Log.i('🎯 [Extractor] 匹配到m3u8视频: $url');
          _onUrlFound(url, Extractor.m3u8);
        } else if (_isVideoRequest(url)) {
          Log.i('🎯 [Extractor] 检索到视频: $url');
          _onUrlFound(url, _determineType(url));
        }
        return null;
      },
    );

    // 预启动 WebView（但先不加载任何页面）
    await _headlessWebView!.run();
    _isInitialized = true;
    Log.d('✅ 全局 WebView 已初始化');
  }

  void _onUrlFound(String url, String type) {
    if (_currentTask != null &&
        _currentTask!.result == null &&
        !_currentTask!.completer.isCompleted) {
      _currentTask!.result = Extractor(type: type, url: url);
      _currentTask!.completer.complete(_currentTask!.result);
      // 注意：不要在这里 _finishCurrentTask，因为页面可能还需要继续加载（但我们已经找到结果，可以完成）
      // 实际上我们找到结果后就可以结束任务，但 WebView 可能还会触发其他请求，不过没关系，我们已标记完成
    }
  }

  /// 判断是否为视频请求
  bool _isVideoRequest(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.m3u8') ||
        //   lower.contains('.ts') ||
        lower.contains('.m4s') ||
        lower.contains('.mp4') ||
        // lower.contains('video') ||
        // lower.contains('stream') ||
        // lower.contains('next=') ||
        lower.contains('listres');
  }

  /// 根据 URL 后缀或特征判断类型
  String _determineType(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.m3u8') ||
        lower.contains('listres') ||
        lower.contains('.m3u8?')) {
      return Extractor.m3u8;
    }
    return Extractor.mp4;
  }

  /// 添加提取任务
  Future<Extractor?> extract(
    String pageUrl, {
    required String selectorMp,
    required String selectorUm,
  }) async {
    if (_isDisposed) {
      Log.d('⚠️ 全局提取器已释放，无法执行新任务');
      return null;
    }

    // 确保 WebView 已初始化
    await _initWebView();

    final completer = Completer<Extractor?>();
    final task = _ExtractTask(
      pageUrl,
      completer,
      selectorMp: selectorMp,
      selectorUm: selectorUm,
    );
    _taskQueue.add(task);

    _processQueue();
    return completer.future;
  }

  /// 处理队列
  Future<void> _processQueue() async {
    if (_isProcessing || _taskQueue.isEmpty) return;
    _isProcessing = true;

    while (_taskQueue.isNotEmpty) {
      _currentTask = _taskQueue.removeFirst();
      await _runTask(_currentTask!);
      _currentTask = null;
    }

    _isProcessing = false;
  }

  /// 执行单个任务
  Future<void> _runTask(_ExtractTask task) async {
    final completer = task.completer;
    final pageUrl = task.pageUrl;
    // final selector = task.selector;

    Log.i('🔇 [单例] 开始提取: $pageUrl');
    try {
      // 加载页面
      await _headlessWebView?.webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(pageUrl)),
      );

      // 等待结果，超时 30 秒
      final result = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          Log.i('⏰ [单例] 提取超时，返回已找到的结果（如果有）');
          return task.result; // 已有结果则返回，否则 null
        },
      );
      task.result = result;
      Log.i('🏁 [单例] 任务完成，${task.result}');
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    } catch (e) {
      Log.i('🔥 [单例] 提取异常: $e');
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }
    // 任务结束后，停止加载，清空页面
    await _headlessWebView?.webViewController?.stopLoading();
    Log.i('🏁 [单例] 任务完成，WebView 暂留待用');
  }

  void _finishCurrentTask() {
    // 辅助方法，实际在 _runTask 的 catch 或完成时已处理
  }

  /// 释放全局资源（在应用退出时调用）
  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    // 取消所有等待中的任务
    while (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeFirst();
      if (!task.completer.isCompleted) {
        task.completer.completeError(DisposedException('提取器已释放'));
      }
    }
    if (_currentTask != null && !_currentTask!.completer.isCompleted) {
      _currentTask!.completer.completeError(DisposedException('提取器已释放'));
    }

    await _headlessWebView?.dispose();
    _headlessWebView = null;
    _isInitialized = false;
    Log.i('🧹 全局提取器已释放');
  }
}

class _ExtractTask {
  final String pageUrl;
  final String selectorMp;
  final String selectorUm;
  final Completer<Extractor?> completer;
  Extractor? result;

  _ExtractTask(
    this.pageUrl,
    this.completer, {
    required this.selectorMp,
    required this.selectorUm,
  });
}

class ExtractException implements Exception {
  final String message;
  ExtractException(this.message);
  @override
  String toString() => 'ExtractException: $message';
}

class DisposedException implements Exception {
  final String message;
  DisposedException(this.message);
  @override
  String toString() => 'DisposedException: $message';
}
