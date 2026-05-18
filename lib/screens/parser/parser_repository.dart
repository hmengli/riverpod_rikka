import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:rikka/utils/logger.dart';

import 'parser_entity.dart';

Map configMap = {VideoType.movie: 'comicsList', VideoType.comics: 'configList'};

// 提供 Box<Todo> 实例
final parserBoxProvider = Provider<Box<ParserEntity>>((ref) {
  Log.d('parserBoxProvider');
  return Hive.box<ParserEntity>('configsBox');
});

// 提供 ParserRepository 实例
final parserRepositoryProvider = Provider<ParserRepository>((ref) {
  Log.d('parserRepositoryProvider');
  final box = ref.watch(parserBoxProvider);
  return ParserRepository(box);
});

class ParserRepository {
  final Box<ParserEntity> box;

  ParserRepository(this.box);

  List<ParserEntity> getAll() => box.values.toList();

  Future<void> add(ParserEntity todo) async {
    Log.d('parserList: $todo');
    box.put(todo.name, todo);
  }

  Future<void> update(ParserEntity todo) => box.put(todo.name, todo);

  Future<void> delete(String name) => box.delete(name);

  // Stream<void> watch() => box.watch().map((event) => null);
}

// 提供 ParserRepository 实例
final parserServiceProvider = Provider<ParserService>((ref) {
  Log.d('parserServiceProvider');
  return ParserService();
});

class ParserService {
  // 执行完整的三步解析
  static Future<String> parseWithConfig(
    String step1Url,
    ParserEntity entity, {
    String? search,
  }) async {
    try {
      // 第一步：获取页面
      if (search != null) {
        step1Url = step1Url.replaceAll('@keyword', search);
      }
      return await fetchPage(step1Url, entity);
    } catch (e) {
      throw Exception('网络错误，请检查网络: $e');
    }
  }

  // 执行完整的三步解析
  static Future<List<Map<String, String>>> parseWithStep1(
    ParserEntity entity, {
    String? search,
  }) async {
    try {
      String step1Url = entity.searchUrl;
      // 第一步：获取页面
      if (search != null) {
        step1Url = step1Url.replaceAll('@keyword', search);
      }
      String html = await fetchPage(step1Url, entity);

      final document = parser.parse(html);
      final elements = document.querySelectorAll(entity.searchHref);
      return elements.map((element) {
        String? href = element.querySelector('a')?.attributes['href'];
        String? title;
        if (entity.searchTitle.contains('@')) {
          List<String>? list = entity.searchTitle.split('@');
          title = element.querySelector(list[0])?.attributes[list[1]];
        } else {
          title = element.querySelector(entity.searchTitle)?.text;
        }
        return {'href': href ?? '', 'title': title ?? ''};
      }).toList();
    } catch (e) {
      throw Exception('网络错误，请检查网络: $e');
    }
  }

  // 获取页面HTML
  static Future<String> fetchPage(String url, ParserEntity parserEntity) async {
    Log.i('请求URL: $url');
    Log.i('请求URL: ${parserEntity.cookie}');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml',
        // 'Referer': parserEntity.referer,
        'Cookie': parserEntity.cookie,
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  // 获取页面HTML//'https://dm.xifanacg.com/index.php/ds_api/weekday'
  static Future<String> postPage(String url, Object? body) async {
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

  // 提取链接或内容
  static List<Map<String, String?>> extractLinks1(
    String html, {
    required String hrefSelector,
    required String titleSelector,
  }) {
    final document = parser.parse(html);
    final elements = document.querySelectorAll(hrefSelector);
    return elements.map((element) {
      String? href = element.querySelector('a')?.attributes['href'];
      String? title;
      if (titleSelector.contains('@')) {
        List<String> list = titleSelector.split('@');
        title = element.querySelector(list[0])?.attributes[list[1]];
      } else {
        title = element.querySelector(titleSelector)?.text;
      }
      return {'href': href ?? '', 'title': title ?? ''};
    }).toList();
  }

  // 提取链接或内容
  static List<List<Map<String, String>>> extractLinks2(
    String html, {
    required String selector,
    required String selectorValue,
  }) {
    final document = parser.parse(html);
    final elements = document.querySelectorAll(selector);
    return List.generate(elements.length, (index) {
      final elementsA = elements[index].querySelectorAll(selectorValue);
      return elementsA.map((element) {
        return {
          'href': element.attributes['href'].toString(),
          'value': element.text.trim(),
        };
      }).toList();
    });
  }

  // 提取链接或内容
  static String? extractLink3(String html, String selector3) {
    final document = parser.parse(html);
    final element = document.querySelector(selector3);
    return element == null ? null : element.attributes['src'].toString();
  }

  // 提取最终数据
  static List<Map<String, String>> extractData(String html, String selector) {
    final document = parser.parse(html);
    final elements = document.querySelectorAll(selector);

    return elements.map((element) {
      Map<String, String> data = {};

      // 提取所有子元素的文本
      data['text'] = element.text.trim();
      data['html'] = element.innerHtml;

      // 提取所有属性（如href, src等）
      element.attributes.forEach((key, value) {
        data[key.toString()] = value;
      });

      return data;
    }).toList();
  }

  // 调试：打印选择器匹配结果
  static void debugSelector(String html, String selector) {
    final document = parser.parse(html);
    final elements = document.querySelectorAll(selector);
    Log.i('选择器 "$selector" 匹配到 ${elements.length} 个元素');
    for (var i = 0; i < elements.length && i < 3; i++) {
      Log.i('元素 $i: ${elements[i].outerHtml.substring(0, 200)}...');
    }
  }
}
