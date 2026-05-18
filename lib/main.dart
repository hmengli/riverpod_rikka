// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rikka/screens/parser/parser_entity.dart';
import 'package:rikka/utils/logger.dart';
import 'package:rikka/utils/utils.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/router_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MediaKit.ensureInitialized();

  try {
    final version = await WebViewEnvironment.getAvailableVersion();
    if (version != null) {
      print('✅ WebView2 运行时已安装，版本: $version');
    } else {
      print('❌ WebView2 运行时未安装！');
    }
  } catch (e) {
    print('❌ 检查失败: $e');
  }

  /*
   * 桌面程序窗口
   */
  if (Utils.isDesktop()) {
    await windowManager.ensureInitialized();
    // await windowManager.setPreventClose(true);
    // 设置窗口初始大小等（可选）
    WindowOptions windowOptions = WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(384, 216),
      center: true,
      // windowButtonVisibility: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /*
   * Log  日志
   */
  await Log.init(
    LogConfig(
      level: LogLevel.debug, // 显示 debug 及以上
      enableConsole: true, // 输出到控制台
      enableFile: true, // 同时写入文件
      maxFileCount: 5, // 最多保留 5 个日志文件
      fileMaxAge: Duration(days: 3), // 超过 3 天的日志自动删除
      isRelease: kReleaseMode, // 根据模式自动调整颜色
    ),
  );
  // 或者简单初始化（开发用）
  // await Log.initDefault();

  /*
   * Hive  本地数据库初始化
   */
  await Hive.initFlutter();
  Hive.registerAdapter(ParserEntityAdapter()); // 注册适配器
  await Hive.openBox<ParserEntity>('configsBox');

  runApp(const ProviderScope(child: AppWidget()));
}

class AppWidget extends ConsumerWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取 GoRouter 实例
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: router,
      builder: (context, child) {
        if (Utils.isDesktop()) {
          return DragToMoveArea(child: child!);
        }
        return GestureDetector(child: child!);
      },
    );
  }
}
