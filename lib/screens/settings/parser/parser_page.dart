import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/component/worker/work_widget.dart';
import 'package:rikka/screens/settings/parser/parser_repository.dart';
import 'package:rikka/utils/logger.dart';

import 'parser_entity.dart';
import 'parser_provide.dart';

class ParserPage extends ConsumerStatefulWidget {
  final VideoType videoType;
  const ParserPage({super.key, required this.videoType});

  @override
  ConsumerState<ParserPage> createState() => _ParserPageState();
}

class _ParserPageState extends ConsumerState<ParserPage> {
  @override
  Widget build(BuildContext context) {
    final parserList = ref.watch(parserListProvider).value;

    Log.d('data: $parserList');
    // provider.loadConfigs(type);
    return Scaffold(
      appBar: AppBar(
        title: Text('页面解析工具'),
        actions: [
          ElevatedButton(
            child: Icon(Icons.add),
            onPressed: () => _navToAdd(null),
          ),
        ],
      ),
      body: parserList == null || parserList.isEmpty
          ? Center(child: Text('点击右上角+添加配置'))
          : ListView.builder(
              itemCount: parserList.length,
              itemBuilder: (context, index) {
                return ParserCard(
                  entity: parserList[index],
                  editEntity: _navToAdd,
                );
              },
            ),
    );
  }

  void _navToAdd(ParserEntity? entity) {
    final notifier = ref.watch(parserProvider.notifier);
    Log.d('message: $notifier');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicFormWidget(
          type: VideoType.comics,
          onSaved: notifier.upsertParser,
          model: entity ?? ParserEntity(createdAt: DateTime.now()),
        ),
      ),
    );
  }
}

class ParserCard extends ConsumerWidget {
  final ParserEntity entity;
  final Function(ParserEntity) editEntity;
  const ParserCard({super.key, required this.entity, required this.editEntity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(parserProvider.notifier);
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(entity.name),
        subtitle: Text('URL: ${entity.basisUrl}'),
        onTap: () => editEntity(entity),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow, color: Colors.green),
              onPressed: () => _navigateToTest(context),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => notifier.deleteEntity(entity.name),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TestScreen(entity: entity)),
    );
  }
}

class TestScreen extends ConsumerStatefulWidget {
  final ParserEntity entity;
  const TestScreen({super.key, required this.entity});

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  final TextEditingController _keywordController = TextEditingController();

  List<Map<String, String?>> _resultsStep2 = [];
  List<List<Map<String, String>>> _resultsStep3 = [];

  List<StepConfig> stepConfigs() {
    List<StepConfig> stepConfigs = [];
    Log.i('cookie: ${widget.entity.cookie}');
    if (widget.entity.verify && widget.entity.cookie.isEmpty) {
      String step1Url = widget.entity.searchUrl;
      String vodName = _keywordController.text;
      step1Url = step1Url.replaceAll('@keyword', vodName);

      stepConfigs.addAll({
        StepConfig(
          id: 'loadingPage',
          title: '加载页面',
          action: (prev) async {
            final notifier = ref.read(cookieProvider.notifier);
            notifier.loadingPage(step1Url);
            await Future.delayed(Duration(seconds: 1));
          },
          errorMessage: ' 失败，请检查网络',
        ),
        StepConfig(
          id: 'getImage',
          title: '获取验证码',
          action: (prev) async {
            final notifier = ref.read(cookieProvider.notifier);
            return notifier.setScreenshot(widget.entity.verifyPng);
          },
          errorMessage: '登录失败，请检查网络',
          subtitle: (v) => GetImage(),
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
              input: widget.entity.verifyInput,
              submit: widget.entity.verifySubmit,
            );
            widget.entity.cookie = cookie ?? '';
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
            widget.entity.searchUrl,
            search: _keywordController.text,
            entity: widget.entity,
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
            titleSelector: widget.entity.searchTitle,
            hrefSelector: widget.entity.searchHref,
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
              '${widget.entity.basisUrl}${_resultsStep2.first['href']}',
              entity: widget.entity,
            );
            _resultsStep3 = parserService.extractLinks2(
              step3Html,
              selector: widget.entity.chapterRoad,
              selectorValue: widget.entity.chapterList,
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
    ref.watch(cookieProvider);
    return Scaffold(
      appBar: AppBar(title: Text('测试: ${widget.entity.basisUrl}')),
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

/// 表单字段类型
enum FieldType { text, number, email, password, date, textarea }

/// 单个字段的配置
// class FormFieldConfig {
//   final String key;
//   final String label;
//   final FieldType type;
//   final bool required;
//   final String? initialValue;
//   final String? Function(String?)? validator;
//   final void Function(dynamic model, String? value) setter;
//   final String? Function(dynamic model) getter;

//   const FormFieldConfig({
//     required this.key,
//     required this.label,
//     this.type = FieldType.text,
//     this.required = false,
//     this.initialValue,
//     this.validator,
//     required this.setter,
//     required this.getter,
//   });
// }

class DynamicFormWidget extends StatefulWidget {
  final VideoType type;
  final ParserEntity model;
  final void Function(VideoType, ParserEntity)? onSaved;
  final void Function(VideoType, ParserEntity)? onUpsert;

  const DynamicFormWidget({
    super.key,
    required this.type,
    required this.model,
    this.onSaved,
    this.onUpsert,
  });

  @override
  State<DynamicFormWidget> createState() => _DynamicFormWidgetState();
}

class _DynamicFormWidgetState extends State<DynamicFormWidget> {
  // late List<FormFieldConfig> _configs;
  late Map<String, TextEditingController> _controllers;
  // final Map<String, String?> _errors = {};

  bool verify = false;
  late TextEditingController verifyPng;
  late TextEditingController verifyInput;
  late TextEditingController verifySubmit;

  @override
  void initState() {
    super.initState();
    _controllers = widget.model.getFieldsEdit();
    Map<String, dynamic> token = widget.model.toJson();
    verify = token['verify'] ?? false;
    verifyPng = TextEditingController(text: token['verifyPng']);
    verifyInput = TextEditingController(text: token['verifyInput']);
    verifySubmit = TextEditingController(text: token['verifySubmit']);
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // void _validateField(FormFieldConfig cfg, String value) {
  //   final error = cfg.validator?.call(value);
  //   setState(() {
  //     if (error != null) {
  //       _errors[cfg.key] = error;
  //     } else {
  //       _errors.remove(cfg.key);
  //     }
  //   });
  // }

  void onUpsert() {
    widget.onUpsert?.call(widget.type, _save());
    Navigator.pop(context);
  }

  void onSaved() {
    Log.i('onSaved:');
    widget.onSaved?.call(widget.type, _save());
    Navigator.pop(context);
  }

  ParserEntity _save() {
    Map<String, dynamic> json = {
      'verify': verify,
      'verifyPng': verifyPng.text,
      'verifyInput': verifyInput.text,
      'verifySubmit': verifySubmit.text,
    };
    _controllers.forEach((key, value) {
      json.addAll({key: value.text});
    });
    Log.i('_save: $json');
    return widget.model.fromJson(json);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新增配置'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: () => _save)],
      ),
      body: Form(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            ..._controllers.keys.map(
              (key) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _controllers[key],
                  decoration: InputDecoration(
                    labelText: key,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                ),
              ),
            ),
            SwitchListTile(
              value: verify,
              onChanged: (value) {
                setState(() {
                  verify = value;
                });
              },
            ),
            if (verify)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: verifyPng,
                  decoration: InputDecoration(
                    labelText: 'verifyPng',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                ),
              ),
            if (verify)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: verifyInput,
                  decoration: InputDecoration(
                    labelText: 'verifyInput',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                ),
              ),
            if (verify)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: verifySubmit,
                  decoration: InputDecoration(
                    labelText: 'verifySubmit',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
      persistentFooterButtons: [
        ElevatedButton(onPressed: onUpsert, child: const Text('保存到云端')),
        ElevatedButton(onPressed: onSaved, child: const Text('保存配置')),
      ],
    );
  }

  // TextInputType _getKeyboardType(FieldType type) {
  //   switch (type) {
  //     case FieldType.number: return TextInputType.number;
  //     case FieldType.email: return TextInputType.emailAddress;
  //     case FieldType.textarea: return TextInputType.multiline;
  //     default: return TextInputType.text;
  //   }
  // }
}
