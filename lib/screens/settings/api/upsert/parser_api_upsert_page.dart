import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rikka/utils/logger.dart';
import 'package:rikka/utils/utils.dart';

import '../../settings_page.dart';
import '../comics_entity.dart';
import '../parser_api_entity.dart';
import 'parser_api_upsert_provide.dart';

/// 表单字段类型
enum FieldType { text, number, email, password, date, textarea }

class ParserApiUpsertPage extends ConsumerStatefulWidget {
  final ApiType apiType;
  final ParserApiEntity? entity;

  const ParserApiUpsertPage({super.key, required this.apiType, this.entity});

  @override
  ConsumerState<ParserApiUpsertPage> createState() =>
      _ParserApiUpsertPageState();
}

class _ParserApiUpsertPageState extends ConsumerState<ParserApiUpsertPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  late final ParserApiEntity entity;

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    title = widget.entity == null ? "新增配置" : "修改配置";
    entity = widget.entity ?? ParserApiEntity();
    _controllers.addAll({
      'basisUrl': TextEditingController(text: entity.basisUrl),
      'method': TextEditingController(text: entity.method),
      'dataRootPath': TextEditingController(text: entity.dataRootPath),
    });
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void onSaved() {
    _formKey.currentState?.save();
    ParserApiEntity entity = _save();
    Log.i('message: $entity');
    context.pop();
  }

  ParserApiEntity _save() {
    final apiNotify = ref.read(apiUpsertProvider.notifier);
    apiNotify.setBasisUrl(_controllers['basisUrl']!.text);
    apiNotify.setMethod(_controllers['method']!.text);
    apiNotify.setDataRootPath(_controllers['dataRootPath']!.text);
    return ref.watch(apiUpsertProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // actions: [IconButton(icon: Icon(Icons.save), onPressed: () => _save)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Container(
              padding: Utils.onlyPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Column(
                children: [
                  ..._controllers.keys.map(
                    (key) => Padding(
                      padding: EdgeInsets.only(bottom: Utils.defaultPadding),
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
                ],
              ),
            ),
            DynamicAddWidget(title: 'header'),
            FieldMappingWidget(title: 'fieldMapping'),
          ],
        ),
      ),
      persistentFooterButtons: [
        ElevatedButton(onPressed: onSaved, child: const Text('保存配置')),
      ],
    );
  }
}

class DynamicAddWidget extends ConsumerWidget {
  final String title;

  const DynamicAddWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headers = ref.watch(apiUpsertProvider).headers;
    final apiNotify = ref.read(apiUpsertProvider.notifier);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Utils.defaultPadding),
      child: Column(
        children: [
          TitleAddCard(title: title, onPressed: apiNotify.addHeaders),
          ...List.generate(headers.length, (index) {
            return DynamicAddCard(
              index: index,
              dynamic: headers[index],
              onPressed: () => apiNotify.removeHeaders(index),
            );
          }),
        ],
      ),
    );
  }
}

class TitleAddCard extends StatelessWidget {
  final String title;
  final void Function()? onPressed;

  const TitleAddCard({super.key, required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(77, 146, 136, 136),
              ),
              padding: EdgeInsets.all(16),
              child: Text(title),
            ),
          ),
          IconButton(onPressed: onPressed, icon: Icon(Icons.add_circle)),
        ],
      ),
    );
  }
}

class DynamicAddCard extends ConsumerStatefulWidget {
  final int index;
  final HeadersEntity dynamic;
  final void Function()? onPressed;

  const DynamicAddCard({
    super.key,
    required this.dynamic,
    required this.index,
    this.onPressed,
  });

  @override
  ConsumerState<DynamicAddCard> createState() => _DynamicAddCardState();
}

class _DynamicAddCardState extends ConsumerState<DynamicAddCard> {
  @override
  Widget build(BuildContext context) {
    final apiNotify = ref.read(apiUpsertProvider.notifier);
    return Container(
      padding: Utils.onlyPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: Utils.defaultPadding),
                  child: TextFormField(
                    onSaved: (v) =>
                        apiNotify.updateHeaders(widget.index, mKey: v),
                    initialValue: widget.dynamic.mKey,
                    decoration: InputDecoration(
                      labelText: 'key',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: Utils.defaultPadding),
                  child: TextFormField(
                    onSaved: (v) =>
                        apiNotify.updateHeaders(widget.index, mValue: v),
                    initialValue: widget.dynamic.mValue,
                    decoration: InputDecoration(
                      labelText: 'value',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onPressed,
            icon: Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }
}

class FieldMappingWidget extends ConsumerStatefulWidget {
  final String title;

  const FieldMappingWidget({super.key, required this.title});

  @override
  ConsumerState<FieldMappingWidget> createState() => _FieldMappingWidgetState();
}

class _FieldMappingWidgetState extends ConsumerState<FieldMappingWidget> {
  @override
  Widget build(BuildContext context) {
    final dynamicList = ref.watch(apiUpsertProvider).fieldMappings;
    final apiNotify = ref.read(apiUpsertProvider.notifier);
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          TitleAddCard(
            title: widget.title,
            onPressed: apiNotify.addFieldMapping,
          ),
          ...List.generate(dynamicList.length, (index) {
            return FieldMappingCard(
              index: index,
              dynamic: dynamicList[index],
              onPressed: () => apiNotify.removeFieldMapping(index),
            );
          }),
        ],
      ),
    );
  }
}

class FieldMappingCard extends ConsumerWidget {
  final int index;
  final FieldMapping dynamic;
  final void Function()? onPressed;

  const FieldMappingCard({
    super.key,
    required this.dynamic,
    this.onPressed,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(apiUpsertProvider).fieldMappings[index];
    final fieldsNotify = ref.read(apiUpsertProvider.notifier);
    return Container(
      padding: Utils.onlyPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: Utils.defaultPadding),
                  child: SettingsDropdownButton<String>(
                    title: 'TargetField',
                    value: fields.targetField,
                    onChanged: (value) {
                      final updated = fields.copyWith(targetField: value);
                      fieldsNotify.updateFieldMapping(index, updated);
                    },
                    items: ComicsEntity.list.map((toElement) {
                      return DropdownMenuItem<String>(
                        value: toElement,
                        child: Text(toElement, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: Utils.defaultPadding),
                  child: SettingsDropdownButton<ValueSourceType>(
                    title: 'ValueSourceType',
                    value: fields.type,
                    onChanged: (value) {
                      final updated = fields.copyWith(type: value);
                      fieldsNotify.updateFieldMapping(index, updated);
                    },
                    items: ValueSourceType.values.map((toElement) {
                      return DropdownMenuItem<ValueSourceType>(
                        value: toElement,
                        child: Text(
                          toElement.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: Utils.defaultPadding),
                  child: TextFormField(
                    initialValue: fields.sourcePath,
                    onSaved: (value) {
                      final updated = fields.copyWith(sourcePath: value);
                      fieldsNotify.updateFieldMapping(index, updated);
                    },
                    decoration: InputDecoration(
                      labelText: 'sourcePath',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                ),
                DataTransFormWidget(title: 'DataTransform', index: index),
              ],
            ),
          ),
          IconButton(
            onPressed: onPressed,
            icon: Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }
}

class DataTransFormWidget extends ConsumerStatefulWidget {
  final String title;
  final int index;

  const DataTransFormWidget({
    super.key,
    required this.title,
    required this.index,
  });

  @override
  ConsumerState<DataTransFormWidget> createState() =>
      _DataTransFormWidgetState();
}

class _DataTransFormWidgetState extends ConsumerState<DataTransFormWidget> {
  final List<DataTransForm> dynamicList = [];
  List<TransFormType> typeList = [];

  @override
  void initState() {
    super.initState();
    typeList.addAll([
      TransFormType.trim,
      TransFormType.unescape,
      TransFormType.removeWhitespace,
      TransFormType.replace,
    ]);
  }

  // 2. 添加新组件的方法
  void _addWidget(TransFormType type) {
    final formNotify = ref.read(
      dataTransFormListNotifyProvider(widget.index).notifier,
    );
    final formList = ref.watch(dataTransFormListNotifyProvider(widget.index));
    final typeNotify = ref.read(
      transFormTypeNotifyProvider(widget.index).notifier,
    );
    switch (type) {
      case TransFormType.replace:
        formNotify.addDataTransForm(
          DataTransForm.replace(pattern: '', replacement: ''),
        );
      case TransFormType.unescape:
      case TransFormType.trim:
      case TransFormType.removeWhitespace:
        if (!formList.any((val) => val.type == type)) {
          dynamicList.add(DataTransForm(type: type));
          typeNotify.setTransFormType(
            typeList.firstWhere((val) => val != type),
          );
          typeList.remove(type);
        }
    }

    setState(() {});
  }

  // 3. 删除组件（可选）
  void _removeWidget(DataTransForm element) {
    final formNotify = ref.watch(
      dataTransFormListNotifyProvider(widget.index).notifier,
    );
    formNotify.deleteDataTransForm(widget.index);
    if (element.type != TransFormType.replace) {
      typeList.add(element.type);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final transFormType = ref.watch(transFormTypeNotifyProvider(widget.index));
    final typeNotify = ref.read(
      transFormTypeNotifyProvider(widget.index).notifier,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: Utils.defaultPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: Utils.defaultPadding),
                  child: SettingsDropdownButton<TransFormType>(
                    title: 'TransFormType',
                    value: transFormType,
                    onChanged: (v) => typeNotify.setTransFormType(v),
                    items: typeList.map((toElement) {
                      return DropdownMenuItem<TransFormType>(
                        value: toElement,
                        child: Text(
                          toElement.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _addWidget(transFormType),
                icon: Icon(Icons.add_circle),
              ),
            ],
          ),
          ...dynamicList.map((card) {
            return DataTransFormCard(
              dynamic: card,
              onPressed: () => _removeWidget(card),
            );
          }),
        ],
      ),
    );
  }
}

class DataTransFormCard extends ConsumerStatefulWidget {
  final DataTransForm dynamic;
  final void Function()? onPressed;

  const DataTransFormCard({super.key, required this.dynamic, this.onPressed});

  @override
  ConsumerState<DataTransFormCard> createState() => _DataTransFormCardState();
}

class _DataTransFormCardState extends ConsumerState<DataTransFormCard> {
  late TextEditingController pattern;
  late TextEditingController replacement;

  @override
  void initState() {
    super.initState();
    pattern = TextEditingController(text: widget.dynamic.pattern);
    replacement = TextEditingController(text: widget.dynamic.replacement);
  }

  @override
  void dispose() {
    pattern.dispose();
    replacement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.zero, child: get(widget.dynamic));
  }

  Widget get(DataTransForm e) {
    switch (e.type) {
      case TransFormType.replace:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: Utils.defaultPadding),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.blue,
                      alignment: AlignmentGeometry.centerStart,
                      child: Text(e.type.toString()),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: Utils.defaultPadding),
                    child: TextFormField(
                      controller: pattern,
                      decoration: InputDecoration(
                        labelText: 'pattern',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: Utils.defaultPadding),
                    child: TextFormField(
                      controller: replacement,
                      decoration: InputDecoration(
                        labelText: 'replacement',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: widget.onPressed,
              icon: Icon(Icons.remove_circle_outline),
            ),
          ],
        );
      case TransFormType.unescape:
      case TransFormType.trim:
      case TransFormType.removeWhitespace:
    }
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: Utils.defaultPadding),
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue,
              alignment: AlignmentGeometry.centerStart,
              child: Text(e.type.toString(), overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
        IconButton(
          onPressed: widget.onPressed,
          icon: Icon(Icons.remove_circle_outline),
        ),
      ],
    );
  }
}
