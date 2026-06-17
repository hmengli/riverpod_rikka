// app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rikka/screens/login_screen.dart';
import 'package:rikka/screens/schedule/detail/video/playlist_page.dart';
import 'package:rikka/logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_router.dart' as app_router;
import 'screens/auth_provider.dart';

import 'screens/main_router.dart' as main_router;
import 'screens/schedule/detail/detail_entity.dart';
import 'screens/schedule/schedule_router.dart' as schedule_router;
import 'screens/settings/settings_route.dart' as settings_route;

part 'app_router.g.dart';

// 1. 定义 Navigator Keys
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeShellNavigatorKey =
    GlobalKey<NavigatorState>();

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
    navigatorKey: _rootNavigatorKey,
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
    onException: (_, GoRouterState state, GoRouter router) {
      router.go('/404', extra: state.uri.toString());
    },

    routes: [
      // ========== 内部导航 (带共享标题的 Shell) ==========
      shellRoutes,
      // ========== 外部部导航 (全屏) ==========
      ...app_router.$appRoutes,
    ],
  );

  return router;
}

final shellRoutes = ShellRoute(
  navigatorKey: _homeShellNavigatorKey, // 独立的子 Navigator
  builder: (context, state, child) {
    Log.i('uri: ${state.uri}');
    return TitleScreen(
      title: state.uri.toString().substring(1),
      context: _rootNavigatorKey.currentContext!,
      child: child,
    );
  },
  routes: [
    ...main_router.$appRoutes,
    ...schedule_router.$appRoutes,
    ...settings_route.$appRoutes,
  ],
);

@TypedGoRoute<VideoPlayerRoute>(path: '/videoplayer')
class VideoPlayerRoute extends GoRouteData with $VideoPlayerRoute {
  const VideoPlayerRoute({this.$extra});
  final DetailEntity? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      VideoPlayerPage(detail: $extra!);
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
