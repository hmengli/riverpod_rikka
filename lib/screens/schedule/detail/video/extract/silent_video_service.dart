import 'dart:async';
import 'dart:collection';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/logger/logger.dart';

import 'extract_entity.dart';

final videoServiceProvider = Provider.autoDispose<SilentVideoService>((ref) {
  final silentVideoService = SilentVideoService();
  silentVideoService._initWebView();
  ref.onDispose(silentVideoService.dispose);
  return silentVideoService;
});

/// 全局单例的视频提取器
/// - 内部维护一个 WebView 实例，复用而不是每次都新建销毁
/// - 任务队列串行执行，避免并发冲突
class SilentVideoService implements Disposable {
  HeadlessInAppWebView? _headlessWebView;
  bool _isInitialized = false;
  bool _isDisposed = false;

  final Completer<InAppWebViewController> _controllerCompleter = Completer();
  Future<InAppWebViewController> get controllerReady =>
      _controllerCompleter.future.timeout(Duration(seconds: 10));

  // 任务队列
  final Queue<ExtractTask> _taskQueue = Queue();
  bool _isProcessing = false;

  // 当前活动任务
  ExtractTask? _currentTask;

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
      onWebViewCreated: (controller) {
        if (!_controllerCompleter.isCompleted) {
          Log.d('Created');
          _controllerCompleter.complete(controller);
        }
      },
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
          _onUrlFound(url, Extension.mp4);
        } else if (_currentTask!.selectorUm.isNotEmpty &&
            url.contains(_currentTask!.selectorUm)) {
          Log.i('🎯 [Extractor] 匹配到m3u8视频: $url');
          _onUrlFound(url, Extension.m3u8);
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

  void _onUrlFound(String url, Extension type) {
    if (_currentTask != null && !_currentTask!.completer.isCompleted) {
      _currentTask!.completer.complete(ExtractEntity(type: type, url: url));
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
  Extension _determineType(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.m3u8') ||
        lower.contains('listres') ||
        lower.contains('.m3u8?')) {
      return Extension.m3u8;
    }
    return Extension.mp4;
  }

  /// 添加提取任务
  Future<ExtractEntity?> extract(
    String pageUrl, {
    required String selectorMp,
    required String selectorUm,
  }) async {
    if (_isDisposed) {
      Log.d('⚠️ 全局提取器已释放，无法执行新任务');
      return null;
    }

    final completer = Completer<ExtractEntity?>();

    final task = ExtractTask(
      selectorMp: selectorMp,
      selectorUm: selectorUm,
      pageUrl: pageUrl,
      completer: completer,
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
  Future<void> _runTask(ExtractTask task) async {
    final completer = task.completer;
    final pageUrl = task.pageUrl;

    Log.i('🔇 [单例] 开始提取: $pageUrl');
    try {
      final controller = await controllerReady;
      await controller.loadUrl(urlRequest: URLRequest(url: WebUri(pageUrl)));

      // 等待结果，超时 30 秒
      await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          Log.i('⏰ [单例] 提取超时，返回已找到的结果（如果有）');
          return null;
        },
      );

      await controller.stopLoading();
      Log.i('🏁 [单例] 任务完成，WebView 暂留待用');
    } catch (e) {
      Log.i('🔥 [单例] 提取异常: $e');
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }
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
