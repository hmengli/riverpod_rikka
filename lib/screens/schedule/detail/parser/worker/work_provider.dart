import 'package:flutter/material.dart';
import 'package:rikka/screens/schedule/detail/detail_provider.dart';
import 'package:rikka/logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../auth_provider.dart';
import '../parser_entity.dart';
import 'work_entity.dart';
import 'work_test_page.dart';

part 'work_provider.g.dart';

@riverpod
class WorkflowNotifier extends _$WorkflowNotifier {
  @override
  WorkflowState build() {
    final stepConfigs = ref.watch(stepListProvider);
    return WorkflowState.fromConfigs(stepConfigs);
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

@riverpod
class StepListNotifier extends _$StepListNotifier {
  @override
  List<StepConfig> build() {
    return [];
  }

  void stepConfigs(ParserEntity entity, String vodName) {
    String? cookieValue = '';
    String resultsStep1 = '';
    List<Map<String, String?>> resultsStep2 = [];
    List<List<Map<String, String>>> resultsStep3 = [];
    List<StepConfig> stepConfigs = [];
    final String step1Url = entity.searchUrl.replaceAll('@keyword', vodName);

    if (entity.verify) {
      final verifyNotifier = ref.read(verifyImgProvider(entity).notifier);

      stepConfigs.addAll({
        StepConfig(
          id: 'loadingPage',
          title: '加载页面',
          action: (prev) async {
            return await verifyNotifier.loadingPage(step1Url);
          },
          subtitle: (result) => GetImage(verify: result),
          errorMessage: ' 失败，请检查网络',
        ),
        StepConfig(
          id: 'parserImage',
          title: '解析验证码',
          action: (prev) async {
            return ref.read(getCodeProvider.notifier).setState(prev);
          },
          subtitle: (v) => ParserImage(),
          errorMessage: '登录失败，请检查网络',
        ),
        StepConfig(
          id: 'parserCookie',
          title: '获取Cookie',
          action: (prev) async {
            cookieValue = await verifyNotifier.parserCookie(prev);
            await Future.delayed(Duration(seconds: 4));
            return cookieValue;
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
          final headers = ref.read(browserHeadersProvider);
          headers.addAll({'cookie': cookieValue ?? ''});
          final parserService = ref.read(parserServiceProvider);
          resultsStep1 = await parserService.parseWithConfig(
            entity.searchUrl,
            search: vodName,
            headers: headers,
            entity: entity,
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
          resultsStep2 = parserService.extractLinks1(
            prev,
            titleSelector: entity.searchTitle,
            hrefSelector: entity.searchHref,
          );
          return resultsStep2;
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
          Log.i('resultsStep3: $cookieValue');
          final headers = ref.read(browserHeadersProvider);
          if (resultsStep2.isNotEmpty) {
            final parserService = ref.read(parserServiceProvider);
            String step3Html = await parserService.parseWithConfig(
              '${entity.basisUrl}${resultsStep2.first['href']}',
              headers: headers,
              entity: entity,
            );
            resultsStep3 = parserService.extractLinks2(
              step3Html,
              selector: entity.chapterRoad,
              selectorValue: entity.chapterList,
            );
          }
          return resultsStep3;
        },
        subtitle: (v) {
          return Center(child: Text(v.toString(), maxLines: 3));
        },
      ),
    });

    state = stepConfigs;
  }
}
