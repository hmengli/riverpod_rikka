import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/settings/api/parser_api_entity.dart';
import 'package:rikka/screens/settings/api/parser_api_provide.dart';
import 'package:rikka/screens/settings/api/upsert/parser_api_upsert_provide.dart';

import '../settings_route.dart';

List<Map<String, dynamic>> dataList = [
  {
    "id": "api_a",
    "basisUrl": "https://api.example.com/articles",
    "method": "GET",
    "dataRootPath": "data.list",
    "fieldMappings": [
      {"targetField": "url", "type": "direct", "sourcePath": "article_id"},
      {"targetField": "vod_name", "type": "direct", "sourcePath": "headline"},
      {
        "targetField": "vod_pic",
        "type": "template",
        "sourcePath": "https://cdn.com/\${image_path}",
      },
      {
        "targetField": "description",
        "type": "template",
        "sourcePath": "\${author} : \${summary}",
      },
    ],
  },
  {
    "id": "api_b",
    "basisUrl": "https://api.another.com/items",
    "method": "POST",
    "dataRootPath": "payload",
    "fieldMappings": [
      {"targetField": "url", "type": "direct", "sourcePath": "uid"},
      {"targetField": "vod_name", "type": "direct", "sourcePath": "data.name"},
      {"targetField": "imageUrl", "type": "direct", "sourcePath": "cover.url"},
      {
        "targetField": "description",
        "type": "template",
        "sourcePath": "\${stats.likes} likes · \${content}",
      },
    ],
  },
];

class ParserApiPage extends ConsumerWidget {
  final ApiType apiType;

  const ParserApiPage({super.key, required this.apiType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parserApiList = dataList.map((toElement) {
      return ParserApiEntity.fromJson(toElement);
    }).toList();
    // final parserApiList = ref.watch(parserApiListProvider(apiType));
    // ref.watch(parserApiProvider(apiType));
    return Scaffold(
      appBar: AppBar(
        title: Text('页面解析工具'),
        actions: [
          ElevatedButton(
            onPressed: () =>
                ParserApiUpsertRoute(apiType: ApiType.comicsApi).push(context),
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: parserApiList.length,
        itemBuilder: (context, index) {
          return ParserApiListViewCard(
            entity: parserApiList[index],
            apiType: apiType,
          );
        },
      ),

      // body: parserApiList.when(
      //   data: (data) {
      //     return ListView.builder(
      //       padding: const EdgeInsets.all(16),
      //       itemCount: data.length,
      //       itemBuilder: (context, index) {
      //         return ParserApiListViewCard(
      //           entity: data[index],
      //           apiType: apiType,
      //         );
      //       },
      //     );
      //   },
      //   error: (e, t) => Center(child: Text('Error: $e')),
      //   loading: () => Center(child: CircularProgressIndicator()),
      // ),
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
    ref.watch(apiUpsertProvider);
    final parserNotifier = ref.read(parserApiProvider(apiType).notifier);
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(entity.method ?? ''),
        subtitle: Text('URL: ${entity.basisUrl}'),
        onTap: () {
          ref.read(apiUpsertProvider.notifier).setParserApi(entity);
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
              onPressed: () =>
                  parserNotifier.deleteEntity(entity.basisUrl ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
