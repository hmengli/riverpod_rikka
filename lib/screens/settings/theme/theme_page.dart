import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/l10n/app_localizations.dart';

import '../assembly/dropdown_button.dart';
import 'theme_provider.dart';

class ThemePage extends ConsumerWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeIndexProvider);
    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    String light = AppLocalizations.of(context)!.light;
    String dark = AppLocalizations.of(context)!.dark;
    String system = AppLocalizations.of(context)!.system;
    // List<String> items = [light, dark];
    // String selectedValue = light;
    return Scaffold(
      appBar: AppBar(title: Text('主题设置')),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text('主题设置', style: Theme.of(context).textTheme.titleLarge),
          ),
          Column(
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  // 所有角圆角半径为20
                  boxShadow: [BoxShadow(color: Colors.black12)],
                ),
                child: Column(
                  children: [
                    SettingsDropdownButton<ThemeMode>(
                      title: '主题',
                      value: theme,
                      onChanged: (v) => themeNotifier.setThemeMode(v),
                      items: [
                        DropdownMenuItem<ThemeMode>(
                          value: ThemeMode.light,
                          child: Text(light),
                        ),
                        DropdownMenuItem<ThemeMode>(
                          value: ThemeMode.dark,
                          child: Text(dark),
                        ),
                        DropdownMenuItem<ThemeMode>(
                          value: ThemeMode.system,
                          child: Text(system),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SettingsButton(
                title: '配色方案',
                // subtitle: '主题配置界面',
                onPressed: () => _showCustomDialog(context, ref),
                // onPressed: () => DraggableDialog(),
                // leading: Icons.settings,
              ),
              SettingsSwitchButton(title: '', onPressed: (b) {}),
              DraggableDialog(),
            ],
          ),
        ],
      ),
    );
  }

  void _showCustomDialog(BuildContext context, WidgetRef ref) {
    final themeIndex = ref.watch(themeIndexProvider);
    final themeIndexNotifier = ref.read(themeIndexProvider.notifier);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          clipBehavior: Clip.antiAlias,
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 300,
            height: 400,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: IconButtonGroup(
              selectedIndex: themeIndex,
              onChanged: (i) {
                themeIndexNotifier.setSelectedIndex(i);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}

class IconButtonGroup extends StatelessWidget {
  final int selectedIndex;
  final void Function(int)? onChanged;

  const IconButtonGroup({
    super.key,
    this.onChanged,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 每行2个item（竖向滚动时）
          mainAxisSpacing: 10, // 主轴方向间距（竖向滚动时为垂直间距）
          crossAxisSpacing: 10, // 交叉轴方向间距（竖向滚动时为水平间距）
          childAspectRatio: 1.0, // 子组件宽高比（宽度/高度）
        ),
        children: List.generate(9, (index) {
          final isSelected = selectedIndex == index;
          return Stack(
            fit: StackFit.expand,
            alignment: AlignmentDirectional.center,
            children: [
              IconButton(
                onPressed: () {
                  onChanged?.call(index);
                },
                isSelected: isSelected,
                icon: Icon(Icons.check_circle_outline),
              ),
              if (isSelected) Icon(Icons.check_circle),
            ],
          );
        }),
      ),
    );
  }
}

// class IconButtonGroup extends StatefulWidget {
//
//
//   @override
//   State<IconButtonGroup> createState() => _IconButtonGroupState();
// }

class DraggableDialog extends StatelessWidget {
  const DraggableDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Draggable(
        feedback: Container(), // 拖拽时的反馈
        child: SizedBox(
          width: 300,
          height: 400,
          child: Column(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text('可拖拽对话框', style: TextStyle(color: Colors.white)),
                ),
              ),
              Expanded(child: Center(child: Text('可以拖拽这个对话框'))),
            ],
          ),
        ),
      ),
    );
  }
}
