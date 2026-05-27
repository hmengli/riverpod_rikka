import 'package:hive_ce/hive.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'parser_entity.dart';

part 'parser_provide.g.dart';

@riverpod
Future<List<ParserEntity>> parserList(Ref ref, VideoType videoType) async {
  Log.i('parserList');
  return ref.watch(parserRepositoryProvider(videoType)).getAll();
}

@riverpod
class ParserNotifier extends _$ParserNotifier {
  late final ParserRepository _repo;

  // 初始状态：未登录，加载完成
  @override
  FutureOr<void> build(VideoType videoType) {
    // 如果希望初始为未登录且不显示加载，可以直接返回 AsyncValue.data(null)
    _repo = ref.watch(parserRepositoryProvider(videoType));
    // 监听盒子变化，当外部修改数据时自动刷新 todoListProvider
    ref.listen(parserBoxProvider(videoType), (_, _) {
      ref.invalidate(parserListProvider(videoType));
    });
  }

  Future<void> upsertParser(ParserEntity entity) async {
    Log.d('upsertParser:${entity.basisUrl}');
    await _repo.add(entity);
    ref.invalidate(parserListProvider(videoType));
  }

  Future<void> deleteEntity(String name) async {
    Log.d('deleteEntity:$name');
    await _repo.delete(name);
    ref.invalidate(parserListProvider(videoType));
  }
}

Map configMap = {VideoType.movie: 'comicsList', VideoType.comics: 'configList'};

@riverpod
Box<ParserEntity> parserBox(Ref ref, VideoType videoType) {
  switch (videoType) {
    case VideoType.movie:
      return Hive.box<ParserEntity>('movieBox');
    case VideoType.comics:
      return Hive.box<ParserEntity>('comicsBox');
  }
}

// 提供 ParserRepository 实例
@riverpod
ParserRepository parserRepository(Ref ref, VideoType videoType) {
  final box = ref.watch(parserBoxProvider(videoType));
  return ParserRepository(box);
}

class ParserRepository {
  final Box<ParserEntity> box;

  ParserRepository(this.box);

  List<ParserEntity> getAll() => box.values.toList();

  Future<void> add(ParserEntity todo) => box.put(todo.name, todo);

  Future<void> update(ParserEntity todo) => box.put(todo.name, todo);

  Future<void> delete(String name) => box.delete(name);

  // Stream<void> watch() => box.watch().map((event) => null);
}
