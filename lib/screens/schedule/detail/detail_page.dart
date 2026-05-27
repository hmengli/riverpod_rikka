import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/router_provider.dart';
import 'package:rikka/screens/schedule/comics_entity.dart';
import 'package:rikka/screens/settings/parser/parser_entity.dart';
import 'package:rikka/screens/settings/parser/parser_provide.dart';
import 'package:rikka/screens/schedule/schedule_page.dart';
import 'package:rikka/screens/settings/parser/tests/parser_test_provide.dart';
import 'package:rikka/utils/dialog.dart';
import 'package:rikka/utils/logger.dart';

import 'detail_provider.dart';
import 'silent_cookie_service.dart';

class DetailPage extends ConsumerStatefulWidget {
  final ComicsEntity comics;
  const DetailPage({super.key, required this.comics});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  @override
  Widget build(BuildContext context) {
    ref.watch(cookieProvider);
    final double maxWidth = 200;
    final double maxHeight = 300;
    ComicsEntity comics = widget.comics;
    return Scaffold(
      appBar: AppBar(title: Text(comics.vodName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: comics.vodId,
              child: Image.network(
                comics.vodPic,
                width: maxWidth,
                height: maxHeight,
              ),
            ),
            Text('当前详情ID: ${comics.vodId}'),
            Text('附加数据: ${comics.vodName}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 通过动态路由跳转到播放页
                // DetailDialog.bottomDialog(
                //   context,
                //   // ParserEntityTabview(comics: comics),
                // );
              },
              child: Text('播放'),
            ),
          ],
        ),
      ),
    );
  }
}

// class ParserEntityTabview extends ConsumerWidget {
//   final ComicsEntity comics;
//   const ParserEntityTabview({super.key, required this.comics});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final configs = ref.watch(parserListProvider);
//     return configs.when(
//       data: (data) {
//         return TabBarWidget(
//           isScrollable: true,
//           tabList: data,
//           tabs: (l) => l.map((element) {
//             return Tab(text: element.name, icon: Icon(Icons.recommend));
//           }).toList(),
//           children: data.map((element) {
//             return RecommendTab(comics: comics, parser: element);
//           }).toList(),
//         );
//       },
//       error: (error, stackTrace) => Center(child: Text("ERROR: 网络错误")),
//       loading: () => Center(child: CircularProgressIndicator()),
//     );
//     // return
//   }
// }

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
  }

  @override
  Widget build(BuildContext context) {
    final parser = widget.parser;
    final comics = widget.comics;
    String step1Url = parser.searchUrl;
    step1Url = step1Url.replaceAll('@keyword', comics.vodName);

    final isCookie = ref.watch(isCookieProvider);

    if (parser.verify) {
      //如果需要获取coolie,获取cookie
      if (isCookie) return getCookie();
      if (parser.cookie.isEmpty) {
        //1.如果需要验证，而且coolie为空，先获取cookie
        return ElevatedButton(
          onPressed: () {
            final notifier = ref.read(cookieProvider.notifier);
            notifier.loadingPage(step1Url, parser.verifyPng);
            ref.read(isCookieProvider.notifier).setIsCookie(true);
          },
          child: Text('获取验证码'),
        );
      }
    }

    return DetailListWidget(comics: comics, parser: parser);
  }

  Widget getCookie() {
    final parser = widget.parser;
    final imgCaptcha = ref.watch(cookieProvider);
    final notifier = ref.read(cookieProvider.notifier);
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
            showCode = code;
          },
          child: Text('解析'),
        ),
        ElevatedButton(onPressed: _parserCookie, child: Text('提交')),
      ],
    );
  }
}

class DetailListWidget extends ConsumerWidget {
  final ComicsEntity comics;
  final ParserEntity parser;
  const DetailListWidget({
    super.key,
    required this.comics,
    required this.parser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailList = ref.watch(detailListProvider(parser, comics.vodName));
    return detailList.when(
      data: (data) {
        if (data.isEmpty) return Center(child: Text('No Data'));
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
              },
            );
          },
        );
      },
      error: (e, t) => Center(child: Text('Error: $e')),
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
