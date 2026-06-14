import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/schedule/detail/parser/parser_upsert_page.dart';

import '../../../settings/settings_route.dart';
import 'parser_entity.dart';
import 'parser_provide.dart';

// 云端页面
class ParserCloudPage extends StatelessWidget {
  final VideoType videoType;
  const ParserCloudPage({super.key, required this.videoType});
  @override
  Widget build(BuildContext context) =>
      ParserListPage(videoType: videoType, fromType: FromType.cloud);
}

// 本地页面
class ParserLocalPage extends StatelessWidget {
  final VideoType videoType;
  const ParserLocalPage({super.key, required this.videoType});
  @override
  Widget build(BuildContext context) =>
      ParserListPage(videoType: videoType, fromType: FromType.local);
}

class ParserListPage extends ConsumerWidget {
  final VideoType videoType;
  final FromType fromType;
  const ParserListPage({
    super.key,
    required this.videoType,
    required this.fromType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudNotifier = ref.read(parserCloudProvider(videoType).notifier);
    final localNotifier = ref.read(parserLocalProvider(videoType).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('页面解析工具 - ${fromType == FromType.cloud ? "云端" : "本地"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ParserUpsertRoute(
              videoType: videoType,
              $extra: ParserUpsertArgs(
                upsert: (ParserEntity p1) {
                  switch (fromType) {
                    case FromType.cloud:
                      cloudNotifier.upsert(p1);
                    case FromType.local:
                      localNotifier.upsert(p1);
                  }
                },
              ),
            ).push(context),
          ),
        ],
      ),
      body: getFromTypeView(ref),
    );
  }

  Widget getFromTypeView(WidgetRef ref) {
    switch (fromType) {
      case FromType.cloud:
        final parserList = ref.watch(parserCloudListProvider(videoType));
        return parserList.when(
          data: (data) {
            return getView(data);
          },
          error: (e, t) => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      case FromType.local:
        return getView(ref.watch(parserLocalListProvider(videoType)));
    }
  }

  Widget getView(List<ParserSyncItem> data) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final entity = data[index];
        return ParserListCard(
          videoType: videoType,
          fromType: fromType,
          entity: entity,
        );
      },
    );
  }
}

class ParserListCard extends ConsumerWidget {
  final ParserSyncItem entity;
  final VideoType videoType;
  final FromType fromType;
  const ParserListCard({
    super.key,
    required this.videoType,
    required this.fromType,
    required this.entity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudNotifier = ref.read(parserCloudProvider(videoType).notifier);
    final localNotifier = ref.read(parserLocalProvider(videoType).notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(entity.name),
        subtitle: Text('URL: ${entity.basisUrl}'),
        onTap: () => ParserUpsertRoute(
          videoType: videoType,
          $extra: ParserUpsertArgs(
            entity: entity.entity,
            upsert: (ParserEntity p1) {
              switch (fromType) {
                case FromType.cloud:
                  cloudNotifier.upsert(p1);
                case FromType.local:
                  localNotifier.upsert(p1);
              }
            },
          ),
        ).push(context),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _syncStatus(ref, entity),
            // 测试按钮（共用）
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              onPressed: () => WorkTestRoute(
                videoType: videoType,
                $extra: entity.entity,
              ).push(context),
            ),
            // 删除按钮（共用）
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => switch (fromType) {
                FromType.cloud => cloudNotifier.delete(entity.basisUrl),
                FromType.local => localNotifier.delete(entity.basisUrl),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _syncStatus(WidgetRef ref, ParserSyncItem entity) {
    final cloudNotifier = ref.read(parserCloudProvider(videoType).notifier);
    final localNotifier = ref.read(parserLocalProvider(videoType).notifier);
    return switch (entity.status) {
      SyncStatus.localOnly => IconButton(
        onPressed: () => cloudNotifier.upsert(entity.entity),
        icon: const Icon(Icons.refresh, color: Colors.green),
      ),
      SyncStatus.cloudOnly => IconButton(
        onPressed: () => localNotifier.upsert(entity.entity),
        icon: const Icon(Icons.download, color: Colors.green),
      ),
      SyncStatus.synced => switch (fromType) {
        FromType.cloud => TextButton(
          onPressed: () => localNotifier.delete(entity.basisUrl),
          child: Text('delete_local'),
        ),
        FromType.local => Text(''),
      },
      SyncStatus.conflict => TextButton(
        onPressed: () => localNotifier.upsert(entity.entity),
        child: Text('sync_local'),
      ),
    };
  }
}
