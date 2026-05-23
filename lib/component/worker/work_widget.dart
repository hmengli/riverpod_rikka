import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'work_provider.dart';

typedef StepContext = Future Function(dynamic previousResult);

class StepConfig {
  final String id; // 唯一标识
  final String title; // 展示用的标题
  final StepContext action; // 执行的异步逻辑，接收上一步结果，返回当前步结果
  final Widget Function(dynamic res)? subtitle; // 执行的异步逻辑，接收上一步结果，返回当前步结果
  final String? errorMessage; // 可自定义的错误提示（若不提供，则使用异常信息）

  StepConfig({
    required this.id,
    required this.title,
    required this.action,
    this.subtitle,
    this.errorMessage,
  });
}

class WorkWidget extends ConsumerStatefulWidget {
  final List<StepConfig> stepConfigs;
  final Widget Function(void Function() aexcute) builder;
  const WorkWidget({
    super.key,
    required this.stepConfigs,
    required this.builder,
  });

  @override
  ConsumerState<WorkWidget> createState() => _WorkWidgetState();
}

class _WorkWidgetState extends ConsumerState<WorkWidget> {
  void _aexcuteFram() {
    ref.read(workflowProvider.notifier).setup(widget.stepConfigs);
    ref.read(workflowProvider.notifier).run();
  }

  @override
  Widget build(BuildContext context) {
    final workflow = ref.watch(workflowProvider);

    // final steps = workflow.steps;
    final steps = widget.stepConfigs;
    final states = workflow.states;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: widget.builder(_aexcuteFram),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              final state = states[index];
              return _buildStepCard(step, state);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(StepConfig step, StepStateModel state) {
    Widget leading;
    switch (state.status) {
      case StepStatus.idle:
        leading = Icon(Icons.circle_outlined, color: Colors.grey);
        break;
      case StepStatus.loading:
        leading = CircularProgressIndicator(strokeWidth: 2);
        break;
      case StepStatus.success:
        leading = Icon(Icons.check_circle, color: Colors.green);
        break;
      case StepStatus.error:
        leading = Icon(Icons.error, color: Colors.red);
        break;
    }
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: leading,
        title: Text(step.title),
        subtitle: step.subtitle != null
            ? step.subtitle?.call(state.result)
            : Text(''),
      ),
    );
  }
}
