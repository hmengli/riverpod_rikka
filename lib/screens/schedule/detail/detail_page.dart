import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/router_provider.dart';
import 'package:rikka/screens/schedule/comics_entity.dart';
import 'package:rikka/screens/settings/parser/parser_entity.dart';
import 'package:rikka/screens/settings/parser/parser_provide.dart';
import 'package:rikka/screens/schedule/schedule_page.dart';
import 'package:rikka/utils/logger.dart';

import '../../../../utils/dialog.dart';
import 'detail_provider.dart';
import 'silent_cookie_service.dart';

class DetailPage extends ConsumerStatefulWidget {
  final ComicsEntity entity;
  const DetailPage({super.key, required this.entity});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  List<ParserEntity> configs = [];

  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(parserListProvider).value;
    ref.watch(cookieProvider);
    final double maxWidth = 200;
    final double maxHeight = 300;
    ComicsEntity entity = widget.entity;
    return Scaffold(
      appBar: AppBar(title: Text(entity.vodName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: entity.vodId,
              child: Image.network(
                entity.vodPic,
                width: maxWidth,
                height: maxHeight,
              ),
            ),
            Text('当前详情ID: ${entity.vodId}'),
            Text('附加数据: ${entity.vodName}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 通过动态路由跳转到播放页
                DetailDialog.bottomDialog(
                  context,
                  TabBarWidget(
                    isScrollable: true,
                    tabList: configs!,
                    tabs: (l) => l.map((element) {
                      return Tab(
                        text: element.name,
                        icon: Icon(Icons.recommend),
                      );
                    }).toList(),
                    children: configs.map((element) {
                      return RecommendTab(
                        comics: widget.entity,
                        parser: element,
                      );
                    }).toList(),
                  ),
                );
              },
              child: Text('播放'),
            ),
          ],
        ),
      ),
    );
  }
}

class RecommendTab extends ConsumerStatefulWidget {
  final ComicsEntity comics;
  final ParserEntity parser;
  const RecommendTab({super.key, required this.comics, required this.parser});

  @override
  ConsumerState<RecommendTab> createState() => _RecommendTabState();
}

class _RecommendTabState extends ConsumerState<RecommendTab> {
  String? showCode;

  Future<void> _parserCookie() async {
    ref.read(isCookieProvider.notifier).setIsCookie(false);
    final parser = widget.parser;
    final comics = widget.comics;
    final cookie = ref
        .read(cookieProvider.notifier)
        .parserCookie(
          showCode,
          input: parser.verifyInput,
          submit: parser.verifySubmit,
        );
    cookie.then((onValue) {
      if (onValue != null) {
        Log.i('Cookie: $onValue');
        parser.cookie = onValue;
      }
    });
    await Future.delayed(Duration(seconds: 3));
    ref.read(detailListProvider.notifier).detailList(parser, comics.vodName);
  }

  @override
  Widget build(BuildContext context) {
    final parser = widget.parser;
    final comics = widget.comics;
    String step1Url = parser.searchUrl;
    step1Url = step1Url.replaceAll('@keyword', comics.vodName);

    final imgCaptcha = ref.watch(cookieProvider);
    final notifier = ref.read(cookieProvider.notifier);
    final isCookie = ref.watch(isCookieProvider);
    final detailList = ref.watch(detailListProvider);

    Log.i('showCode: ${parser.cookie}');
    if (!isCookie) {
      if (parser.verify && parser.cookie.isEmpty) {
        return ElevatedButton(
          onPressed: () {
            notifier.loadingPage(step1Url);
            ref.read(isCookieProvider.notifier).setIsCookie(true);
          },
          child: Text('获取验证码'),
        );
      }
    } else {
      return Row(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () => notifier.setScreenshot(parser.verifyPng),
              child: imgCaptcha != null
                  ? Image.memory(imgCaptcha)
                  : CircularProgressIndicator(),
            ),
          ),
          Expanded(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(hintText: "验证码"),
              onChanged: (value) {
                showCode = value;
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = await CaptchaService.recognizeCaptcha(imgCaptcha!);
              Log.i('showCode: $code');
              setState(() {
                showCode = code;
              });
            },
            child: Text('解析'),
          ),
          ElevatedButton(onPressed: _parserCookie, child: Text('提交')),
        ],
      );
    }

    if (detailList.isEmpty) {
      return Center(
        child: ListTile(
          title: Text('NO Data'),
          trailing: ElevatedButton(
            onPressed: () {
              final notifier = ref.read(detailListProvider.notifier);
              notifier.detailList(parser, comics.vodName);
            },
            child: Text('re'),
          ),
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: detailList.length,
        itemBuilder: (context, index) {
          DetailEntity token = detailList[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(token.title),
            trailing: const Icon(Icons.favorite_border),
            onTap: () {
              VideoPlayerRoute($extra: token).push(context);
              // Navigator.pop(context);
            },
          );
        },
      );
    }
  }
}

/// 辅助函数：显示提示
// void _showSnackbar(BuildContext context, String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text(message), duration: const Duration(milliseconds: 500)),
//   );
// }
