// lib/services/http.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:rikka/utils/logger.dart';

class Http {
  static final Http _instance = Http._internal();
  factory Http() => _instance;
  Http._internal();

  // 缓存: baseUrl -> Dio 实例
  final Map<String, Dio> _dioCache = {};

  /// 获取或创建指定 baseUrl 的 Dio 实例
  Dio _getDioForUrl(
    String baseUrl,
    // , {Map<String, dynamic>? defaultOptions }
  ) {
    if (_dioCache.containsKey(baseUrl)) {
      return _dioCache[baseUrl]!;
    }

    // 创建新的 Dio 实例
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 可选：针对开发环境允许自签名证书
    if (kDebugMode) {
      final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    // 添加通用拦截器（日志、Token 等）
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Log.i('📤 [${options.baseUrl}] ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Log.i(
            '📥 [${response.requestOptions.baseUrl}] ${response.statusCode}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          Log.i('❌ [${error.requestOptions.baseUrl}] ${error.message}');
          return handler.next(error);
        },
      ),
    );

    _dioCache[baseUrl] = dio;
    return dio;
  }

  /// 从 URL 中提取 baseUrl
  String _extractBaseUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}${uri.port == 80 || uri.port == 443 ? '' : ':${uri.port}'}';
    } catch (e) {
      throw FormatException('Invalid URL: $url');
    }
  }

  /// 通用请求方法
  Future<Response> request(
    String url, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final baseUrl = _extractBaseUrl(url);
    final dio = _getDioForUrl(baseUrl);

    // 提取相对路径（去掉 baseUrl 部分）
    String path = url;
    if (url.startsWith(baseUrl)) {
      path = url.substring(baseUrl.length);
      if (path.isEmpty) path = '/';
    }

    try {
      return await dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options?.copyWith(method: method) ?? Options(method: method),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw Exception('Request failed: ${e.message}');
    }
  }

  // 便捷方法
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) {
    return request(
      url,
      method: 'GET',
      queryParameters: queryParams,
      options: options,
    );
  }

  Future<Response> post(
    String url, {
    dynamic body,
    Map<String, dynamic>? headers,
    Options? options,
  }) {
    return request(
      url,
      method: 'POST',
      data: body,
      queryParameters: headers,
      options: options,
    );
  }

  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) {
    return request(
      url,
      method: 'PUT',
      data: data,
      queryParameters: queryParams,
      options: options,
    );
  }

  Future<Response> delete(
    String url, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) {
    return request(
      url,
      method: 'DELETE',
      queryParameters: queryParams,
      options: options,
    );
  }

  /// 可选：手动清除某个 baseUrl 的缓存（例如证书更新后）
  void clearCache(String baseUrl) {
    final dio = _dioCache.remove(baseUrl);
    dio?.close();
  }

  /// 清除所有缓存（应用退出时调用）
  void clearAllCache() {
    for (var dio in _dioCache.values) {
      dio.close();
    }
    _dioCache.clear();
  }
}
