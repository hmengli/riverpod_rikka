import 'package:rikka/logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../parser_api_entity.dart';

part 'parser_api_upsert_provide.g.dart';

@riverpod
class ApiUpsertNotifier extends _$ApiUpsertNotifier {
  @override
  ParserApiEntity build() {
    ref.keepAlive();
    return ParserApiEntity();
  }

  // 修改单个字段的便捷方法
  void setState(ParserApiEntity entity) {
    Log.i('setState: $entity');
    state = entity;
  }

  // 修改单个字段的便捷方法
  void setBasisUrl(String url) {
    state = state.copyWith(basisUrl: url);
  }

  void setMethod(Methods method) {
    state = state.copyWith(method: method);
  }

  void setDataRootPath(String path) {
    state = state.copyWith(dataRootPath: path);
  }

  void addHeaders() {
    state = state.copyWith(
      headers: [
        ...state.headers,
        HeadersEntity(mKey: ''),
      ],
    );
  }

  void updateHeaders(int index, {String? mKey, dynamic mValue}) {
    Log.i('updateHeaders: $index,$mKey,$mValue');

    final currentHeader = state.headers[index];
    HeadersEntity? updatedHeader;
    if (mKey != null) {
      updatedHeader = currentHeader.copyWith(mKey: mKey);
    } else if (mValue != null) {
      updatedHeader = currentHeader.copyWith(mValue: mValue);
    }
    if (updatedHeader == null || updatedHeader == currentHeader) return;
    final newHeaders = List<HeadersEntity>.from(state.headers);
    newHeaders[index] = updatedHeader;
    state = state.copyWith(headers: newHeaders);
  }

  void removeHeaders(int index) {
    final newHeaders = List<HeadersEntity>.from(state.headers);
    newHeaders.removeAt(index);
    state = state.copyWith(headers: newHeaders);
  }

  void addFieldMapping() {
    state = state.copyWith(
      fieldMappings: [...state.fieldMappings, FieldMapping()],
    );
  }

  void updateFieldMapping(int index, FieldMapping updatedMapping) {
    state = state.copyWith(
      fieldMappings: [
        for (int i = 0; i < state.fieldMappings.length; i++)
          if (i == index) updatedMapping else state.fieldMappings[i],
      ],
    );
  }

  void removeFieldMapping(int index) {
    final newList = List<FieldMapping>.from(state.fieldMappings);
    newList.removeAt(index);
    state = state.copyWith(fieldMappings: newList);
  }

  // // 整体替换状态
  // void setState(ParserApiEntity newState) {
  //   state = newState;
  // }
}

@riverpod
class DataTransFormListNotify extends _$DataTransFormListNotify {
  late FieldMapping fieldMappings;
  late ApiUpsertNotifier fieldsNotify;

  @override
  List<DataTransForm> build(int index) {
    fieldsNotify = ref.read(apiUpsertProvider.notifier);
    fieldMappings = ref.watch(apiUpsertProvider).fieldMappings[index];
    return fieldMappings.transforms;
  }

  void addDataTransForm(DataTransForm element) {
    state = [...state, element];
    final updated = fieldMappings.copyWith(transforms: state);
    fieldsNotify.updateFieldMapping(index, updated);
  }

  void upDataTransForm(int upIndex, DataTransForm element) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) element else state[i],
    ];
    final updated = fieldMappings.copyWith(transforms: state);
    fieldsNotify.updateFieldMapping(index, updated);
  }

  void deleteDataTransForm(int deleteIndex) {
    final newList = List<DataTransForm>.from(state);
    newList.removeAt(deleteIndex);
    state = newList;
    final updated = fieldMappings.copyWith(transforms: state);
    fieldsNotify.updateFieldMapping(index, updated);
  }

  void updatePattern(int fromIndex, String pattern) {
    DataTransForm updateForm = state[fromIndex].copyWith(pattern: pattern);
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) updateForm else state[i],
    ];
    final updated = fieldMappings.copyWith(transforms: state);
    fieldsNotify.updateFieldMapping(index, updated);
  }

  void updateReplacement(int fromIndex, String replacement) {
    DataTransForm updateForm = state[fromIndex].copyWith(
      replacement: replacement,
    );
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) updateForm else state[i],
    ];
    final updated = fieldMappings.copyWith(transforms: state);
    fieldsNotify.updateFieldMapping(index, updated);
  }
}

@riverpod
class TransFormTypeNotify extends _$TransFormTypeNotify {
  // 初始状态：未登录，加载完成
  @override
  TransFormType build(int index) {
    return TransFormType.trim;
  }

  void setTransFormType(TransFormType element) {
    state = element;
  }
}

@riverpod
class TransFormTypeListNotify extends _$TransFormTypeListNotify {
  // 初始状态：未登录，加载完成
  @override
  List<TransFormType> build(int index) {
    return [
      TransFormType.trim,
      TransFormType.unescape,
      TransFormType.removeWhitespace,
      TransFormType.replace,
    ];
  }

  void addTransFormType(TransFormType element) {
    state = [...state, element];
  }

  void removeTransFormType(TransFormType element) {
    state = [
      for (var action in state)
        if (element != action) action,
    ];
  }
}
