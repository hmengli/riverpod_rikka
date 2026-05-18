import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rikka/screens/comics_entity.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'schedule_provider.g.dart';

@riverpod
Future<List<ComicsEntity>> fetchData(Ref ref, {required String weekday}) async {
  ref.keepAlive();
  try {
    final results = await postPage(
      'https://dm.xifanacg.com/index.php/ds_api/weekday',
      {"weekday": weekday},
    );
    Map<String, dynamic> resultMap = jsonDecode(results);
    return (resultMap['list'] as List)
        .map((item) => ComicsEntity.fromJson(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    Log.i('fetchData:$e');
    return [];
  }
}

// 获取页面HTML//'https://dm.xifanacg.com/index.php/ds_api/weekday'
Future<String> postPage(String url, Object? body) async {
  Log.i('请求URL: $url, $body');
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0',
      'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'origin': 'https://dm.xifanacg.com',
      'referer': 'https://dm.xifanacg.com/index.php/label/weekday.html',
    },
    body: body,
  );
  if (response.statusCode == 200) {
    // Log.i('postPage:${response.body}');
    return response.body;
  } else {
    throw Exception('HTTP ${response.statusCode}');
  }
}
