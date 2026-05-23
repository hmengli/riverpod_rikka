import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/providers/router_provider.dart';
import 'package:rikka/screens/comics_entity.dart';
import 'package:rikka/screens/parser/parser_entity.dart';
import 'package:rikka/screens/parser/parser_provide.dart';
import 'package:rikka/screens/schedule/schedule_page.dart';
import 'package:rikka/utils/logger.dart';

import '../../../../utils/dialog.dart';
import 'captcha_service.dart';
import 'detail_provider.dart';

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
    ref.watch(imgProvider);
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
  // bool getCookie = false;
  // bool isLoading = false;
  String? showCode;
  // Uint8List? _imgCaptcha;
  // List<DetailEntity> detailList = [];

  // Future<void> _parserCookie() async {
  //   final service = ref.read(cookieSilentServiceProvider);
  //   setState(() {
  //     isLoading = true;
  //     getCookie = false;
  //   });
  //   String? cookie = await service.submitCaptcha(
  //     showCode,
  //     input: widget.parser.verifyInput,
  //     submit: widget.parser.verifySubmit,
  //   );
  //   Log.d('submitCaptcha: $cookie');
  //   if (cookie == null) {
  //     if (context.mounted) {
  //       DialogUtil.showAnimatedDialog(context, '验证错误');
  //     }
  //     return;
  //   }
  //   widget.parser.cookie = cookie;
  //   await Future.delayed(Duration(seconds: 4));
  //   await _testParseHtml();
  // }

  @override
  Widget build(BuildContext context) {
    final parser = widget.parser;
    final comics = widget.comics;
    String step1Url = parser.searchUrl;
    step1Url = step1Url.replaceAll('@keyword', comics.vodName);

    final notifier = ref.read(imgProvider.notifier);
    final imgCaptcha = ref.watch(imgProvider);
    final isCookie = ref.watch(isCookieProvider);
    Log.i('isCookie: ${parser.cookie}');
    if (!isCookie) {
      if (parser.verify && parser.cookie.isEmpty) {
        return ElevatedButton(
          onPressed: () {
            notifier.captureScreenshot(step1Url);
            ref.read(isCookieProvider.notifier).setIsCookie(true);
            Log.i('isCookie: $isCookie');
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
          ElevatedButton(
            onPressed: () {
              final cookie = notifier.parserCookie(
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
              ref.read(isCookieProvider.notifier).setIsCookie(false);
            },
            child: Text('提交'),
          ),
        ],
      );
    }
    final detailList = ref.watch(detailListProvider(parser, comics.vodName));
    return detailList.when(
      data: (data) {
        Log.i('detailList: $data');
        if (data.isEmpty) {
          if (parser.verify) {
            ref.read(isCookieProvider.notifier).setIsCookie(true);
            parser.cookie = "";
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(child: Text("NO Data"));
          }
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            DetailEntity token = data[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(token.title),
              trailing: const Icon(Icons.favorite_border),
              onTap: () {
                VideoPlayerRoute($extra: token).push(context);
                // Navigator.pop(context);
                // Navigator.pushNamed(
                //   context,
                //   '/player/${token.title}/',
                //   arguments: token,
                // );
              },
            );
          },
        );
      },
      error: (a, b) => Center(child: Text("NO Data")),
      loading: () => Center(child: CircularProgressIndicator()),
    );
  }
}

/// 辅助函数：显示提示
// void _showSnackbar(BuildContext context, String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text(message), duration: const Duration(milliseconds: 500)),
//   );
// }
