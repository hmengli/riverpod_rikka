import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/router_provider.dart';
import 'package:rikka/screens/settings/parser/parser_entity.dart';

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
          onPressed: () {
            // Modular.to.pushNamed(
            //   '/main/settings/theme/',
            //   arguments: {'title': '主题配置'},
            // );
          },
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
          // onPressed: () {
          //   Modular.to.pushNamed(
          //     '/main/settings/cloud/',
          //     arguments: {'title': '云端同步'},
          //   );
          // },
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
  final String title;
  final String? subtitle;
  final Widget? leading;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final List<DropdownMenuItem<T>> items;
  const SettingsDropdownButton({
    super.key,
    this.leading,
    this.subtitle,
    this.value,
    this.onChanged,
    required this.items,
    required this.title,
  });

  @override
  State<SettingsDropdownButton<T>> createState() =>
      _SettingsDropdownButtonState<T>();
}

class _SettingsDropdownButtonState<T> extends State<SettingsDropdownButton<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;
  late DropdownMenuItem<T> selectItem;

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
      builder: (context) => Positioned(
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
              child: ListView(
                padding: EdgeInsets.zero,
                children: widget.items.map((item) {
                  return InkWell(
                    onTap: () {
                      widget.onChanged?.call(item.value);
                      _removeOverlay();
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: item.child,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
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
    selectItem = widget.items.firstWhere((e) => e.value == widget.value);
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
        end: selectItem.child,
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? end;

  const SettingsButton({
    super.key,
    this.onPressed,
    this.leading,
    this.subtitle,
    this.end,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsetsGeometry.all(5),
        child: Row(
          // spacing:1,
          children: [
            if (leading != null)
              Padding(padding: EdgeInsetsGeometry.all(5), child: leading),
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge,
                      // textAlign: TextAlign.start,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
            ),
            if (end != null)
              Padding(padding: EdgeInsetsGeometry.all(5), child: end),
          ],
        ),
      ),
    );
  }
}
