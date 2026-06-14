// lib/screens/login_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/utils/utils.dart';
import 'package:window_manager/window_manager.dart';
import 'auth_provider.dart';

class TitleScreen extends StatefulWidget {
  final String title;
  final BuildContext context;
  final Widget? child;
  const TitleScreen({
    super.key,
    required this.title,
    required this.context,
    this.child,
  });

  @override
  State<StatefulWidget> createState() => StateTitleScreen();
}

class StateTitleScreen extends State<TitleScreen> {
  bool isDialogShowing = false;
  void showDialogClose(BuildContext context, bool isDialogShowing) async {
    // 防止重复弹出
    if (isDialogShowing) return;
    isDialogShowing = true;

    final result = await showDialog<bool>(
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('退出'),
          ),
        ],
      ),
    );
    isDialogShowing = false;

    if (result == true) {
      if (Utils.isDesktop()) {
        // 桌面端优雅关闭窗口
        await windowManager.close(); // 需要先初始化 window_manager
      } else {
        // 移动端退出应用（Android 通常返回桌面，iOS 需特殊处理）
        exit(0); // 或者使用 SystemNavigator.pop()
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              showDialogClose(context, isDialogShowing);
            },
            icon: Icon(Icons.close),
          ),
        ],
        centerTitle: true,
      ),
      body: widget.child,
    );
  }
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 触发登录，更新 Riverpod 状态
            ref.read(authProvider.notifier).signIn('signed_in_user');
          },
          child: const Text('登录'),
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// The not found screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.uri});
  final String uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Can't find a page for: $uri")));
  }
}
