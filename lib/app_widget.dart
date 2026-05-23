import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/utils/utils.dart';
import 'package:window_manager/window_manager.dart';

import 'router_provider.dart';

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
