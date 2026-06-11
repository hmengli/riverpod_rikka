import 'package:hive_ce/hive.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'parser_entity.dart';

part 'parser_provide.g.dart';

///  本地解析库 -----------------------------------------------------------------

@riverpod
ParserRepository parserLocalRepository(Ref ref, VideoType videoType) {
  return ParserRepository(Hive.box<ParserEntity>(videoType.name));
}

@riverpod
class ParserLocalNotifier extends _$ParserLocalNotifier {
  late final ParserRepository _local;
  @override
  List<ParserEntity> build(VideoType videoType) {
    _local = ref.watch(parserLocalRepositoryProvider(videoType));
    // 重新加载本地列表
    return _local.getAll();
  }

  Future<void> _refresh() async {
    if (!ref.mounted) return;
    state = _local.getAll();
  }

  Future<void> upsert(ParserEntity entity) async {
    await _local.upsert(entity);
    await _refresh();
  }

  Future<void> delete(String basisUrl) async {
    await _local.delete(basisUrl);
    await _refresh();
  }
}

@riverpod
List<ParserSyncItem> parserLocalList(Ref ref, VideoType videoType) {
  final local = ref.watch(parserLocalProvider(videoType));

  final List<ParserSyncItem> syncItemList = [];

  // 处理云端有、本地无 -> cloudOnly
  for (var entry in local) {
    SyncStatus status = switch (entry.fromType) {
      FromType.cloud => SyncStatus.synced,
      FromType.local => SyncStatus.localOnly,
    };
    final newItem = ParserSyncItem(
      name: entry.name,
      basisUrl: entry.basisUrl,
      entity: entry,
      status: status,
    );
    syncItemList.add(newItem);
  }

  // 重新加载本地列表
  return syncItemList;
}

///  云端解析库 -----------------------------------------------------------------

@riverpod
Future<List<ParserSyncItem>> parserCloudList(
  Ref ref,
  VideoType videoType,
) async {
  ref.keepAlive();
  final local = ref.watch(parserLocalProvider(videoType));
  final cloud = await ref.watch(parserCloudProvider(videoType).future);
  final List<ParserSyncItem> syncItemList = [];

  final Map<String, ParserEntity> cloudMap = {
    for (var c in cloud) c.basisUrl: c,
  };

  final Map<String, ParserEntity> localMap = {
    for (var l in local) l.basisUrl: l,
  };

  // 处理云端有、本地无 -> cloudOnly
  for (var entry in cloudMap.entries) {
    if (!localMap.containsKey(entry.key)) {
      final newItem = ParserSyncItem(
        name: entry.value.name,
        basisUrl: entry.value.basisUrl,
        entity: entry.value,
        status: SyncStatus.cloudOnly,
      );
      syncItemList.add(newItem);
    } else {
      final newItem = ParserSyncItem(
        name: entry.value.name,
        basisUrl: entry.value.basisUrl,
        entity: entry.value,
        status: SyncStatus.synced,
      );
      syncItemList.add(newItem);
    }
  }

  // 重新加载本地列表
  return syncItemList;
}

@riverpod
class ParserCloudNotifier extends _$ParserCloudNotifier {
  late final ParserService _cloud;
  @override
  Future<List<ParserEntity>> build(VideoType videoType) async {
    _cloud = ref.watch(parserCloudRepositoryProvider(videoType));
    return await _cloud.getAll();
  }

  Future<void> _refresh() async {
    if (!ref.mounted) return;
    state = await AsyncValue.guard(() => _cloud.getAll());
  }

  Future<void> upsert(ParserEntity entity) async {
    await _cloud.upsert(entity);
    await _refresh();
  }

  Future<void> delete(String basisUrl) async {
    await _cloud.delete(basisUrl);
    await _refresh();
  }
}

abstract class ParserService {
  Future<List<ParserEntity>> getAll();
  Future<void> upsert(ParserEntity entity);
  Future<void> delete(String basisUrl);
}

@riverpod
ParserService parserCloudRepository(Ref ref, VideoType videoType) {
  return SupabaseService(Supabase.instance.client.from(videoType.name));
}

class SupabaseService extends ParserService {
  final SupabaseQueryBuilder builder;

  SupabaseService(this.builder);

  // 查询数据
  @override
  Future<List<ParserEntity>> getAll() async {
    final response = await builder
        .select(' * ')
        // .eq('isActive', true)
        .order('created_at', ascending: false);
    return response.map((element) {
      return ParserEntity.fromJson(element);
    }).toList();
  }

  // 插入数据
  @override
  Future<void> upsert(ParserEntity entity) async {
    final json = entity.toJson();
    Log.i('upsert: $json');
    await builder.upsert(json);
  }

  @override
  Future<void> delete(String basisUrl) async {
    await builder.delete().eq('basisUrl', basisUrl);
  }

  // 实时订阅
  // void subscribeToMessages(Function(List<dynamic>) onData) {
  //   _supabase
  //       .channel('messages')
  //       .on(
  //     RealtimeListenTypes.postgresChanges,
  //     ChannelFilter(event: 'INSERT', schema: 'public', table: 'messages'),
  //         (payload) => onData(payload['new'] as List),
  //   )
  //       .subscribe();
  // }

  // 调用存储过程
  // Future<void> callFunction() async {
  //   await _supabase.rpc('my_function', params: {'param1': 'value'});
  // }
}
