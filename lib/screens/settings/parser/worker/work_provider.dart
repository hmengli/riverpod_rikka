import 'package:rikka/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'work_widget.dart';
part 'work_provider.g.dart';

enum StepStatus { idle, loading, success, error }

class StepStateModel {
  final StepStatus status;
  final dynamic result;
  final String? error;

  StepStateModel({required this.status, this.result, this.error});

  StepStateModel copyWith({StepStatus? status, dynamic result, String? error}) {
    return StepStateModel(
      status: status ?? this.status,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

class WorkflowState {
  final List<StepConfig> steps;
  final List<StepStateModel> states; // 对应每个步骤的运行时状态
  WorkflowState({required this.steps, required this.states});

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

@riverpod
class WorkflowNotifier extends _$WorkflowNotifier {
  @override
  WorkflowState build() {
    return WorkflowState(steps: [], states: []);
  }

  /// 设置流程配置（会重置整个流程）
  void setup(List<StepConfig> configs) {
    state = WorkflowState.fromConfigs(configs);
  }

  /// 执行整个流程
  Future<void> run() async {
    if (state.steps.isEmpty) return;
    Log.i('message: ${state.steps.length}');

    dynamic previousResult;
    for (int i = 0; i < state.steps.length; i++) {
      final config = state.steps[i];
      // 更新为 loading
      _updateStepState(i, StepStatus.loading);

      try {
        final result = await config.action(previousResult);
        _updateStepSuccess(i, result);
        previousResult = result;
      } catch (e) {
        final errorMsg = config.errorMessage ?? e.toString();
        _updateStepError(i, errorMsg);
        // 出错后停止后续步骤
        return;
      }
    }
  }

  void _updateStepState(int index, StepStatus status) {
    final newStates = List<StepStateModel>.from(state.states);
    newStates[index] = newStates[index].copyWith(status: status);
    state = WorkflowState(steps: state.steps, states: newStates);
  }

  void _updateStepSuccess(int index, dynamic result) {
    final newStates = List<StepStateModel>.from(state.states);
    newStates[index] = newStates[index].copyWith(
      status: StepStatus.success,
      result: result,
    );
    state = WorkflowState(steps: state.steps, states: newStates);
  }

  void _updateStepError(int index, String error) {
    final newStates = List<StepStateModel>.from(state.states);
    newStates[index] = newStates[index].copyWith(
      status: StepStatus.error,
      error: error,
    );
    state = WorkflowState(steps: state.steps, states: newStates);
  }

  /// 重置流程（清空所有步骤的状态）
  void reset() {
    final newStates = List.generate(
      state.steps.length,
      (_) => StepStateModel(status: StepStatus.idle),
    );
    state = WorkflowState(steps: state.steps, states: newStates);
  }

  /// 清空所有步骤配置和状态
  void clear() {
    state = WorkflowState(steps: [], states: []);
  }
}

// final workflowProvider = StateNotifierProvider<WorkflowNotifier, WorkflowState>(
//   (ref) {
//     return WorkflowNotifier();
//   },
// );
