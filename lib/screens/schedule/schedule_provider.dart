import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rikka/screens/auth_provider.dart';
import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'parserapi/parser_api_entity.dart';
import 'parserapi/parser_api_provide.dart';
import 'schedule_entity.dart';

part 'schedule_provider.g.dart';

@riverpod
class ApiDropdownNotify extends _$ApiDropdownNotify {
  @override
  ParserApiEntity build(ApiType apiType) {
    final parserApi = ref.watch(parserApiProvider(apiType));
    return parserApi.firstOrNull ?? ParserApiEntity();
  }

  void setState(ParserApiEntity element) {
    state = element;
  }
}

@riverpod
Future<List<ScheduleEntity>> fetchData(
  Ref ref,
  String weekday,
  ApiType apiType,
) async {
  ref.keepAlive();
  final apiValue = ref.watch(apiDropdownNotifyProvider(apiType));
  final headers = ref.read(browserHeadersProvider);

  return postData(apiEntity: apiValue, weekday: weekday, headers: headers);
}

Future<List<ScheduleEntity>> postData({
  required ParserApiEntity apiEntity,
  required String weekday,
  required Map<String, String> headers,
}) async {
  try {
    Map<String, dynamic> body = {"weekday": weekday};
    if (apiEntity.headers.isNotEmpty) {
      for (var e in apiEntity.headers) {
        headers.addAll({e.mKey: e.mValue.toString()});
      }
    }
    Log.i('fetchData:$headers');

    final response = await http.post(
      Uri.parse(apiEntity.basisUrl.trim()),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      Log.i('fetchData: ${response.statusCode}');
      Map<String, dynamic> resultMap = jsonDecode(response.body);

      return DataMappingEngine.convert(resultMap, apiEntity);
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  } catch (e) {
    Log.e('fetchData:$e');
    return [];
  }
}

/// 根据点分隔路径从Map中取值，如 'data.user.name'
dynamic getValueByPath(Map<String, dynamic> json, String path) {
  List<String> keys = path.split('.');
  dynamic current = json;
  for (var key in keys) {
    if (current is Map && current.containsKey(key)) {
      current = current[key];
    } else {
      return null; // 路径不存在
    }
  }
  return current;
}

/// 解析模板字符串，如 '${author} : ${summary}'，从json中获取变量值
String parseTemplate(String template, Map<String, dynamic> json) {
  // 匹配 ${xxx} 中的 xxx，支持点路径
  final regex = RegExp(r'\$\{([^}]+)\}');
  return template.replaceAllMapped(regex, (match) {
    final path = match.group(1)!;
    final value = getValueByPath(json, path);
    return value?.toString() ?? '';
  });
}

class DataMappingEngine {
  /// 根据配置将单个API返回的JSON对象列表（或单个对象）转换为统一实体列表
  static List<ScheduleEntity> convert(
    dynamic responseJson,
    ParserApiEntity config,
  ) {
    // 获取原始数据列表
    List<dynamic> rawList;
    final data = getValueByPath(responseJson, config.dataRootPath);
    if (data is List) {
      rawList = data;
    } else {
      rawList = [];
    }

    return rawList.map((rawItem) {
      final Map<String, dynamic> unifiedMap = {};
      for (String field in ScheduleEntity.fieldList) {
        final mapping = getFieldMappings(config.fieldMappings, field);
        if (mapping != null) {
          dynamic value;
          if (mapping.type == ValueSourceType.direct) {
            value = getValueByPath(rawItem, mapping.sourcePath!);
          } else if (mapping.type == ValueSourceType.template) {
            value = parseTemplate(mapping.sourcePath!, rawItem);
          }
          // 如果是字符串且有清洗规则，则应用
          if (value is String && mapping.transforms.isNotEmpty) {
            Log.i('transforms: $value');
            value = applyTransforms(value, mapping.transforms);
          }
          unifiedMap[field] = value;
        } else {
          unifiedMap[field] = rawItem[field];
        }
      }
      // 从Map创建UnifiedEntity，假设UnifiedEntity有一个fromMap构造
      return ScheduleEntity.fromJson(unifiedMap);
    }).toList();
  }
}

FieldMapping? getFieldMappings(List<FieldMapping> fieldMapping, String field) {
  for (var action in fieldMapping) {
    if (action.targetField != null &&
        field.compareTo(action.targetField!) == 0) {
      return action;
    }
  }
  return null;
}

String applyTransforms(String input, List<DataTransForm> transforms) {
  var result = input;
  for (final t in transforms) {
    switch (t.type) {
      case TransFormType.trim:
        result = result.trim();
        break;
      case TransFormType.unescape:
        // 处理常见转义字符
        result = result
            .replaceAll(r'\"', '"')
            .replaceAll(r'\n', '')
            .replaceAll(r'\r', '')
            .replaceAll(r'\t', '')
            .replaceAll(r'\\', '');
        break;
      case TransFormType.removeWhitespace:
        result = result.replaceAll(RegExp(r'\s+'), '');
        break;
      case TransFormType.replace:
        if (t.pattern != null) {
          result = result.replaceAll(RegExp(t.pattern!), t.replacement ?? '');
        }
        break;
    }
  }
  return result;
}

// String gugu3 = "https://www.gugu3.com/index.php/api/weekday";
// int time = DateTime.now().millisecondsSinceEpoch;
// String md5Result = hexMd5('DS${time}DCC147D11943AF75');
// Map<String, dynamic> gugu3Body = {
//   "weekday": "二",
//   "num": "20",
//   "by": "time",
//   "type": "",
//   "time": '$time',
//   "key": md5Result,
// };
int hexcase = 0; // 0=小写，1=大写
int chrsz = 8; // 每个字符位数，固定为8

String hexMd5(String s) {
  List<int> bin = str2binl(s);
  List<int> core = coreMd5(bin, s.length * chrsz);
  return binl2hex(core);
}

String binl2hex(List<int> binarray) {
  String hexTab = hexcase == 0 ? "0123456789abcdef" : "0123456789ABCDEF";
  StringBuffer sb = StringBuffer();
  for (int i = 0; i < binarray.length * 4; i++) {
    int idx = i >> 2;
    sb.write(hexTab[(binarray[idx] >> (((i % 4) * 8) + 4)) & 0x0F]);
    sb.write(hexTab[(binarray[idx] >> ((i % 4) * 8)) & 0x0F]);
  }
  return sb.toString();
}

List<int> str2binl(String str) {
  List<int> bin = [];
  int mask = (1 << chrsz) - 1;
  for (int i = 0; i < str.length * chrsz; i += chrsz) {
    int wordIdx = i >> 5;
    int charCode = str.codeUnitAt(i ~/ chrsz);
    int bits = (charCode & mask) << (i % 32);
    if (wordIdx >= bin.length) bin.add(0);
    bin[wordIdx] |= bits;
  }
  return bin;
}

List<int> coreMd5(List<int> x, int len) {
  // 补位 0x80
  int byteIdx = len >> 5;
  if (byteIdx >= x.length) x.add(0);
  x[byteIdx] |= 0x80 << (len % 32);

  // 存储长度
  int index = (((len + 64) >>> 9) << 4) + 14;
  while (index >= x.length) {
    x.add(0);
  }
  x[index] = len;

  int a = 1732584193;
  int b = -271733879;
  int c = -1732584194;
  int d = 271733878;

  for (int i = 0; i < x.length; i += 16) {
    // 确保当前块完整
    while (i + 15 >= x.length) {
      x.add(0);
    }

    int olda = a, oldb = b, oldc = c, oldd = d;

    // 第1轮
    a = md5Ff(a, b, c, d, x[i + 0], 7, -680876936);
    d = md5Ff(d, a, b, c, x[i + 1], 12, -389564586);
    c = md5Ff(c, d, a, b, x[i + 2], 17, 606105819);
    b = md5Ff(b, c, d, a, x[i + 3], 22, -1044525330);
    a = md5Ff(a, b, c, d, x[i + 4], 7, -176418897);
    d = md5Ff(d, a, b, c, x[i + 5], 12, 1200080426);
    c = md5Ff(c, d, a, b, x[i + 6], 17, -1473231341);
    b = md5Ff(b, c, d, a, x[i + 7], 22, -45705983);
    a = md5Ff(a, b, c, d, x[i + 8], 7, 1770035416);
    d = md5Ff(d, a, b, c, x[i + 9], 12, -1958414417);
    c = md5Ff(c, d, a, b, x[i + 10], 17, -42063);
    b = md5Ff(b, c, d, a, x[i + 11], 22, -1990404162);
    a = md5Ff(a, b, c, d, x[i + 12], 7, 1804603682);
    d = md5Ff(d, a, b, c, x[i + 13], 12, -40341101);
    c = md5Ff(c, d, a, b, x[i + 14], 17, -1502002290);
    b = md5Ff(b, c, d, a, x[i + 15], 22, 1236535329);

    // 第2轮
    a = md5Gg(a, b, c, d, x[i + 1], 5, -165796510);
    d = md5Gg(d, a, b, c, x[i + 6], 9, -1069501632);
    c = md5Gg(c, d, a, b, x[i + 11], 14, 643717713);
    b = md5Gg(b, c, d, a, x[i + 0], 20, -373897302);
    a = md5Gg(a, b, c, d, x[i + 5], 5, -701558691);
    d = md5Gg(d, a, b, c, x[i + 10], 9, 38016083);
    c = md5Gg(c, d, a, b, x[i + 15], 14, -660478335);
    b = md5Gg(b, c, d, a, x[i + 4], 20, -405537848);
    a = md5Gg(a, b, c, d, x[i + 9], 5, 568446438);
    d = md5Gg(d, a, b, c, x[i + 14], 9, -1019803690);
    c = md5Gg(c, d, a, b, x[i + 3], 14, -187363961);
    b = md5Gg(b, c, d, a, x[i + 8], 20, 1163531501);
    a = md5Gg(a, b, c, d, x[i + 13], 5, -1444681467);
    d = md5Gg(d, a, b, c, x[i + 2], 9, -51403784);
    c = md5Gg(c, d, a, b, x[i + 7], 14, 1735328473);
    b = md5Gg(b, c, d, a, x[i + 12], 20, -1926607734);

    // 第3轮
    a = md5Hh(a, b, c, d, x[i + 5], 4, -378558);
    d = md5Hh(d, a, b, c, x[i + 8], 11, -2022574463);
    c = md5Hh(c, d, a, b, x[i + 11], 16, 1839030562);
    b = md5Hh(b, c, d, a, x[i + 14], 23, -35309556);
    a = md5Hh(a, b, c, d, x[i + 1], 4, -1530992060);
    d = md5Hh(d, a, b, c, x[i + 4], 11, 1272893353);
    c = md5Hh(c, d, a, b, x[i + 7], 16, -155497632);
    b = md5Hh(b, c, d, a, x[i + 10], 23, -1094730640);
    a = md5Hh(a, b, c, d, x[i + 13], 4, 681279174);
    d = md5Hh(d, a, b, c, x[i + 0], 11, -358537222);
    c = md5Hh(c, d, a, b, x[i + 3], 16, -722521979);
    b = md5Hh(b, c, d, a, x[i + 6], 23, 76029189);
    a = md5Hh(a, b, c, d, x[i + 9], 4, -640364487);
    d = md5Hh(d, a, b, c, x[i + 12], 11, -421815835);
    c = md5Hh(c, d, a, b, x[i + 15], 16, 530742520);
    b = md5Hh(b, c, d, a, x[i + 2], 23, -995338651);

    // 第4轮
    a = md5Ii(a, b, c, d, x[i + 0], 6, -198630844);
    d = md5Ii(d, a, b, c, x[i + 7], 10, 1126891415);
    c = md5Ii(c, d, a, b, x[i + 14], 15, -1416354905);
    b = md5Ii(b, c, d, a, x[i + 5], 21, -57434055);
    a = md5Ii(a, b, c, d, x[i + 12], 6, 1700485571);
    d = md5Ii(d, a, b, c, x[i + 3], 10, -1894986606);
    c = md5Ii(c, d, a, b, x[i + 10], 15, -1051523);
    b = md5Ii(b, c, d, a, x[i + 1], 21, -2054922799);
    a = md5Ii(a, b, c, d, x[i + 8], 6, 1873313359);
    d = md5Ii(d, a, b, c, x[i + 15], 10, -30611744);
    c = md5Ii(c, d, a, b, x[i + 6], 15, -1560198380);
    b = md5Ii(b, c, d, a, x[i + 13], 21, 1309151649);
    a = md5Ii(a, b, c, d, x[i + 4], 6, -145523070);
    d = md5Ii(d, a, b, c, x[i + 11], 10, -1120210379);
    c = md5Ii(c, d, a, b, x[i + 2], 15, 718787259);
    b = md5Ii(b, c, d, a, x[i + 9], 21, -343485551);

    a = safeAdd(a, olda);
    b = safeAdd(b, oldb);
    c = safeAdd(c, oldc);
    d = safeAdd(d, oldd);
  }
  return [a, b, c, d];
}

int md5Cmn(int q, int a, int b, int x, int s, int t) =>
    safeAdd(bitRot(safeAdd(safeAdd(a, q), safeAdd(x, t)), s), b);

int md5Ff(int a, int b, int c, int d, int x, int s, int t) =>
    md5Cmn((b & c) | ((~b) & d), a, b, x, s, t);

int md5Gg(int a, int b, int c, int d, int x, int s, int t) =>
    md5Cmn((b & d) | (c & (~d)), a, b, x, s, t);

int md5Hh(int a, int b, int c, int d, int x, int s, int t) =>
    md5Cmn(b ^ c ^ d, a, b, x, s, t);

int md5Ii(int a, int b, int c, int d, int x, int s, int t) =>
    md5Cmn(c ^ (b | (~d)), a, b, x, s, t);

int safeAdd(int x, int y) {
  int lsw = (x & 0xFFFF) + (y & 0xFFFF);
  int msw = (x >> 16) + (y >> 16) + (lsw >> 16);
  return (msw << 16) | (lsw & 0xFFFF);
}

int bitRot(int num, int cnt) {
  num = num & 0xFFFFFFFF;
  return ((num << cnt) | (num >> (32 - cnt))) & 0xFFFFFFFF;
}

// 使用示例
