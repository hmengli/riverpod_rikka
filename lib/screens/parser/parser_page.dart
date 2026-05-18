import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/parser/parser_repository.dart';
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
    // final VideoType type = widget.videoType;
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

class TestScreen extends StatefulWidget {
  final ParserEntity entity;
  const TestScreen({super.key, required this.entity});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TextEditingController _keywordController = TextEditingController();

  bool _isRunning = false;
  String _resultsStep1 = '';
  List<Map<String, String?>> _resultsStep2 = [];
  List<List<Map<String, String>>> _resultsStep3 = [];

  void _resetTasks() {
    _resultsStep1 = '';
    _resultsStep2 = [];
    _resultsStep3 = [];
  }

  Future<void> _startTasks() async {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _resetTasks();
    });
    try {
      _resultsStep1 = await ParserService.parseWithConfig(
        widget.entity.searchUrl,
        widget.entity,
        search: _keywordController.text,
      );
      setState(() {});

      _resultsStep2 = ParserService.extractLinks1(
        _resultsStep1,
        titleSelector: widget.entity.searchTitle,
        hrefSelector: widget.entity.searchHref,
      );
      Log.i('$_resultsStep2');
      setState(() {});

      if (_resultsStep2.isNotEmpty) {
        String step3Html = await ParserService.parseWithConfig(
          '${widget.entity.basisUrl}${_resultsStep2.first['href']}',
          widget.entity,
        );

        _resultsStep3 = ParserService.extractLinks2(
          step3Html,
          selector: widget.entity.chapterRoad,
          selectorValue: widget.entity.chapterList,
        );
      }
      Log.i('$_resultsStep3');
    } catch (e) {
      _resultsStep1 = '网络错误，请检查网络';
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('测试: ${widget.entity.basisUrl}')),
      body: Column(
        children: [
          Padding(
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
                ElevatedButton(
                  onPressed: _isRunning ? null : _startTasks,
                  child: Text('搜索'),
                ),
              ],
            ),
          ),
          Expanded(child: showResults(_resultsStep1)),
          Expanded(child: showResults(_resultsStep2)),
          Expanded(child: showResults(_resultsStep3)),
        ],
      ),
    );
  }

  Widget showResults(dynamic results) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        results.toString(),
        style: TextStyle(fontSize: 16, height: 1.5),
      ),
    );
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
