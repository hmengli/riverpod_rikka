import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:rikka/utils/logger.dart';

import '../parser_entity.dart';

// class ParseResult {
//   final String step1Content; // 第一步获取的原始HTML
//   final List<String> step1Items; // 第一步提取的链接/内容
//   final String step2Content; // 第二步获取的HTML（点击第一个链接）
//   final List<Map<String, String>> finalData; // 最终提取的数据

//   ParseResult({
//     required this.step1Content,
//     required this.step1Items,
//     required this.step2Content,
//     required this.finalData,
//   });
// }

/// 步骤执行函数签名：
///   - 输入：前一步的结果（第一步为 null）
// ignore: unintended_html_in_doc_comment
///   - 输出：Future<dynamic> 当前步骤的结果
typedef StepAction = Future<dynamic> Function(dynamic previousResult);

final parserServiceProvider = Provider<ParserService>((ref) {
  return ParserService();
});

class ParserService {
  // 执行完整的三步解析
  Future<String> parseWithConfig(
    String step1Url, {
    required ParserEntity entity,
    String? search,
  }) async {
    try {
      if (search != null) {
        step1Url = step1Url.replaceAll('@keyword', search);
      }
      return await fetchPage(uri: step1Url, parserEntity: entity);
    } catch (e) {
      throw Exception('网络错误，请检查网络: $e');
    }
  }

  // 获取页面HTML
  Future<String> fetchPage({
    required String uri,
    required ParserEntity parserEntity,
  }) async {
    Log.i('请求URL: $uri');
    Log.i('请求URL: ${parserEntity.cookie}');

    final response = await http.get(
      Uri.parse(uri),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml',
        'Referer': parserEntity.referer,
        'Cookie': parserEntity.cookie,
      },
    );

    if (response.statusCode == 200) {
      Log.i('请求URL: ${response.statusCode}');
      return response.body;
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  // 提取链接或内容
  List<Map<String, String?>> extractLinks1(
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
  List<List<Map<String, String>>> extractLinks2(
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
  String? extractLinks3(String html, {required String selector}) {
    final document = parser.parse(html);
    final elements = document.querySelector(selector);
    return elements?.attributes['src'].toString();
  }
}
