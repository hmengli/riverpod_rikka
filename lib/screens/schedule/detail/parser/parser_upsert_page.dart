import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'parser_entity.dart';

class ParserUpsertArgs {
  final ParserEntity? entity;
  final void Function(ParserEntity) upsert;

  const ParserUpsertArgs({this.entity, required this.upsert});
}

class ParserUpsertPage extends ConsumerStatefulWidget {
  final VideoType videoType;
  final ParserUpsertArgs? model;
  const ParserUpsertPage({super.key, this.model, required this.videoType});

  @override
  ConsumerState<ParserUpsertPage> createState() => _ParserUpsertPageState();
}

class _ParserUpsertPageState extends ConsumerState<ParserUpsertPage> {
  String title = '';
  bool verify = false;
  late final ParserEntity entity;

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _verify = {};

  @override
  void initState() {
    super.initState();
    title = widget.model == null ? "新增配置" : "修改配置";
    entity = widget.model?.entity ?? ParserEntity(videoType: widget.videoType);
    _controllers.addAll({
      'name': TextEditingController(text: entity.name),
      'basisUrl': TextEditingController(text: entity.basisUrl),
      'searchUrl': TextEditingController(text: entity.searchUrl),
      'searchHref': TextEditingController(text: entity.searchHref),
      'searchTitle': TextEditingController(text: entity.searchTitle),
      'chapterRoad': TextEditingController(text: entity.chapterRoad),
      'chapterList': TextEditingController(text: entity.chapterList),
      'selectorM3u8': TextEditingController(text: entity.selectorM3u8),
      'selectorVideo': TextEditingController(text: entity.selectorVideo),
    });
    verify = entity.verify;
    _verify.addAll({
      'verifyPng': TextEditingController(text: entity.verifyPng),
      'verifyInput': TextEditingController(text: entity.verifyInput),
      'verifySubmit': TextEditingController(text: entity.verifySubmit),
    });
  }

  @override
  void dispose() {
    for (var action in _controllers.values) {
      action.dispose();
    }
    for (var action in _verify.values) {
      action.dispose();
    }
    super.dispose();
  }

  void onUpsert() {
    if (!_formKey.currentState!.validate()) return;
    widget.model?.upsert(_save());
    context.pop();
  }

  ParserEntity _save() {
    Map<String, dynamic> json = {};
    _controllers.forEach(((key, value) => json.addAll({key: value.text})));
    if (verify) {
      json.addAll({'verify': verify});
      _verify.forEach(((key, value) => json.addAll({key: value.text})));
    }
    return ParserEntity.fromJson(json);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: () => _save)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            ...buildField(_controllers),
            SwitchListTile(
              title: Text('verify'),
              value: verify,
              onChanged: (value) {
                setState(() {
                  verify = value;
                });
              },
            ),
            if (verify) ...buildField(_verify),
          ],
        ),
      ),
      persistentFooterButtons: [
        ElevatedButton(onPressed: onUpsert, child: const Text('保存配置')),
      ],
    );
  }

  List<Widget> buildField(Map<String, TextEditingController> list) {
    return list.keys.map((field) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: list[field],
          decoration: InputDecoration(
            labelText: field,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          maxLines: 1,
        ),
      );
    }).toList();
  }
}
