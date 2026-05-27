import 'dart:convert';

import 'package:browser_headers/browser_headers.dart';
import 'package:http/http.dart' as http;
import 'package:rikka/screens/schedule/comics_entity.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'schedule_provider.g.dart';

@riverpod
Future<List<ComicsEntity>> fetchData(Ref ref, {required String weekday}) async {
  ref.keepAlive();

  try {
    // String gugu3 = "https://www.gugu3.com/index.php/api/weekday";
    // String xifanacg = "https://www.gugu3.com/index.php/api/weekday";
    String dalvdm = "https://www.dalvdm.cc/index.php/ds_api/weekday";
    // Map<String, dynamic> gugu3Body = {
    //   "weekday": "二",
    //   "num": "20",
    //   "by": "time",
    //   "type": "",
    //   "time": "${DateTime.now().millisecondsSinceEpoch}",
    //   "key": "8fd3ead5453c6d2d842c88266a932faa",
    // };
    Map<String, dynamic> xifa = {"weekday": weekday};
    final results = await postPage(dalvdm, xifa);
    Log.i("message:$results");

    Map<String, dynamic> resultMap = jsonDecode(results);
    return (resultMap['list'] as List)
        .map((item) => ComicsEntity.fromJson(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    Log.e('fetchData:$e');
    return [];
  }
}

// 获取页面HTML//'https://dm.xifanacg.com/index.php/ds_api/weekday'
Future<dynamic> postPage(String uri, Object? body) async {
  final headers = BrowserHeaders.generate();
  final response = await http.post(
    Uri.parse(uri),
    headers: headers,
    body: body,
  );
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('HTTP ${response.statusCode}');
  }
}
