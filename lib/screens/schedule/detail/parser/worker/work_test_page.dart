import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/schedule/detail/parser/parser_entity.dart';

import '../../detail_provider.dart';
import 'work_provider.dart';
import 'work_widget.dart';

class WorkTestPage extends ConsumerStatefulWidget {
  final ParserEntity entity;

  const WorkTestPage({super.key, required this.entity});

  @override
  ConsumerState<WorkTestPage> createState() => _ParserTestPageState();
}

class _ParserTestPageState extends ConsumerState<WorkTestPage> {
  final TextEditingController _keywordController = TextEditingController();

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ParserEntity entity = widget.entity;
    return Scaffold(
      appBar: AppBar(title: Text('测试: ${entity.basisUrl}')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: InputDecoration(
                      hintText: '输入搜索关键词',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // ref.read(workflowProvider.notifier).clear();
                    ref
                        .read(stepListProvider.notifier)
                        .stepConfigs(entity, _keywordController.text);
                    ref.read(workflowProvider.notifier).run();
                  },
                  child: Text('搜索'),
                ),
              ],
            ),
          ),
          WorkWidget(),
        ],
      ),
    );
  }
}

class GetImage extends ConsumerWidget {
  final Uint8List? verify;
  const GetImage({super.key, required this.verify});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (verify != null) {
      return Image.memory(verify!, height: 50);
    }
    return Center(child: CircularProgressIndicator());
  }
}

class ParserImage extends ConsumerWidget {
  const ParserImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(getCodeProvider);
    return Center(child: Text(code));
  }
}
