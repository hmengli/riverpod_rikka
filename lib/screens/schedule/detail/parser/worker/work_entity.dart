import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'work_entity.freezed.dart';

enum StepStatus { idle, loading, success, error }

// typedef StepAction = Future<dynamic> Function(dynamic previousResult);

typedef StepContext = Future Function(dynamic previousResult);

@freezed
abstract class StepStateModel with _$StepStateModel {
  const factory StepStateModel({
    required StepStatus status,
    dynamic result,
    String? error,
  }) = _StepStateModel;
}

@freezed
abstract class StepConfig with _$StepConfig {
  const factory StepConfig({
    required String id, // 唯一标识
    required String title, // 展示用的标题
    required StepContext action, // 执行的异步逻辑，接收上一步结果，返回当前步结果
    Widget Function(dynamic res)? subtitle, // 执行的异步逻辑，接收上一步结果，返回当前步结果
    String? errorMessage, // 可自定义的错误提示（若不提供，则使用异常信息）
  }) = _StepConfig;
}

@freezed
abstract class WorkflowState with _$WorkflowState {
  const factory WorkflowState({
    required List<StepConfig> steps,
    required List<StepStateModel> states,
  }) = _WorkflowState;

  /// 根据配置初始化状态（全部 idle）
  factory WorkflowState.fromConfigs(List<StepConfig> configs) {
    return WorkflowState(
      steps: configs,
      states: configs
          .map((_) => StepStateModel(status: StepStatus.idle))
          .toList(),
    );
  }
}
