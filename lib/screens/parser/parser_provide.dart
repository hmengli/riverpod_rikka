import 'package:flutter/cupertino.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'parser_entity.dart';
import 'parser_repository.dart';

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
