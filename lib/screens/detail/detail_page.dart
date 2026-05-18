import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rikka/screens/comics_entity.dart';
import 'package:rikka/screens/parser/parser_entity.dart';
import 'package:rikka/screens/parser/parser_provide.dart';
import 'package:rikka/screens/schedule_page.dart';

import '../../../utils/dialog.dart';
import 'silent_cookie_service.dart';

class DetailPage extends ConsumerStatefulWidget {
  final ComicsEntity entity;
  const DetailPage({super.key, required this.entity});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  final service = CookieSilentService();
  List<ParserEntity> configs = [];

  @override
  void initState() {
    super.initState();
    service.init();
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(parserListProvider).value;
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
                        service: service,
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

class RecommendTab extends StatefulWidget {
  final ComicsEntity comics;
  final ParserEntity parser;
  final CookieSilentService service;
  const RecommendTab({
    super.key,
    required this.comics,
    required this.parser,
    required this.service,
  });

  @override
  State<RecommendTab> createState() => _RecommendTabState();
}

class _RecommendTabState extends State<RecommendTab> {
  bool getCookie = false;
  bool isLoading = false;
  String? showCode;
  Uint8List? _imgCaptcha;
  List<DetailEntity> detailList = [];

  @override
  void initState() {
    super.initState();
    if (!widget.parser.verify || widget.parser.cookie.isNotEmpty) {
      _testParseHtml();
    }
  }

  Future<void> _testParseHtml() async {
    // try {
    //   final results = await ParserService.parseWithStep1(
    //     widget.parser,
    //     search: widget.comics.vodName,
    //   );
    //   detailList = results.map((e) {
    //     return DetailEntity(
    //       id: '${e['id']}',
    //       title: '${e['title']}',
    //       href: '${widget.parser.basisUrl}${e['href']}',
    //       imageSrc: '',
    //       parser: widget.parser,
    //     );
    //   }).toList();
    //   Log.i('_testParseHtml: $detailList');
    //   if (widget.parser.verify && widget.parser.cookie.isNotEmpty) {
    //     if (detailList.isEmpty) {
    //       widget.parser.cookie = '';
    //       isLoading = true;
    //     }
    //   }
    //   setState(() {});
    // } catch (e) {
    //   Log.e('_testParseHtml: $e');
    // }
  }

  Future<void> _parserCookie(BuildContext context) async {
    setState(() {
      isLoading = true;
      getCookie = false;
    });
    String? cookie = await widget.service.submitCaptcha(
      showCode,
      input: widget.parser.verifyInput,
      submit: widget.parser.verifySubmit,
    );
    if (cookie == null) {
      if (context.mounted) {
        DialogUtil.showAnimatedDialog(context, '验证错误');
      }
      return;
    }
    widget.parser.cookie = cookie;
    await Future.delayed(Duration(seconds: 4));
    await _testParseHtml();
  }

  Future<void> _captureScreenshot(BuildContext context, String step1Url) async {
    Uint8List? img = await widget.service.captureScreenshot(step1Url);
    if (img == null && context.mounted) {
      _parserCookie(context);
      return;
    }
    _imgCaptcha = img;
    setState(() {});
  }

  Future<void> _getScreenshot(BuildContext context) async {
    Uint8List? img = await widget.service.getScreenshot(
      widget.parser.verifyPng,
    );
    if (img == null) {
      if (context.mounted) {
        DialogUtil.showAnimatedDialog(context, '获取失败');
      }
      return;
    }
    _imgCaptcha = img;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String step1Url = widget.parser.searchUrl;
    step1Url = step1Url.replaceAll('@keyword', widget.comics.vodName);
    if (getCookie && !isLoading) {
      return Row(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () => _getScreenshot(context),
              child: _imgCaptcha != null
                  ? Image.memory(_imgCaptcha!)
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
            onPressed: () => _parserCookie(context),
            child: Text('提交'),
          ),
        ],
      );
    }

    if (widget.parser.verify && !isLoading) {
      if (widget.parser.cookie.isEmpty) {
        return ElevatedButton(
          onPressed: () => setState(() {
            _captureScreenshot(context, step1Url);
            getCookie = true;
          }),
          child: Text('获取验证码'),
        );
      }
    }

    if (detailList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: detailList.length,
        itemBuilder: (context, index) {
          DetailEntity? token = detailList[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(token.title),
            trailing: const Icon(Icons.favorite_border),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/player/${token.title}/',
                arguments: token,
              );
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
