import 'package:freezed_annotation/freezed_annotation.dart';

part 'proxy_entity.freezed.dart';

// ===================== 基础模型 & 拦截器接口 =====================
@freezed
abstract class ProxyRequest with _$ProxyRequest {
  const factory ProxyRequest({
    required String method,
    required String url,
    required Map<String, String> headers,
    List<int>? body,
  }) = _ProxyRequest;
}

@freezed
abstract class ProxyResponse with _$ProxyResponse {
  const factory ProxyResponse({
    required int statusCode,
    required Map<String, String> headers,
    List<int>? body,
  }) = _ProxyResponse;
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
@freezed
abstract class ProxyRoute with _$ProxyRoute {
  const factory ProxyRoute({
    /// 本地代理路径前缀，如 /proxy/
    required String localPath,

    /// 该路由对应的拦截器
    ProxyInterceptor? interceptor,
  }) = _ProxyRoute;
}
