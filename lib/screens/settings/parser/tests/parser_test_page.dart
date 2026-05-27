import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/component/worker/work_widget.dart';
import 'package:rikka/screens/settings/parser/parser_entity.dart';
import 'package:rikka/utils/logger.dart';

import 'parser_repository.dart';
import 'parser_test_provide.dart';

class ParserTestPage extends ConsumerStatefulWidget {
  final ParserEntity? entity;
  const ParserTestPage({super.key, required this.entity});

  @override
  ConsumerState<ParserTestPage> createState() => _ParserTestPageState();
}

class _ParserTestPageState extends ConsumerState<ParserTestPage> {
  final TextEditingController _keywordController = TextEditingController();

  List<Map<String, String?>> _resultsStep2 = [];
  List<List<Map<String, String>>> _resultsStep3 = [];

  List<StepConfig> stepConfigs() {
    ParserEntity entity =
        widget.entity ?? ParserEntity(createdAt: DateTime.now());
    List<StepConfig> stepConfigs = [];
    Log.i('cookie: ${entity.cookie}');

    if (entity.verify && entity.cookie.isEmpty) {
      String step1Url = entity.searchUrl;
      String vodName = _keywordController.text;
      step1Url = step1Url.replaceAll('@keyword', vodName);

      stepConfigs.addAll({
        StepConfig(
          id: 'loadingPage',
          title: '加载页面',
          action: (prev) async {
            final notifier = ref.read(cookieProvider.notifier);
            return notifier.loadingPage(step1Url, entity.verifyPng);
          },
          subtitle: (v) => GetImage(),
          errorMessage: ' 失败，请检查网络',
        ),
        StepConfig(
          id: 'parserImage',
          title: '解析验证码',
          action: (prev) async {
            return ref.read(getCodeProvider.notifier).getCode(prev);
          },
          subtitle: (v) => ParserImage(),
          errorMessage: '登录失败，请检查网络',
        ),
        StepConfig(
          id: 'parserCookie',
          title: '获取Cookie',
          action: (prev) async {
            final notifier = ref.read(cookieProvider.notifier);
            final cookie = await notifier.parserCookie(
              prev,
              input: entity.verifyInput,
              submit: entity.verifySubmit,
            );
            entity.cookie = cookie ?? '';
            await Future.delayed(Duration(seconds: 4));
          },
          subtitle: (v) {
            return Center(child: Text(v.toString(), maxLines: 3));
          },
          errorMessage: '登录失败，请检查网络',
        ),
      });
    }
    stepConfigs.addAll({
      StepConfig(
        id: 'login',
        title: '页面验证',
        action: (prev) async {
          final parserService = ref.read(parserServiceProvider);
          String resultsStep1 = await parserService.parseWithConfig(
            entity.searchUrl,
            search: _keywordController.text,
            entity: entity,
          );
          if (resultsStep1.isNotEmpty) return resultsStep1;
          throw Exception("数据异常");
        },
        subtitle: (v) {
          return Center(child: Text(v.toString(), maxLines: 3));
        },
        errorMessage: '登录失败，请检查网络',
      ),
      StepConfig(
        id: 'fetch_data',
        title: '获取数据列表',
        action: (prev) async {
          final parserService = ref.read(parserServiceProvider);
          _resultsStep2 = parserService.extractLinks1(
            prev,
            titleSelector: entity.searchTitle,
            hrefSelector: entity.searchHref,
          );
          return _resultsStep2;
        },
        subtitle: (v) {
          return Center(child: Text(v.toString(), maxLines: 3));
        },
        // errorMessage: '获取数据出错，可自定义', // 可选
      ),
      StepConfig(
        id: 'process',
        title: '获取播放列表',
        action: (prev) async {
          if (_resultsStep2.isNotEmpty) {
            final parserService = ref.read(parserServiceProvider);
            String step3Html = await parserService.parseWithConfig(
              '${entity.basisUrl}${_resultsStep2.first['href']}',
              entity: entity,
            );
            _resultsStep3 = parserService.extractLinks2(
              step3Html,
              selector: entity.chapterRoad,
              selectorValue: entity.chapterList,
            );
          }
          return _resultsStep3;
        },
        subtitle: (v) {
          return Center(child: Text(v.toString(), maxLines: 3));
        },
      ),
    });

    return stepConfigs;
  }

  @override
  Widget build(BuildContext context) {
    ParserEntity entity =
        widget.entity ?? ParserEntity(createdAt: DateTime.now());
    Log.i("ParserTestPage");
    ref.watch(cookieProvider);
    return Scaffold(
      appBar: AppBar(title: Text('测试: ${entity.basisUrl}')),
      body: WorkWidget(
        state: stepConfigs(),
        builder: (Function aexcute) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: InputDecoration(
                      hintText: '输入搜索关键词',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: () => aexcute(), child: Text('搜索')),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GetImage extends ConsumerWidget {
  const GetImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(cookieProvider);
    return image != null
        ? Image.memory(image, width: 200, height: 50)
        : CircularProgressIndicator();
  }
}

class ParserImage extends ConsumerWidget {
  const ParserImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(getCodeProvider);
    return Center(child: Text(code));
  }
}
