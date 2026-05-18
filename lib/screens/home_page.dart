// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('主页')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 触发登出，更新 Riverpod 状态
            ref.read(authProvider.notifier).signOut();
          },
          child: const Text('登出'),
        ),
      ),
    );
  }
}
