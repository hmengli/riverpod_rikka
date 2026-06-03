import 'package:rikka/screens/settings/parserapi/parser_api_entity.dart';
import 'package:rikka/utils/logger.dart';

import 'comics_entity.dart';

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
  static List<ComicsEntity> convert(
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
      for (String field in ComicsEntity.list) {
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
      return ComicsEntity.fromJson(unifiedMap);
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
