import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/router_provider.dart';

import 'parser_entity.dart';
import 'parser_provide.dart';

class ParserPage extends ConsumerWidget {
  final VideoType videoType;
  const ParserPage({super.key, required this.videoType});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parserList = ref.watch(parserListProvider(videoType));
    ref.watch(parserProvider(videoType));
    return Scaffold(
      appBar: AppBar(
        title: Text('页面解析工具'),
        actions: [
          ElevatedButton(
            child: Icon(Icons.add),
            onPressed: () =>
                ParserUpsertRoute(videoType: videoType).push(context),
          ),
        ],
      ),
      body: parserList.when(
        data: (data) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ParserListViewCard(
                entity: data[index],
                videoType: videoType,
              );
            },
          );
        },
        error: (e, t) => Center(child: Text('Error: $e')),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class ParserListViewCard extends ConsumerWidget {
  final VideoType videoType;
  final ParserEntity entity;
  const ParserListViewCard({
    super.key,
    required this.entity,
    required this.videoType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parserNotifier = ref.read(parserProvider(videoType).notifier);
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(entity.name),
        subtitle: Text('URL: ${entity.basisUrl}'),
        onTap: () => ParserUpsertRoute(
          $extra: entity,
          videoType: videoType,
        ).push(context),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow_outlined, color: Colors.green),
              onPressed: () => ParserTestRoute(
                $extra: entity,
                videoType: videoType,
              ).push(context),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => parserNotifier.deleteEntity(entity.name),
            ),
          ],
        ),
      ),
    );
  }
}
