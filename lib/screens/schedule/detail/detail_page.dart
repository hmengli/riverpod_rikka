import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rikka/app_router.dart';
import 'package:rikka/screens/auth_provider.dart';
import 'package:rikka/screens/schedule/schedule_page.dart';
import 'package:rikka/utils/dialog.dart';
import 'package:rikka/screens/schedule/detail/parser/parser_provide.dart';
import 'package:rikka/screens/schedule/schedule_entity.dart';
import 'package:rikka/screens/schedule/detail/parser/parser_entity.dart';

import 'detail_entity.dart';
import 'detail_provider.dart';

class DetailPage extends ConsumerStatefulWidget {
  final ScheduleEntity comics;
  const DetailPage({super.key, required this.comics});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  @override
  Widget build(BuildContext context) {
    final headers = ref.read(browserHeadersProvider);
    final double maxWidth = 300;
    // final double maxHeight = 300;
    ScheduleEntity comics = widget.comics;
    return Scaffold(
      appBar: AppBar(title: Text(comics.vodName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: maxWidth,
              padding: const EdgeInsets.all(10),
              child: Hero(
                transitionOnUserGestures: true,
                tag: comics.vodId,
                child: AspectRatio(
                  aspectRatio: 0.7, // 16:9 比例
                  child: CachedNetworkImage(
                    imageUrl: comics.vodPic,
                    httpHeaders: headers,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    unsupportedImageBuilder: (context, url, bytes) =>
                        SvgPicture.memory(bytes, fit: BoxFit.contain),
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            Text('当前详情ID: ${comics.vodId}'),
            Text('附加数据: ${comics.vodName}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 通过动态路由跳转到播放页
                DetailDialog.bottomDialog(
                  context,
                  ParserEntityTabview(comics: comics),
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

class ParserEntityTabview extends ConsumerWidget {
  final ScheduleEntity comics;
  const ParserEntityTabview({super.key, required this.comics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(parserLocalListProvider(VideoType.comics));
    return TabBarWidget(
      isScrollable: true,
      tabList: configs,
      tabs: (l) => l.map((element) {
        return Tab(text: element.name, icon: Icon(Icons.recommend));
      }).toList(),
      children: configs.map((element) {
        return RecommendTab(comics: comics, parser: element.entity);
      }).toList(),
    );
  }
}

class RecommendTab extends ConsumerStatefulWidget {
  final ScheduleEntity comics;
  final ParserEntity parser;
  const RecommendTab({super.key, required this.comics, required this.parser});

  @override
  ConsumerState<RecommendTab> createState() => _RecommendTabState();
}

class _RecommendTabState extends ConsumerState<RecommendTab> {
  // Future<void> _parserCookie() async {
  //   final String code = showCode.text;
  //   Log.i('_parserCookie: $code');
  //   final parser = widget.verify.parser;
  //   final parserCookie = ref.read(
  //     parserCookieProvider(parser.basisUrl).notifier,
  //   );
  //   final verifyNotify = ref.read(verifyImgProvider(widget.verify).notifier);
  //   final cookie = await verifyNotify.parserCookie(code, entity: parser);
  //   parserCookie.setState(cookie ?? '');

  //   ref.read(isCookieProvider.notifier).setState(false);
  // }

  @override
  Widget build(BuildContext context) {
    // final parser = widget.parser;
    // final comics = widget.comics;
    // String step1Url = parser.searchUrl;
    // step1Url = step1Url.replaceAll('@keyword', comics.vodName);
    // final isCookie = ref.watch(isCookieProvider);
    // if (parser.verify) {
    //   final cookieValue = ref.read(parserCookieProvider(parser.basisUrl));
    //   if (cookieValue.isNotEmpty) {}

    //   //如果需要获取coolie,获取cookie
    //   if (isCookie) {
    //     return DetailVerifyWidget(
    //       verify: VerifyEntity(parser: parser, url: step1Url),
    //     );
    //   } else {
    //     //1.如果需要验证，而且coolie为空，先获取cookie
    //     return ElevatedButton(
    //       onPressed: () {
    //         ref.read(isCookieProvider.notifier).setState(true);
    //       },
    //       child: Text('获取验证码'),
    //     );
    //   }
    // }

    return DetailListWidget(comics: widget.comics, parser: widget.parser);
  }
}

// class DetailVerifyWidget extends ConsumerStatefulWidget {
//   final VerifyEntity verify;
//   const DetailVerifyWidget({super.key, required this.verify});

//   @override
//   ConsumerState<DetailVerifyWidget> createState() => _DetailVerifyWidgetState();
// }

// class _DetailVerifyWidgetState extends ConsumerState<DetailVerifyWidget> {
//   final showCode = TextEditingController(text: '');

//   Future<void> _parserCookie() async {
//     final String code = showCode.text;
//     Log.i('_parserCookie: $code');
//     final parser = widget.verify.parser;
//     final parserCookie = ref.read(
//       parserCookieProvider(parser.basisUrl).notifier,
//     );
//     final verifyNotify = ref.read(verifyImgProvider(widget.verify).notifier);
//     final cookie = await verifyNotify.parserCookie(code, entity: parser);
//     parserCookie.setState(cookie ?? '');

//     ref.read(isCookieProvider.notifier).setState(false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final parser = widget.verify.parser;
//     final imgCaptcha = ref.watch(verifyImgProvider(widget.verify));
//     final verifyNotifier = ref.read(verifyImgProvider(widget.verify).notifier);
//     return imgCaptcha.when(
//       data: (data) => Row(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(20),
//             child: ElevatedButton(
//               onPressed: verifyNotifier.getScreenshot,
//               child: Image.memory(data!),
//             ),
//           ),
//           Expanded(
//             child: TextField(
//               controller: showCode,
//               autofocus: true,
//               decoration: InputDecoration(hintText: "验证码"),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final code = await CaptchaService.recognizeCaptcha(data);
//               showCode.text = code;
//             },
//             child: Text('解析'),
//           ),
//           ElevatedButton(onPressed: _parserCookie, child: Text('提交')),
//         ],
//       ),
//       error: (e, t) => Text('$e'),
//       loading: () => Center(child: CircularProgressIndicator()),
//     );
//   }
// }

class DetailListWidget extends ConsumerWidget {
  final ScheduleEntity comics;
  final ParserEntity parser;
  const DetailListWidget({
    super.key,
    required this.comics,
    required this.parser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailList = ref.watch(detailListProvider(parser, comics));
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
