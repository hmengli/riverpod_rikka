import 'package:hive_ce/hive.dart';
import 'package:rikka/screens/settings/api/parser_api_entity.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parser_api_provide.g.dart';

@riverpod
class ParserApiNotifier extends _$ParserApiNotifier {
  late final ParserApiRepository _repo;

  // 初始状态：未登录，加载完成
  @override
  FutureOr<void> build(ApiType apiType) {
    // 如果希望初始为未登录且不显示加载，可以直接返回 AsyncValue.data(null)
    _repo = ref.watch(parserApiRepositoryProvider(apiType));
    // 监听盒子变化，当外部修改数据时自动刷新 todoListProvider
    ref.listen(parserApiBoxProvider(apiType), (_, _) {
      ref.invalidate(parserApiListProvider(apiType));
    });
  }

  Future<void> upsertParser(ParserApiEntity entity) async {
    Log.d('upsertParser:${entity.basisUrl}');
    await _repo.add(entity);
    ref.invalidate(parserApiListProvider(apiType));
  }

  Future<void> deleteEntity(String basisUrl) async {
    Log.d('deleteEntity:$basisUrl');
    await _repo.delete(basisUrl);
    ref.invalidate(parserApiListProvider(apiType));
  }
}

@riverpod
Future<List<ParserApiEntity>> parserApiList(Ref ref, ApiType apiType) async {
  Log.i('parserApiList');
  return ref.watch(parserApiRepositoryProvider(apiType)).getAll();
}

@riverpod
ParserApiRepository parserApiRepository(Ref ref, ApiType apiType) {
  final box = ref.watch(parserApiBoxProvider(apiType));
  return ParserApiRepository(box);
}

@riverpod
Box<ParserApiEntity> parserApiBox(Ref ref, ApiType videoType) {
  switch (videoType) {
    case ApiType.comicsApi:
      return Hive.box<ParserApiEntity>('comicsApiBox');
    case ApiType.movieApi:
      return Hive.box<ParserApiEntity>('movieApiBox');
  }
}

class ParserApiRepository {
  final Box<ParserApiEntity> box;

  ParserApiRepository(this.box);

  List<ParserApiEntity> getAll() => box.values.toList();

  Future<void> add(ParserApiEntity todo) => box.put(todo.basisUrl, todo);

  Future<void> update(ParserApiEntity todo) => box.put(todo.basisUrl, todo);

  Future<void> delete(String basisUrl) => box.delete(basisUrl);

  // Stream<void> watch() => box.watch().map((event) => null);
}
