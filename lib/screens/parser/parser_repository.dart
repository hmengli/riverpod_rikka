import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:rikka/utils/logger.dart';

import 'parser_entity.dart';

typedef StepContext = Future Function(dynamic previousResult);

class StepConfig {
  final String id; // 唯一标识
  final String title; // 展示用的标题
  final StepContext action; // 执行的异步逻辑，接收上一步结果，返回当前步结果
  final String? errorMessage; // 可自定义的错误提示（若不提供，则使用异常信息）

  StepConfig({
    required this.id,
    required this.title,
    required this.action,
    this.errorMessage,
  });
}

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

class WorkflowNotifier extends StateNotifier<WorkflowState> {
  WorkflowNotifier() : super(WorkflowState(steps: [], states: []));

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

final workflowProvider = StateNotifierProvider<WorkflowNotifier, WorkflowState>(
  (ref) {
    return WorkflowNotifier();
  },
);

/// 步骤执行函数签名：
///   - 输入：前一步的结果（第一步为 null）
///   - 输出：Future<dynamic> 当前步骤的结果
typedef StepAction = Future<dynamic> Function(dynamic previousResult);

// 提供 ParserRepository 实例
final parserServiceProvider = Provider<ParserService>((ref) {
  Log.d('parserServiceProvider');
  return ParserService();
});

class ParserService {
  // 执行完整的三步解析
  Future<String> parseWithConfig(
    String? search, {
    required String step1Url,
    required ParserEntity entity,
  }) async {
    try {
      if (search != null) {
        step1Url = step1Url.replaceAll('@keyword', search);
      }
      return await fetchPage(url: step1Url, parserEntity: entity);
    } catch (e) {
      throw Exception('网络错误，请检查网络: $e');
    }
  }

  // 获取页面HTML
  Future<String> fetchPage({
    required String url,
    required ParserEntity parserEntity,
  }) async {
    Log.i('请求URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml',
        'Referer': parserEntity.referer,
        'Cookie': parserEntity.cookie,
      },
    );

    if (response.statusCode == 200) {
      Log.i('请求URL: ${response.statusCode}');
      return response.body;
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  // 提取链接或内容
  List<Map<String, String?>> extractLinks1(
    String html, {
    required String hrefSelector,
    required String titleSelector,
  }) {
    final document = parser.parse(html);
    final elements = document.querySelectorAll(hrefSelector);
    return elements.map((element) {
      String? href = element.querySelector('a')?.attributes['href'];
      String? title;
      if (titleSelector.contains('@')) {
        List<String> list = titleSelector.split('@');
        title = element.querySelector(list[0])?.attributes[list[1]];
      } else {
        title = element.querySelector(titleSelector)?.text;
      }
      return {'href': href ?? '', 'title': title ?? ''};
    }).toList();
  }

  // 提取链接或内容
  static List<List<Map<String, String>>> extractLinks2(
    String html, {
    required String selector,
    required String selectorValue,
  }) {
    final document = parser.parse(html);
    final elements = document.querySelectorAll(selector);
    return List.generate(elements.length, (index) {
      final elementsA = elements[index].querySelectorAll(selectorValue);
      return elementsA.map((element) {
        return {
          'href': element.attributes['href'].toString(),
          'value': element.text.trim(),
        };
      }).toList();
    });
  }
}
