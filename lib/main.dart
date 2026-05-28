// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:rikka/app_widget.dart';
import 'package:rikka/screens/settings/parser/parser_entity.dart';
import 'package:rikka/utils/logger.dart';
import 'package:rikka/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

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
      level: LogLevel.info, // 显示 debug 及以上
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
  await Hive.openBox<ParserEntity>('comicsBox');
  await Hive.openBox<ParserEntity>('movieBox');

  /*
   * GetStorage  本地键值对初始化
   */
  await GetStorage.init();
  final box = GetStorage();
  String? url = box.read('supabaseUrl');
  String? anonKey = box.read('supabaseAnonKey');

  /*
   * Supabase  云数据库初始化
   */
  if (url == null || anonKey == null) {
    url = 'https://iyausllaoabjijotcqsl.supabase.co';
    anonKey = 'sb_publishable_-77deP0oUUadeA7_77Dw3A_MOA_rdDl';
  }
  await Supabase.initialize(url: url, anonKey: anonKey);

  runApp(const ProviderScope(child: AppWidget()));
  // runApp(MaterialApp(home: MyCaptchaPage()));
}
