import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/utils/utils.dart';
import 'package:window_manager/window_manager.dart';

import 'app_router.dart';
import 'l10n/app_localizations.dart';
import 'screens/settings/theme/theme_provider.dart';
import 'logger/logger.dart';

class AppWidget extends ConsumerStatefulWidget {
  const AppWidget({super.key});

  @override
  ConsumerState<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends ConsumerState<AppWidget>
    with WidgetsBindingObserver, WindowListener {
  bool showingExitDialog = false;
  static const targetAspectRatio = 16 / 9;

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
  void onWindowResize() async {
    // 获取当前窗口尺寸
    final currentSize = await windowManager.getSize();
    final currentWidth = currentSize.width;
    final currentHeight = currentSize.height;

    // 计算目标高度（基于比例）
    final targetHeight = currentWidth / targetAspectRatio;

    if (currentHeight >= 720) {
      await windowManager.setSize(Size(currentWidth, targetHeight));
    }

    // 如果当前高度与目标高度相差大于允许的误差值，则进行调整
    // if ((currentHeight - targetHeight).abs() > 1.0) {
    //   // 设置新尺寸，使其符合精确比例
    //   await windowManager.setSize(Size(currentWidth, targetHeight));
    // }
    super.onWindowResize();
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
          // backgroundColor: Theme.of(context).canvasColor, // 背景颜色
          // selectedItemColor: Theme.of(context).primaryColor, // 选中项颜色
          // unselectedItemColor: Theme.of(context).disabledColor, // 未选中项颜色
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
          builder: (BuildContext cont, child) {
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
