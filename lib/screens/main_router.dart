import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rikka/l10n/app_localizations.dart';
import 'package:transit_kit/transit_kit.dart';

import 'home/home_page.dart';
import 'login_screen.dart';
import 'schedule/schedule_page.dart';
import 'settings/settings_page.dart';

part 'main_router.g.dart';

@TypedGoRoute<LoginRoute>(path: '/')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => LoginScreen();
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

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute(); // 无参构造

  @override
  Widget build(_, _) => const HomePage();
}

class ScheduleRoute extends GoRouteData with $ScheduleRoute {
  const ScheduleRoute();

  @override
  Widget build(_, _) => const SchedulePage();
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(_, _) => const SettingsPage();
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
      appBar: AppBar(title: Text('RIKKA')),
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
