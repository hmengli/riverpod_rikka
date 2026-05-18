// lib/providers/auth_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

// 用户类型，例如使用 String 表示登录用户标识
typedef AuthUser = String;

@riverpod
class AuthNotifier extends _$AuthNotifier {
  // 初始状态：未登录，加载完成
  @override
  AsyncValue<AuthUser?> build() {
    // 如果希望初始为未登录且不显示加载，可以直接返回 AsyncValue.data(null)
    return const AsyncValue.data(null);
  }

  // 登录方法
  Future<void> signIn(String user) async {
    // 设置为加载状态（可选）
    state = const AsyncValue.loading();
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    // 设置登录成功的数据
    state = AsyncValue.data(user);
  }

  // 登出方法
  Future<void> signOut() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    // 设置为未登录状态
    state = const AsyncValue.data(null);
  }
}
