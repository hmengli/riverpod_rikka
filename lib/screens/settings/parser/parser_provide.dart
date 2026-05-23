import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:rikka/screens/schedule/detail/silent_cookie_service.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'parser_entity.dart';

part 'parser_provide.g.dart';

@riverpod
Future<List<ParserEntity>> parserList(Ref ref) async {
  final repo = ref.watch(parserRepositoryProvider);
  Log.d('parserList: $repo');
  List<ParserEntity> parserList = repo.getAll();
  Log.d('parserList: $parserList');
  // state = const AsyncValue.data(parserList);
  // 返回初始数据
  return parserList;
}

@riverpod
class CodeNotifier extends _$CodeNotifier {
  @override
  Future<String?> build() async {
    return null;
  }

  Future<String?> getCode(Uint8List prev) async {
    try {
      state = AsyncValue.loading();
      final data = await CaptchaService.recognizeCaptcha(prev);
      Log.i('getCode: $data');
      state = AsyncValue.data(data);
      return data;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
    return null;
  }
}

@riverpod
class CookieNotifier extends _$CookieNotifier {
  late CookieSilentService cookie;

  @override
  Future<Uint8List?> build() async {
    cookie = ref.read(cookieSilentServiceProvider);
    // 注册销毁回调：取消所有进行中的异步任务
    ref.onDispose(() {
      cookie.dispose();
    });
    return null;
  }

  Future<void> loadingPage(String step1Url) async {
    await cookie.captureScreenshot(step1Url);
  }

  Future<Uint8List?> setScreenshot(String verifyPng) async {
    try {
      state = AsyncValue.loading();
      final data = await cookie.getScreenshot(verifyPng);
      state = AsyncValue.data(data);
      return data;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<String?> parserCookie(
    String? code, {
    required String input,
    required String submit,
  }) {
    return cookie.submitCaptcha(code, input: input, submit: submit);
  }
}

@riverpod
class ParserNotifier extends _$ParserNotifier {
  late final ParserRepository _repo;

  // 初始状态：未登录，加载完成
  @override
  FutureOr<void> build() {
    // 如果希望初始为未登录且不显示加载，可以直接返回 AsyncValue.data(null)
    _repo = ref.read(parserRepositoryProvider);
    listenSelf((previous, next) {
      // 例如：每次状态变化时打印日志
      debugPrint('TodoNotifier state changed from $previous to $next');
    });
    // 监听盒子变化，当外部修改数据时自动刷新 todoListProvider
    ref.listen(parserBoxProvider, (_, _) {
      ref.invalidate(parserListProvider);
    });
  }

  Future<void> upsertParser(VideoType type, ParserEntity entity) async {
    state = const AsyncValue.loading();
    Log.d('upsertParser:${entity.basisUrl}');
    await _repo.add(entity);
    ref.invalidate(parserListProvider);
    state = const AsyncValue.data(null);
  }

  Future<void> deleteEntity(String name) async {
    state = const AsyncValue.loading();
    await _repo.delete(name);
    ref.invalidate(parserListProvider);
    state = const AsyncValue.data(null);
  }
}

Map configMap = {VideoType.movie: 'comicsList', VideoType.comics: 'configList'};

// 提供 Box<Todo> 实例
final parserBoxProvider = Provider<Box<ParserEntity>>((ref) {
  Log.d('parserBoxProvider');
  return Hive.box<ParserEntity>('configsBox');
});

// 提供 ParserRepository 实例
final parserRepositoryProvider = Provider<ParserRepository>((ref) {
  Log.d('parserRepositoryProvider');
  final box = ref.watch(parserBoxProvider);
  return ParserRepository(box);
});

class ParserRepository {
  final Box<ParserEntity> box;

  ParserRepository(this.box);

  List<ParserEntity> getAll() => box.values.toList();

  Future<void> add(ParserEntity todo) => box.put(todo.name, todo);

  Future<void> update(ParserEntity todo) => box.put(todo.name, todo);

  Future<void> delete(String name) => box.delete(name);

  // Stream<void> watch() => box.watch().map((event) => null);
}
