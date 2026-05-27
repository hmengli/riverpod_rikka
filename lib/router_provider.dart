// lib/providers/router_provider.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rikka/l10n/app_localizations.dart';
import 'package:rikka/screens/schedule/comics_entity.dart';
import 'package:rikka/screens/schedule/detail/detail_page.dart';
import 'package:rikka/screens/home/home_page.dart';
import 'package:rikka/screens/login_screen.dart';
import 'package:rikka/screens/settings/parser/parser_entity.dart';
import 'package:rikka/screens/settings/parser/parser_view_page.dart';
import 'package:rikka/screens/schedule/detail/video/playlist_page.dart';
import 'package:rikka/screens/schedule/schedule_page.dart';
import 'package:rikka/screens/settings/parser/tests/parser_test_page.dart';
import 'package:rikka/screens/settings/parser/parser_upsert_page.dart';
import 'package:rikka/screens/settings/settings_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:transit_kit/transit_kit.dart';
import 'screens/auth_provider.dart';
part 'router_provider.g.dart';

// 1. 创建负责监听认证状态并通知 GoRouter 的 Listenable 类
class AuthStateListenable extends ChangeNotifier {
  final Ref ref;
  AuthStateListenable(this.ref) {
    // 监听认证 Provider 的状态变化
    ref.listen(authProvider, (previous, next) {
      print('listen: $previous -> $next');
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
      print('Redirect: ${state.uri.path}'); // 看看实际路径
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
    routes: $appRoutes,
  );

  return router;
}

@TypedGoRoute<LoginRoute>(path: '/')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => LoginScreen();
}

@TypedGoRoute<DetailsRoute>(path: '/details')
class DetailsRoute extends GoRouteData with $DetailsRoute {
  const DetailsRoute({this.$extra});
  final ComicsEntity? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DetailPage(comics: $extra!);
}

@TypedGoRoute<VideoPlayerRoute>(path: '/videoplayer')
class VideoPlayerRoute extends GoRouteData with $VideoPlayerRoute {
  const VideoPlayerRoute({this.$extra});
  final DetailEntity? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      VideoPlayerPage(detail: $extra!);
}

// 2. 定义分支数据 (Tab)
class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'home_branch');
}

class ScheduleBranch extends StatefulShellBranchData {
  const ScheduleBranch();
  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'schedule_branch');
}

class SettingsBranch extends StatefulShellBranchData {
  const SettingsBranch();
  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'settings_branch');
}

// 3. 定义壳路由 (底部导航)
@TypedStatefulShellRoute<MainShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [TypedGoRoute<HomeRoute>(path: '/home')],
    ),
    TypedStatefulShellBranch<ScheduleBranch>(
      routes: [TypedGoRoute<ScheduleRoute>(path: '/schedule')],
    ),
    TypedStatefulShellBranch<SettingsBranch>(
      routes: [TypedGoRoute<SettingsRoute>(path: '/settings')],
    ),
  ],
)
class MainShellRoute extends StatefulShellRouteData {
  const MainShellRoute();

  // 壳路由自身的根 Navigator Key，可选
  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'main_shell');

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    // 将 navigationShell 传递给之前定义的布局组件
    return ScaffoldWithNavBar(navigationShell: navigationShell);
  }
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute(); // 无参构造

  @override
  Widget build(BuildContext context, GoRouterState state) => HomePage();
}

class ScheduleRoute extends GoRouteData with $ScheduleRoute {
  const ScheduleRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SchedulePage();
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SettingsPage();
}

@TypedGoRoute<ParserRoute>(
  path: '/parser/:videoType',
  routes: [
    TypedGoRoute<ParserUpsertRoute>(path: 'upsert'),
    TypedGoRoute<ParserTestRoute>(path: 'tests'),
  ],
)
class ParserRoute extends GoRouteData with $ParserRoute {
  const ParserRoute({required this.videoType});
  final VideoType videoType;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ParserPage(videoType: videoType);
}

class ParserUpsertRoute extends GoRouteData with $ParserUpsertRoute {
  const ParserUpsertRoute({this.$extra, required this.videoType});
  final VideoType videoType;
  final ParserEntity? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ParserUpsertPage(model: $extra, videoType: videoType);
}

class ParserTestRoute extends GoRouteData with $ParserTestRoute {
  const ParserTestRoute({required this.videoType, this.$extra});
  final VideoType videoType;
  final ParserEntity? $extra;
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ParserTestPage(entity: $extra);
  }
}

// ============= 2. 带底部导航栏的 Scaffold（必须在使用前定义） =============
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    String home = AppLocalizations.of(context)!.home;
    String schedule = AppLocalizations.of(context)!.schedule;
    // String favorite = AppLocalizations.of(context)!.favorite;
    String settings = AppLocalizations.of(context)!.settings;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            activeIcon: const Icon(Icons.home_outlined),
            label: home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.schedule),
            activeIcon: const Icon(Icons.schedule_outlined),
            label: schedule,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            activeIcon: const Icon(Icons.settings_outlined),
            label: settings,
          ),
        ],
      ),
    );
  }
}

// 1. 定义你喜欢的动画类型列表
final List<TransitType> interestingTransitions = [
  TransitType.fadeScale, // 淡入淡出 + 缩放
  TransitType.slideUp, // 向上滑动
  TransitType.zoomIn, // 缩放进入
  TransitType.cupertino, // iOS 风格滑动
  TransitType.elastic, // 弹性进入
  TransitType.glitchFade, // 故障艺术效果
  // ... 在这里添加更多你喜欢的动画
];

// 2. 创建一个工具函数，随机返回一个动画类型
TransitType getRandomTransition() {
  final random = Random();
  return interestingTransitions[random.nextInt(interestingTransitions.length)];
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
    print('🔗 Route $action: ${settings.name ?? settings.arguments}');
    // 如果使用 GoRouter，可以强制转换获取更多信息
    if (route is GoRoute) {
      // 也可以拿到当前 location
      print('   Location: ${route}');
    }
  }
}
