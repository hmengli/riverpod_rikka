// app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'routes.g.dart';
import 'screens/auth_provider.dart';

part 'app_router.g.dart';

// 1. 创建负责监听认证状态并通知 GoRouter 的 Listenable 类
class AuthStateListenable extends ChangeNotifier {
  final Ref ref;
  AuthStateListenable(this.ref) {
    // 监听认证 Provider 的状态变化
    ref.listen(authProvider, (previous, next) {
      // 当状态变化时，通知 GoRouter 重新执行 redirect
      notifyListeners();
    });
  }
}

// 2. 提供一个可以获取 AuthStateListenable 实例的 Provider
@riverpod
AuthStateListenable authStateListenable(Ref ref) {
  return AuthStateListenable(ref);
}

// 3. 核心：使用 @riverpod 创建 GoRouter 实例
@riverpod
GoRouter goRouter(Ref ref) {
  // 获取认证状态监听器
  final authStateListenable = ref.watch(authStateListenableProvider);

  // 获取路由定义，稍后会创建
  final router = GoRouter(
    // 绑定监听器，当监听器触发 notifyListeners 时，GoRouter 会重新评估 redirect
    refreshListenable: authStateListenable,
    // 初始页面，可以是一个加载页
    initialLocation: '/splash',
    observers: [LoggingNavigatorObserver()],
    // 路由守卫的核心逻辑
    redirect: (context, state) {
      Log.d('Redirect: ${state.uri.path}'); // 看看实际路径
      // 使用 ref.read 单次获取状态，避免重建
      final authState = ref.read(authProvider);

      // 正在加载，留在加载页
      if (authState.isLoading) return '/splash';

      final isLoggedIn = authState.value != null;
      final isSplashPage = state.matchedLocation == '/splash';
      final isLoginPage = state.matchedLocation == '/';

      // 已登录，但当前在登录页或加载页 -> 跳转到主页
      if (isLoggedIn && (isLoginPage || isSplashPage)) return '/home';

      // 未登录，且当前页面不是登录页 -> 跳转到登录页
      if (!isLoggedIn && !isLoginPage) return '/';

      // 无需重定向
      return null;
    },

    routes: $aggregatedRoutes,
  );

  return router;
}

class LoggingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(route, 'push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(route, 'pop');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _log(newRoute, 'replace');
  }

  void _log(Route<dynamic> route, String action) {
    // 获取当前路由的完整路径（仅适用于 GoRouterState 等）
    final settings = route.settings;
    Log.d('🔗 Route $action: ${settings.name ?? settings.arguments}');
    // 如果使用 GoRouter，可以强制转换获取更多信息
    if (route is GoRoute) {
      // 也可以拿到当前 location
      Log.d('Location: ${route.isActive}');
    }
  }
}
