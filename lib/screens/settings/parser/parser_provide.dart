import 'package:hive_ce/hive.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'parser_entity.dart';

part 'parser_provide.g.dart';

@riverpod
Future<List<ParserEntity>> parserList(Ref ref, VideoType videoType) async {
  Log.i('parserList');
  return ref.watch(parserRepositoryProvider<ParserEntity>(videoType)).getAll();
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

  Future<void> upsertParser(Entity entity) async {
    Log.d('upsertParser:${entity.basisUrl}');
    await _repo.add(entity);
    ref.invalidate(parserListProvider(videoType));
  }

  Future<void> deleteEntity(String basisUrl) async {
    Log.d('deleteEntity:$basisUrl');
    await _repo.delete(basisUrl);
    ref.invalidate(parserListProvider(videoType));
  }
}

Map configMap = {VideoType.movie: 'comicsList', VideoType.comics: 'configList'};

@riverpod
Box<T> parserBox<T extends Entity>(Ref ref, VideoType videoType) {
  switch (videoType) {
    case VideoType.movie:
      return Hive.box<T>('movieBox');
    case VideoType.comics:
      return Hive.box<T>('comicsBox');
    case VideoType.comicsApi:
      return Hive.box<T>('comicsApiBox');
    case VideoType.movieApi:
      return Hive.box<T>('movieApiBox');
  }
}

// 提供 ParserRepository 实例
@riverpod
ParserRepository<T> parserRepository<T extends Entity>(
  Ref ref,
  VideoType videoType,
) {
  final box = ref.watch(parserBoxProvider<T>(videoType));
  return ParserRepository<T>(box);
}

class ParserRepository<T extends Entity> {
  final Box<T> box;

  ParserRepository(this.box);

  List<T> getAll() => box.values.toList();

  Future<void> add(T todo) => box.put(todo.basisUrl, todo);

  Future<void> update(T todo) => box.put(todo.basisUrl, todo);

  Future<void> delete(String basisUrl) => box.delete(basisUrl);

  // Stream<void> watch() => box.watch().map((event) => null);
}
