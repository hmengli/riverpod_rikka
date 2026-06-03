import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/settings/parserapi/parser_api_entity.dart';
import 'package:rikka/screens/settings/parserapi/parser_api_provide.dart';
import 'package:rikka/screens/settings/parserapi/upsert/parser_api_upsert_provide.dart';
import 'package:rikka/utils/logger.dart';

import '../settings_route.dart';

class ParserApiPage extends ConsumerWidget {
  final ApiType apiType;

  const ParserApiPage({super.key, required this.apiType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final parserApiList = dataList.map((toElement) {
    //   return ParserApiEntity.fromJson(toElement);
    // }).toList();
    final parserApiList = ref.watch(parserApiListProvider(apiType));
    ref.watch(parserApiProvider(apiType));
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

      // body: ListView.builder(
      //   itemCount: parserApiList.length,
      //   itemBuilder: (context, index) {
      //     return ParserApiListViewCard(
      //       entity: parserApiList[index],
      //       apiType: apiType,
      //     );
      //   },
      // ),
      body: parserApiList.when(
        data: (data) {
          Log.i('parserApiList: $data');
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ParserApiListViewCard(
                entity: data[index],
                apiType: apiType,
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
    // ref.watch(apiUpsertProvider);
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
              onPressed: () =>
                  parserApiNotifier.deleteEntity(entity.basisUrl ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
