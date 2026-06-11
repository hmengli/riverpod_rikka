import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/schedule/detail/parser/parser_entity.dart';

import '../schedule/parserapi/parser_api_entity.dart';
import '../../utils/dropdown_button.dart';
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
          onPressed: () =>
              CloudRoute(videoType: VideoType.comics).push(context),
          leading: Icon(Icons.settings),
        ),
      ],
    );
  }
}
