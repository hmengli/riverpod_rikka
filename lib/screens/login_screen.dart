// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录页')),
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
