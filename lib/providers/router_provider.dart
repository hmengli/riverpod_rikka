// lib/providers/router_provider.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rikka/screens/comics_entity.dart';
import 'package:rikka/screens/detail/detail_page.dart';
// import 'package:rikka/screens/comics_entity.dart';
import 'package:rikka/screens/home_page.dart';
import 'package:rikka/screens/login_screen.dart';
import 'package:rikka/screens/parser/parser_entity.dart';
import 'package:rikka/screens/parser/parser_page.dart';
import 'package:rikka/screens/schedule_page.dart';
import 'package:rikka/screens/settings_page.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:transit_kit/transit_kit.dart';
import 'auth_provider.dart';
part 'router_provider.g.dart';

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
    // 路由守卫的核心逻辑
    redirect: (context, state) {
      // 使用 ref.read 单次获取状态，避免重建
      final authState = ref.read(authProvider);

      // 正在加载，留在加载页
      if (authState.isLoading) return '/splash';

      final isLoggedIn = authState.value != null;
      final isSplashPage = state.matchedLocation == '/splash';
      final isLoginPage = state.matchedLocation == '/login';

      // 已登录，但当前在登录页或加载页 -> 跳转到主页
      if (isLoggedIn && (isLoginPage || isSplashPage)) return '/home';

      // 未登录，且当前页面不是登录页 -> 跳转到登录页
      if (!isLoggedIn && !isLoginPage) return '/login';

      // 无需重定向
      return null;
    },
    routes: $appRoutes,
  );

  return router;
}

@TypedGoRoute<LoginRoute>(path: '/login')
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
      DetailPage(entity: $extra!);
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
      routes: [
        TypedGoRoute<SettingsRoute>(
          path: '/settings',
          routes: [TypedGoRoute<ParserRoute>(path: '/parser')],
        ),
      ],
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

class ParserRoute extends GoRouteData with $ParserRoute {
  const ParserRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ParserPage(videoType: VideoType.comics);
}

// ============= 2. 带底部导航栏的 Scaffold（必须在使用前定义） =============
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: '时间表'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
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
