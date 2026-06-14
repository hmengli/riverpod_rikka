import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'work_entity.dart';
import 'work_provider.dart';

class WorkWidget extends ConsumerWidget {
  const WorkWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflow = ref.watch(workflowProvider);
    final steps = workflow.steps;
    final states = workflow.states;

    return Expanded(
      child: ListView.builder(
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          final state = states[index];
          return _buildStepCard(step, state);
        },
      ),
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
