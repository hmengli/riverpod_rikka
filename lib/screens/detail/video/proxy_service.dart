import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rikka/screens/parser/api_service.dart';
import 'package:rikka/utils/logger.dart';
import 'package:rikka/utils/utils.dart';

// ===================== 基础模型 & 拦截器接口 =====================

class ProxyRequest {
  final String method;
  final String url; // 远程请求的相对路径 + query
  final Map<String, String> headers;
  final List<int>? body;

  const ProxyRequest({
    required this.method,
    required this.url,
    required this.headers,
    this.body,
  });

  ProxyRequest copyWith({
    String? method,
    String? url,
    Map<String, String>? headers,
    List<int>? body,
  }) => ProxyRequest(
    method: method ?? this.method,
    url: url ?? this.url,
    headers: headers ?? this.headers,
    body: body ?? this.body,
  );
}

class ProxyResponse {
  final int statusCode;
  final Map<String, String> headers;
  final List<int>? body;

  const ProxyResponse({
    required this.statusCode,
    required this.headers,
    this.body,
  });

  ProxyResponse copyWith({
    int? statusCode,
    Map<String, String>? headers,
    List<int>? body,
  }) => ProxyResponse(
    statusCode: statusCode ?? this.statusCode,
    headers: headers ?? this.headers,
    body: body ?? this.body,
  );
}

abstract class ProxyInterceptor {
  Future<ProxyResponse?> onRequest(ProxyRequest request) async => null;

  Future<ProxyResponse> onResponse(
    ProxyResponse response,
    ProxyRequest originalRequest,
  ) async => response;
}

// ===================== 组合拦截器 =====================

class CompositeInterceptor extends ProxyInterceptor {
  final List<ProxyInterceptor> interceptors;

  CompositeInterceptor(this.interceptors);

  @override
  Future<ProxyResponse?> onRequest(ProxyRequest request) async {
    for (final interceptor in interceptors) {
      final res = await interceptor.onRequest(request);
      if (res != null) return res;
    }
    return null;
  }

  @override
  Future<ProxyResponse> onResponse(
    ProxyResponse response,
    ProxyRequest originalRequest,
  ) async {
    ProxyResponse current = response;
    for (final interceptor in interceptors) {
      current = await interceptor.onResponse(current, originalRequest);
    }
    return current;
  }
}

// ===================== 路由定义（增加地址映射） =====================

class ProxyRoute {
  /// 本地代理路径前缀，如 /proxy/
  final String localPath;

  /// 该路由对应的拦截器
  final ProxyInterceptor? interceptor;

  const ProxyRoute({required this.localPath, this.interceptor});
}

// ===================== 代理服务（单例） =====================

class ProxyService {
  static final ProxyService _instance = ProxyService._internal();
  factory ProxyService() => _instance;
  ProxyService._internal();

  HttpServer? _server;
  List<ProxyRoute> _routes = [];

  /// 文件名 → 远程基础地址的映射
  /// key: 请求路径中去除 localPath 后的部分（如 "file.html"）
  /// value: 远程基础 URL（如 "https://example.com/data"）
  static String _cachedM3U8Content = '';
  static Map<String, String> addressMap = {};

  bool get isRunning => _server != null;
  int? get port => _server?.port;
  String? get localProxyAddress {
    final p = port;
    if (p == null) return null;
    return 'http://127.0.0.1:$p';
  }

  /// 启动代理服务
  Future<String> start({required List<ProxyRoute> routes}) async {
    if (_server != null) await stop();
    _routes = routes;
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    _server!.listen(_handleRequest);
    return localProxyAddress!;
  }

  Future<void> stop() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }
  }

  /// 查找匹配的路由（按前缀最长匹配或简单 startsWith）
  ProxyRoute? _matchRoute(String path) {
    for (final route in _routes) {
      if (path.startsWith(route.localPath)) {
        return route;
      }
    }
    return null;
  }

  /// 从路径中提取文件名部分（用于查 addressMap）
  String? _extractFileNameKey(ProxyRoute route, String requestPath) {
    // 去除路由前缀，得到类似 "file.html" 的部分
    String suffix = requestPath.substring(route.localPath.length);
    // 去除开头的 '/'
    if (suffix.startsWith('/')) {
      suffix = suffix.substring(1);
    }
    // 可能还有查询参数，但路径不含 query，requestPath 是 uri.path，不含 query
    return suffix.isEmpty ? null : suffix;
  }

  Future<String> getMuUrl(String url) async {
    // 1. 预先获取并缓存 M3U8 内容
    final response = await Http().get(
      url,
      queryParams: {'User-Agent': Utils.userAgent},
    );
    if (response.statusCode == 200) {
      _cachedM3U8Content = _rewriteTsUrls(response.data);
    }
    return 'http://127.0.0.1:8080/proxy/mu/${Utils.encode(url)}.m3u8';
  }

  /// 处理播放器对 M3U8 的请求
  Future<void> _handleMuRequest(HttpRequest request) async {
    if (_cachedM3U8Content.isNotEmpty) {
      // Log.i('_handleRequest: ${request.uri}');
      request.response
        ..headers.contentType = ContentType.parse(
          'application/vnd.apple.mpegurl',
        )
        ..headers.add('Access-Control-Allow-Origin', '*')
        ..write(_cachedM3U8Content);
      await request.response.close();
    } else {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('M3U8 未加载');
      await request.response.close();
    }
  }

  String _rewriteTsUrls(String m3u8Content) {
    addressMap.clear();
    final lines = m3u8Content.split('\n');
    final newLines = <String>[];
    // 用于追踪分片索引
    int tsIndex = 0;
    for (String line in lines) {
      line = line.trim();
      // 如果是分片地址（非注释，非空）
      if (line.isNotEmpty && !line.startsWith('#')) {
        addressMap.addAll({'originalUrl$tsIndex.ts': line});
        line = 'http://127.0.0.1:8080/proxy/ts/originalUrl$tsIndex.ts';
        tsIndex++;
        // debugPrint('🔄 重写分片: ${originalUrl.substring(0, min(50, originalUrl.length))}... → $filename');
      }
      newLines.add(line);
    }
    return newLines.join('\n');
  }

  Future<void> _handleRequest(HttpRequest clientReq) async {
    final HttpResponse clientRes = clientReq.response;
    bool responseStarted = false;

    try {
      String uri = clientReq.uri.toString();

      if (uri.endsWith('.m3u8')) {
        _handleMuRequest(clientReq);
        return;
      }

      // 1. 匹配路由
      final route = _matchRoute(clientReq.uri.path);
      if (route == null) {
        clientRes.statusCode = 404;
        clientRes.write('No matching proxy route');
        await clientRes.close();
        return;
      }

      // 2. 获取文件名 key
      final fileKey = _extractFileNameKey(route, clientReq.uri.path);
      if (fileKey == null || fileKey.isEmpty) {
        clientRes.statusCode = 400;
        clientRes.write('Missing file key in path');
        await clientRes.close();
        return;
      }

      // 3. 从映射表查找远程地址
      final baseUrl = addressMap[fileKey];
      Log.i('baseUrl: $baseUrl');
      if (baseUrl == null) {
        clientRes.statusCode = 404;
        clientRes.write('No mapping found for "$fileKey"');
        await clientRes.close();
        return;
      }

      // 4. 构造完整的远程 URL（基础地址 + 客户端请求的查询参数）
      final remoteUri = Uri.parse(baseUrl).replace(
        query: clientReq.uri.query.isNotEmpty ? clientReq.uri.query : null,
      );

      // 5. 读取客户端请求体
      final List<int> bodyBytes = await clientReq.fold<List<int>>(
        <int>[],
        (prev, chunk) => prev..addAll(chunk),
      );

      ProxyRequest proxyReq = ProxyRequest(
        method: clientReq.method,
        url:
            remoteUri.path +
            (remoteUri.query.isNotEmpty ? '?${remoteUri.query}' : ''),
        headers: _copyHeaders(clientReq.headers),
        body: bodyBytes.isEmpty ? null : bodyBytes,
      );

      final interceptor = route.interceptor;

      // 6. 请求拦截
      ProxyResponse? shortCircuit;
      if (interceptor != null) {
        shortCircuit = await interceptor.onRequest(proxyReq);
      }
      if (shortCircuit != null) {
        await _writeResponse(clientRes, shortCircuit);
        return;
      }

      // 7. 转发到远程
      final HttpClient httpClient = HttpClient();
      final HttpClientRequest remoteReq = await httpClient.openUrl(
        proxyReq.method,
        remoteUri,
      );

      proxyReq.headers.forEach((name, value) {
        if (!name.toLowerCase().startsWith('host')) {
          remoteReq.headers.set(name, value);
        }
      });
      remoteReq.headers.set('User-Agent', Utils.userAgent);
      remoteReq.headers.set('Referer', 'https://player.ezdmw.com');
      if (proxyReq.body != null && proxyReq.body!.isNotEmpty) {
        remoteReq.add(proxyReq.body!);
      }

      final HttpClientResponse remoteRes = await remoteReq.close();
      final List<int> remoteBody = await remoteRes.fold<List<int>>(
        <int>[],
        (prev, chunk) => prev..addAll(chunk),
      );

      ProxyResponse proxyRes = ProxyResponse(
        statusCode: remoteRes.statusCode,
        headers: _copyHeaders(remoteRes.headers),
        body: remoteBody,
      );

      // 8. 响应拦截
      if (interceptor != null) {
        proxyRes = await interceptor.onResponse(proxyRes, proxyReq);
      }

      responseStarted = true;
      await _writeResponse(clientRes, proxyRes);
      httpClient.close();
    } catch (e) {
      Log.e('Proxy error: $e');
      if (!responseStarted) {
        try {
          clientRes.statusCode = HttpStatus.badGateway;
          clientRes.write('Proxy Error: $e');
          await clientRes.close();
        } catch (_) {}
      }
    }
  }

  Future<void> _writeResponse(
    HttpResponse clientRes,
    ProxyResponse proxyRes,
  ) async {
    clientRes.statusCode = proxyRes.statusCode;
    proxyRes.headers.forEach((name, value) {
      try {
        clientRes.headers.set(name, value);
      } catch (_) {}
    });
    if (proxyRes.body != null) {
      clientRes.add(proxyRes.body!);
    }
    await clientRes.close();
  }

  Map<String, String> _copyHeaders(HttpHeaders headers) {
    final map = <String, String>{};
    headers.forEach((name, values) {
      map[name] = values.join(', ');
    });
    return map;
  }
}

// ---------- 定义具体的拦截器 ----------

class LogInterceptor extends ProxyInterceptor {
  @override
  Future<ProxyResponse> onResponse(
    ProxyResponse response,
    ProxyRequest originalRequest,
  ) async {
    Log.d('statusCode: ${response.statusCode}');
    return response;
  }
}

class MuInterceptor extends ProxyInterceptor {
  @override
  Future<ProxyResponse> onResponse(
    ProxyResponse response,
    ProxyRequest originalRequest,
  ) async {
    if (response.body != null) {
      String bodyStr = utf8.decode(response.body!);
      return response.copyWith(body: utf8.encode(bodyStr));
    }
    return response;
  }
}

class TsInterceptor extends ProxyInterceptor {
  @override
  Future<ProxyResponse> onResponse(
    ProxyResponse response,
    ProxyRequest originalRequest,
  ) async {
    if (response.body != null) {
      List<int>? data = response.body;
      if (data!.length > 3 &&
          data[0] == 0x89 &&
          data[1] == 0x50 &&
          data[2] == 0x4E) {
        Log.d('🔧 已去除伪装头:');
        data = data.sublist(3);
      }
      return response.copyWith(body: data);
    }
    return response;
  }
}

class CacheInterceptor extends ProxyInterceptor {
  final Map<String, ProxyResponse> _cache = {};

  @override
  Future<ProxyResponse?> onRequest(ProxyRequest request) async {
    if (request.method == 'GET' && _cache.containsKey(request.url)) {
      final cached = _cache[request.url]!;
      return cached.copyWith(headers: {...cached.headers, 'X-Cache': 'HIT'});
    }
    return null;
  }

  @override
  Future<ProxyResponse> onResponse(
    ProxyResponse response,
    ProxyRequest originalRequest,
  ) async {
    if (originalRequest.method == 'GET' && response.statusCode == 200) {
      _cache[originalRequest.url] = response;
    }
    return response;
  }
}
