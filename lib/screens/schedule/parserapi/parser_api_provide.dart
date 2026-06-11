import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'parser_api_entity.dart';

part 'parser_api_provide.g.dart';

@riverpod
class ParserApiNotifier extends _$ParserApiNotifier {
  late final ParserApiRepository _repo;
  @override
  List<ParserApiEntity> build(ApiType apiType) {
    _repo = ref.watch(parserApiRepositoryProvider(apiType));
    return _repo.getAll();
  }

  Future<void> _refresh() async {
    if (!ref.mounted) return;
    state = _repo.getAll();
  }

  Future<void> upsertParser(ParserApiEntity entity) async {
    await _repo.add(entity);
    await _refresh();
  }

  Future<void> deleteEntity(String basisUrl) async {
    await _repo.delete(basisUrl);
    await _refresh();
  }
}

@riverpod
ParserApiRepository parserApiRepository(Ref ref, ApiType apiType) {
  return ParserApiRepository(Hive.box<ParserApiEntity>(apiType.name));
}
