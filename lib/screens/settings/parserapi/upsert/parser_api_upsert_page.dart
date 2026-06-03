import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rikka/utils/logger.dart';
import 'package:rikka/utils/utils.dart';

import '../../assembly/dropdown_button.dart';
import '../comics_entity.dart';
import '../parser_api_entity.dart';
import '../parser_api_provide.dart';
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
    Log.i('onSaved:$entity');
    ref.read(parserApiProvider(widget.apiType).notifier).upsertParser(entity);
    context.pop();
  }

  ParserApiEntity _save() {
    final apiNotify = ref.read(apiUpsertProvider.notifier);
    apiNotify.setBasisUrl(_controllers['basisUrl']!.text);
    apiNotify.setDataRootPath(_controllers['dataRootPath']!.text);
    return ref.watch(apiUpsertProvider);
  }

  @override
  Widget build(BuildContext context) {
    final apiValue = ref.watch(apiUpsertProvider);
    final apiNotify = ref.read(apiUpsertProvider.notifier);
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
            GroupCard(
              children: [
                Padding(
                  padding: Utils.onlyPadding,
                  child: TextFormField(
                    controller: _controllers['basisUrl'],
                    decoration: InputDecoration(
                      labelText: 'basisUrl',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                ),
                Padding(
                  padding: Utils.onlyPadding,
                  child: SettingsDropdownButton<Methods>(
                    title: 'Method',
                    value: apiValue.method,
                    onChanged: apiNotify.setMethod,
                    items: Methods.values.map((toElement) {
                      return DropdownMenuItem<Methods>(
                        value: toElement,
                        child: Text(
                          toElement.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                DynamicAddWidget(title: 'header'),
              ],
            ),
            GroupCard(
              children: [
                Padding(
                  padding: Utils.onlyPadding,
                  child: TextFormField(
                    controller: _controllers['dataRootPath'],
                    decoration: InputDecoration(
                      labelText: 'dataRootPath',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                ),
                FieldMappingWidget(title: 'fieldMapping'),
              ],
            ),
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
    return Column(
      children: [
        TitleAddCard(title: title, onPressed: apiNotify.addHeaders),
        ...List.generate(headers.length, (index) {
          return DynamicAddCard(
            index: index,
            entity: headers[index],
            onPressed: () => apiNotify.removeHeaders(index),
          );
        }),
      ],
    );
  }
}

class GroupCard extends StatelessWidget {
  final List<Widget> children;

  const GroupCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Utils.onlyPadding,
      padding: Utils.onlyPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(children: children),
    );
  }
}

class TitleAddCard extends StatelessWidget {
  final String title;
  final void Function()? onPressed;

  const TitleAddCard({super.key, required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Utils.onlyPadding,
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
  final HeadersEntity entity;
  final void Function()? onPressed;

  const DynamicAddCard({
    super.key,
    required this.entity,
    required this.index,
    this.onPressed,
  });

  @override
  ConsumerState<DynamicAddCard> createState() => _DynamicAddCardState();
}

class _DynamicAddCardState extends ConsumerState<DynamicAddCard> {
  @override
  Widget build(BuildContext context) {
    Log.i('DynamicAddCard: ${widget.entity}');
    final apiNotify = ref.read(apiUpsertProvider.notifier);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Utils.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Utils.defaultPadding),
                  child: TextFormField(
                    onSaved: (v) =>
                        apiNotify.updateHeaders(widget.index, mKey: v),
                    initialValue: widget.entity.mKey,
                    decoration: InputDecoration(
                      labelText: 'key',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Utils.defaultPadding),
                  child: TextFormField(
                    onSaved: (v) =>
                        apiNotify.updateHeaders(widget.index, mValue: v),
                    initialValue: widget.entity.mValue,
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
    final fieldMappings = ref.watch(apiUpsertProvider).fieldMappings;
    final apiNotify = ref.read(apiUpsertProvider.notifier);
    Log.i('message: ${fieldMappings.length}');
    return Column(
      children: [
        TitleAddCard(title: widget.title, onPressed: apiNotify.addFieldMapping),
        ...List.generate(fieldMappings.length, (index) {
          return FieldMappingCard(index: index);
        }),
      ],
    );
  }
}

class FieldMappingCard extends ConsumerStatefulWidget {
  final int index;

  const FieldMappingCard({super.key, required this.index});

  @override
  ConsumerState<FieldMappingCard> createState() => _FieldMappingCardState();
}

class _FieldMappingCardState extends ConsumerState<FieldMappingCard> {
  @override
  Widget build(BuildContext context) {
    final fieldMappings = ref.watch(apiUpsertProvider).fieldMappings;
    final fieldsNotify = ref.read(apiUpsertProvider.notifier);
    final fields = fieldMappings[widget.index];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Utils.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Utils.defaultPadding),
                  child: SettingsDropdownButton<String>(
                    title: 'TargetField',
                    value: fields.targetField,
                    onChanged: (value) {
                      final updated = fields.copyWith(targetField: value);
                      fieldsNotify.updateFieldMapping(widget.index, updated);
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
                  padding: EdgeInsets.symmetric(vertical: Utils.defaultPadding),
                  child: SettingsDropdownButton<ValueSourceType>(
                    title: 'ValueSourceType',
                    value: fields.type,
                    onChanged: (value) {
                      final updated = fields.copyWith(type: value);
                      fieldsNotify.updateFieldMapping(widget.index, updated);
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
                  padding: EdgeInsets.symmetric(vertical: Utils.defaultPadding),
                  child: TextFormField(
                    initialValue: fields.sourcePath,
                    onSaved: (value) {
                      final updated = fields.copyWith(sourcePath: value);
                      fieldsNotify.updateFieldMapping(widget.index, updated);
                    },
                    decoration: InputDecoration(
                      labelText: 'sourcePath',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                ),
                DataTransFormWidget(
                  transforms: fields.transforms,
                  index: widget.index,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => fieldsNotify.removeFieldMapping(widget.index),
            icon: Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }
}

class DataTransFormWidget extends ConsumerStatefulWidget {
  final List<DataTransForm> transforms;
  final int index;

  const DataTransFormWidget({
    super.key,
    required this.transforms,
    required this.index,
  });

  @override
  ConsumerState<DataTransFormWidget> createState() =>
      _DataTransFormWidgetState();
}

class _DataTransFormWidgetState extends ConsumerState<DataTransFormWidget> {
  // 2. 添加新组件的方法
  void _addWidget(TransFormType type) {
    final typeList = ref.watch(transFormTypeListNotifyProvider(widget.index));
    final typeListNotify = ref.read(
      transFormTypeListNotifyProvider(widget.index).notifier,
    );
    final formNotify = ref.read(
      dataTransFormListNotifyProvider(widget.index).notifier,
    );
    final typeNotify = ref.read(
      transFormTypeNotifyProvider(widget.index).notifier,
    );
    switch (type) {
      case TransFormType.replace:
        formNotify.addDataTransForm(
          DataTransForm.replace(pattern: '', replacement: ''),
        );
      default:
        if (!widget.transforms.any((val) => val.type == type)) {
          formNotify.addDataTransForm(DataTransForm(type: type));
          typeNotify.setTransFormType(
            typeList.firstWhere((val) => val != type),
          );
          typeListNotify.removeTransFormType(type);
        }
    }
  }

  // 3. 删除组件（可选）
  void _removeWidget(int removeIndex, TransFormType element) {
    final typeListNotify = ref.read(
      transFormTypeListNotifyProvider(widget.index).notifier,
    );
    final formNotify = ref.watch(
      dataTransFormListNotifyProvider(widget.index).notifier,
    );
    formNotify.deleteDataTransForm(removeIndex);
    if (element != TransFormType.replace) {
      typeListNotify.addTransFormType(element);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeList = ref.watch(transFormTypeListNotifyProvider(widget.index));
    final transFormType = ref.watch(transFormTypeNotifyProvider(widget.index));
    final typeNotify = ref.read(
      transFormTypeNotifyProvider(widget.index).notifier,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: Utils.defaultPadding),
          child: Row(
            children: [
              Expanded(
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
              IconButton(
                onPressed: () => _addWidget(transFormType),
                icon: Icon(Icons.add_circle),
              ),
            ],
          ),
        ),
        ...List.generate(widget.transforms.length, (i) {
          return getDataTransForm(fromIndex: i);
        }),
      ],
    );
  }

  Widget getDataTransForm({required int fromIndex}) {
    final formNotify = ref.watch(
      dataTransFormListNotifyProvider(widget.index).notifier,
    );

    DataTransForm dynamic = widget.transforms[fromIndex];
    switch (dynamic.type) {
      case TransFormType.replace:
        return Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Utils.defaultPadding,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.blue,
                      alignment: AlignmentGeometry.centerStart,
                      child: Text(dynamic.type.name),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Utils.defaultPadding,
                    ),
                    child: TextFormField(
                      initialValue: dynamic.pattern,
                      onSaved: (val) {
                        formNotify.updatePattern(fromIndex, val ?? '');
                      },
                      decoration: InputDecoration(
                        labelText: 'pattern',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Utils.defaultPadding,
                    ),
                    child: TextFormField(
                      initialValue: dynamic.replacement,
                      onSaved: (val) {
                        formNotify.updateReplacement(fromIndex, val ?? '');
                      },
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
              onPressed: () => _removeWidget(fromIndex, dynamic.type),
              icon: Icon(Icons.remove_circle_outline),
            ),
          ],
        );
      default:
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Utils.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue,
              alignment: AlignmentGeometry.centerStart,
              child: Text(dynamic.type.name, overflow: TextOverflow.ellipsis),
            ),
          ),
          IconButton(
            onPressed: () => _removeWidget(fromIndex, dynamic.type),
            icon: Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }
}
