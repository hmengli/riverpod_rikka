import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/settings_route.dart';
import 'parser_api_entity.dart';
import 'parser_api_provide.dart';
import 'upsert/parser_api_upsert_provide.dart';

class ParserApiPage extends ConsumerWidget {
  final ApiType apiType;
  const ParserApiPage({super.key, required this.apiType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parserApiList = ref.watch(parserApiProvider(apiType));
    return Scaffold(
      appBar: AppBar(
        title: Text('页面解析工具'),
        actions: [
          ElevatedButton(
            onPressed: () =>
                ParserApiUpsertRoute(apiType: apiType).push(context),
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parserApiList.length,
        itemBuilder: (context, index) {
          return ParserApiListViewCard(
            entity: parserApiList[index],
            apiType: apiType,
          );
        },
      ),
    );
  }
}

class ParserApiListViewCard extends ConsumerWidget {
  final ApiType apiType;
  final ParserApiEntity entity;

  const ParserApiListViewCard({
    super.key,
    required this.entity,
    required this.apiType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parserApiNotifier = ref.read(parserApiProvider(apiType).notifier);
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(entity.method.name),
        subtitle: Text('URL: ${entity.basisUrl}'),
        onTap: () {
          ref.read(apiUpsertProvider.notifier).setState(entity);
          ParserApiUpsertRoute(
            apiType: ApiType.comicsApi,
            $extra: entity,
          ).push(context);
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow_outlined, color: Colors.green),
              onPressed: null,
              // () => ParserTestRoute(
              //   $extra: entity,
              //   videoType: videoType,
              // ).push(context),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => parserApiNotifier.deleteEntity(entity.basisUrl),
            ),
          ],
        ),
      ),
    );
  }
}
