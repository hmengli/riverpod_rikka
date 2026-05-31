import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/settings/parser/parser_entity.dart';

import 'api/parser_api_entity.dart';
import 'settings_route.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text('配置', style: Theme.of(context).textTheme.titleLarge),
            ),
            Column(
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    // 所有角圆角半径为20
                    boxShadow: [BoxShadow(color: Colors.black26)],
                  ),
                  child: ColumnWidget(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ColumnWidget extends StatelessWidget {
  const ColumnWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsButton(
          title: '播放器配置',
          subtitle: '播放器配置界面',
          onPressed: () {
            // Modular.to.pushNamed(
            //   '/main/settings/player/',
            //   arguments: {'title': '播放器配置'},
            // );
          },
          leading: Icon(Icons.settings),
        ),
        SettingsButton(
          title: '主题配置',
          subtitle: '主题配置界面',
          onPressed: () => ThemeRoute().push(context),
          leading: Icon(Icons.settings),
        ),
        SettingsButton(
          title: '配置界面',
          subtitle: '主题配置界面',
          onPressed: () {},
          leading: Icon(Icons.settings),
        ),
        SettingsButton(
          title: '配置',
          subtitle: '动漫Api规则配置界面',
          onPressed: () {
            ParserApiRoute(apiType: ApiType.comicsApi).push(context);
          },
          leading: Icon(Icons.settings),
        ),
        SettingsButton(
          title: '配置',
          subtitle: '动漫规则配置界面',
          onPressed: () {
            ParserRoute(videoType: VideoType.comics).push(context);
          },
          leading: Icon(Icons.settings),
        ),
        SettingsButton(
          title: '配置',
          subtitle: '影视规则配置界面',
          onPressed: () {
            ParserRoute(videoType: VideoType.movie).push(context);
          },
          leading: Icon(Icons.settings),
        ),
        SettingsButton(
          title: '云端配置',
          subtitle: '云端同步界面',
          onPressed: () => CloudRoute().push(context),
          leading: Icon(Icons.settings),
        ),
      ],
    );
  }
}

class SettingsSwitchButton extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final ValueChanged<bool>? onPressed;

  const SettingsSwitchButton({
    super.key,
    this.onPressed,
    this.subtitle,
    this.leading,
    required this.title,
  });

  @override
  State<SettingsSwitchButton> createState() => _SettingsSwitchButtonState();
}

class _SettingsSwitchButtonState extends State<SettingsSwitchButton> {
  bool _isHovering = false;

  void onChanged() {
    if (widget.onPressed != null) {
      _isHovering = !_isHovering;
      widget.onPressed?.call(_isHovering);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsButton(
      title: widget.title,
      subtitle: widget.subtitle,
      onPressed: onChanged,
      leading: widget.leading,
      end: SizedBox(
        width: 20,
        height: 20,
        child: Transform.scale(
          scale: 0.5, // 缩小到 0.8 倍
          child: Switch(value: _isHovering, onChanged: (b) => onChanged()),
        ),
      ),
    );
  }
}

class SettingsDropdownButton<T> extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final T? value;
  final ValueChanged<T>? onChanged;
  final List<DropdownMenuItem<T>> items;

  const SettingsDropdownButton({
    super.key,
    this.title,
    this.leading,
    this.subtitle,
    this.value,
    this.onChanged,
    required this.items,
  });

  @override
  State<SettingsDropdownButton<T>> createState() =>
      _SettingsDropdownButtonState<T>();
}

class _SettingsDropdownButtonState<T> extends State<SettingsDropdownButton<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;
  DropdownMenuItem<T>? deItem;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final double width = renderBox.size.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () => _removeOverlay(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Container(color: Colors.transparent),
            Positioned(
              left: offset.dx,
              top: offset.dy + renderBox.size.height,
              width: width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, renderBox.size.height),
                child: Material(
                  elevation: 4,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min, // 让 Column 高度由子组件决定
                        children: widget.items.map((item) {
                          return InkWell(
                            onTap: () {
                              widget.onChanged?.call(item.value as T);
                              _removeOverlay();
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: item.child,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _isHovering = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value != null) {
      deItem = widget.items.firstWhere(
        (e) => e.value == widget.value,
        orElse: () => DropdownMenuItem(child: Text('')),
      );
    }
    return CompositedTransformTarget(
      link: _layerLink,
      child: SettingsButton(
        title: widget.title,
        subtitle: widget.subtitle,
        onPressed: () {
          if (_isHovering) {
            _removeOverlay();
          } else {
            _showOverlay(context);
            _isHovering = true;
          }
          setState(() {});
        },
        leading: widget.leading,
        end: deItem?.child,
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? end;

  const SettingsButton({
    super.key,
    this.title,
    this.onPressed,
    this.leading,
    this.subtitle,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero, // 移除内边距
        minimumSize: Size.zero, // 允许按钮尺寸收缩到最小（可选）
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 缩小点击区域
      ),
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            if (leading != null)
              Padding(padding: EdgeInsets.zero, child: leading),
            if (title != null)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? '',
                        style: Theme.of(context).textTheme.labelLarge,
                        overflow: TextOverflow.ellipsis,
                        // textAlign: TextAlign.start,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            if (end != null)
              Expanded(
                child: Padding(padding: EdgeInsets.zero, child: end),
              ),
          ],
        ),
      ),
    );
  }
}
