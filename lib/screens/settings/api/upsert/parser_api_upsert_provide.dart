import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../parser_api_entity.dart';

part 'parser_api_upsert_provide.g.dart';

@riverpod
class ApiUpsertNotifier extends _$ApiUpsertNotifier {
  @override
  ParserApiEntity build() {
    return ParserApiEntity();
  }

  // 修改单个字段的便捷方法
  void setParserApi(ParserApiEntity entity) {
    state = entity;
  }

  // 修改单个字段的便捷方法
  void setBasisUrl(String url) {
    state = state.copyWith(basisUrl: url);
  }

  void setMethod(String method) {
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

// @riverpod
// class FieldMappingNotify extends _$FieldMappingNotify {
//   late List<FieldMapping> fieldMappings;
//
//   @override
//   FieldMapping build(int index) {
//     fieldMappings = ref.watch(apiUpsertProvider).fieldMappings;
//     return fieldMappings[index];
//   }
//
//   void setTargetField(String? element) {
//     Log.i('setTargetField: $element');
//     state = state.copyWith(targetField: element);
//   }
//
//   void setValueSourceType(ValueSourceType element) {
//     state = state.copyWith(type: element);
//   }
//
//   void setSourcePath(String? element) {
//     state = state.copyWith(sourcePath: element);
//   }
// }

@riverpod
class DataTransFormListNotify extends _$DataTransFormListNotify {
  late FieldMapping fieldMappings;
  late ApiUpsertNotifier fieldsNotify;

  // 初始状态：未登录，加载完成
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

  void deleteDataTransForm(int index) {
    final newList = List<DataTransForm>.from(state);
    newList.removeAt(index);
    state = newList;
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

// class DataTransFormNotify extends _$DataTransFormNotify {
//   @override
//   List<DataTransForm> build() {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }

// @riverpod
// class DynamicListNotify extends _$DynamicListNotify {
//   // 初始状态：未登录，加载完成
//   @override
//   List<HeadersEntity> build(List<HeadersEntity> headers) {
//     return headers;
//   }
//
//   // 2. 添加新组件的方法
//   void addWidget() {
//     state = [...state, HeadersEntity(mKey: '')]; // 创建新列表
//   }
//
//   // 3. 删除组件（可选）
//   void removeWidget(HeadersEntity entity) {
//     state = state.where((e) => e != entity).toList(); // 新列表
//   }
// }

// @riverpod
// class ValueSourceTypeNotify extends _$ValueSourceTypeNotify {
//   // 初始状态：未登录，加载完成
//   @override
//   ValueSourceType build(int index) {
//     return ValueSourceType.direct;
//   }
// }
