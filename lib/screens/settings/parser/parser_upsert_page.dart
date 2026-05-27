import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'parser_entity.dart';
import 'parser_provide.dart';

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

class ParserUpsertPage extends ConsumerStatefulWidget {
  final VideoType videoType;
  final ParserEntity? model;
  const ParserUpsertPage({super.key, this.model, required this.videoType});

  @override
  ConsumerState<ParserUpsertPage> createState() => _ParserUpsertPageState();
}

class _ParserUpsertPageState extends ConsumerState<ParserUpsertPage> {
  bool verify = false;
  String title = '';
  late final ParserEntity entity;

  late Map<String, TextEditingController> _controllers;
  late TextEditingController verifyPng;
  late TextEditingController verifyInput;
  late TextEditingController verifySubmit;

  @override
  void initState() {
    super.initState();
    title = widget.model == null ? "新增配置" : "修改配置";
    entity = widget.model ?? ParserEntity(createdAt: DateTime.now());
    _controllers = entity.getFieldsEdit();
    Map<String, dynamic> token = entity.toJson();
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
    verifyPng.dispose();
    verifyInput.dispose();
    verifySubmit.dispose();
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
    context.pop();
  }

  void onSaved() {
    final notifier = ref.read(parserProvider(widget.videoType).notifier);
    notifier.upsertParser(_save());
    context.pop();
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
    return entity.fromJson(json);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
}
