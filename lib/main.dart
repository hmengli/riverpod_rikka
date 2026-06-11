// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rikka/app_widget.dart';
import 'package:rikka/hive/hive_registrar.g.dart';
import 'package:rikka/screens/schedule/parserapi/parser_api_entity.dart';
import 'package:rikka/utils/logger.dart';
import 'package:rikka/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/schedule/detail/parser/parser_entity.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
   * Hive  本地数据库初始化
   */
  // 1. 初始化 Hive 存储目录
  // await Hive.initFlutter();
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  Hive.registerAdapters();
  Hive.openBox<ParserEntity>(VideoType.comics.name);
  Hive.openBox<ParserEntity>(VideoType.movie.name);
  Hive.openBox<ParserApiEntity>(ApiType.comicsApi.name);
  Hive.openBox<ParserApiEntity>(ApiType.movieApi.name);

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
      level: LogLevel.info,
      // 显示 debug 及以上
      enableConsole: true,
      // 输出到控制台
      enableFile: true,
      // 同时写入文件
      maxFileCount: 5,
      // 最多保留 5 个日志文件
      fileMaxAge: Duration(days: 3),
      // 超过 3 天的日志自动删除
      isRelease: kReleaseMode, // 根据模式自动调整颜色
    ),
  );
  // 或者简单初始化（开发用）
  // await Log.initDefault();

  /*
   * GetStorage  本地键值对初始化
   */
  await GetStorage.init();
  // final box = GetStorage();
  // String? url = box.read('supabaseUrl');
  // String? anonKey = box.read('supabaseAnonKey');

  await dotenv.load();
  final url = dotenv.get('SUPABASE_URL');
  final anonKey = dotenv.get('SUPABASE_ANON_KEY');

  /*
   * Supabase  云数据库初始化
   */
  await Supabase.initialize(url: url, publishableKey: anonKey);

  runApp(const ProviderScope(child: AppWidget()));
  // runApp(MaterialApp(home: MyCaptchaPage()));
}
