import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/utils/utils.dart';
import 'package:window_manager/window_manager.dart';

import 'router_provider.dart';
import 'l10n/app_localizations.dart';
import 'theme_provider.dart';
import 'utils/logger.dart';

class AppWidget extends ConsumerStatefulWidget {
  const AppWidget({super.key});

  @override
  ConsumerState<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends ConsumerState<AppWidget>
    with WidgetsBindingObserver, WindowListener {
  bool showingExitDialog = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // 弹出自定义对话框
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('确认退出'),
        content: Text('确定要关闭应用吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('取消'),
          ),
          TextButton(onPressed: () => exit(0), child: Text('退出')),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        Log.d('应用进入后台，立刻保存重要数据');
        break;
      case AppLifecycleState.resumed:
        // Log.d('应用回到前台');
        break;
      case AppLifecycleState.inactive:
        // Log.d('应用失去焦点');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    ElevatedButtonThemeData elevatedButtonThemeData = ElevatedButtonThemeData(
      style: ButtonStyle(
        // backgroundColor: WidgetStateProperty.all(Colors.teal),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        minimumSize: WidgetStateProperty.all(const Size(120, 48)),
      ),
    );
    BottomNavigationBarThemeData bottomNavigationBarThemeData =
        BottomNavigationBarThemeData(
          backgroundColor: Theme.of(context).canvasColor, // 背景颜色
          selectedItemColor: Theme.of(context).primaryColor, // 选中项颜色
          unselectedItemColor: Theme.of(context).disabledColor, // 未选中项颜色
          showSelectedLabels: true, // 是否显示选中项标签
          showUnselectedLabels: true, // 是否显示未选中项标签
          enableFeedback: true,
          // 更多定制...
        );
    // 获取 GoRouter 实例
    final router = ref.watch(goRouterProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          // title: 'Flutter Modular Demo',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          //动态主题
          theme: ThemeData(
            useMaterial3: true,
            elevatedButtonTheme: elevatedButtonThemeData,
            bottomNavigationBarTheme: bottomNavigationBarThemeData,
            colorScheme: lightDynamic,
            brightness: Brightness.light,
            // ... 其他样式
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            elevatedButtonTheme: elevatedButtonThemeData,
            bottomNavigationBarTheme: bottomNavigationBarThemeData,
            colorScheme: darkDynamic,
            brightness: Brightness.dark,
          ),
          themeMode: themeMode,
          routerConfig: router,
          builder: (context, child) {
            if (Utils.isDesktop()) {
              return DragToMoveArea(child: child!);
            }
            return GestureDetector(child: child!);
          },
        );
      },
    );
  }
}
