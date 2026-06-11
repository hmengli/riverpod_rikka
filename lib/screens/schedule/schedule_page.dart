import 'package:browser_headers/browser_headers.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rikka/screens/schedule/schedule_provider.dart';
import 'package:rikka/screens/schedule/parserapi/parser_api_entity.dart';
import 'package:rikka/screens/schedule/parserapi/parser_api_provide.dart';
import 'package:rikka/utils/utils.dart';

import 'schedule_entity.dart';
import '../../utils/dropdown_button.dart';
import 'schedule_router.dart';

class SchedulePage extends ConsumerWidget {
  final ApiType apiType;
  const SchedulePage({super.key, required this.apiType});

  //
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parserApiList = ref.watch(parserApiProvider(apiType));

    final apiValue = ref.watch(apiDropdownNotifyProvider(apiType));
    final apiNotifier = ref.read(apiDropdownNotifyProvider(apiType).notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('时间表'),
        actions: [
          Expanded(
            child: SettingsDropdownButton<ParserApiEntity>(
              title: 'basisUrl',
              value: apiValue,
              onChanged: apiNotifier.setState,
              items: parserApiList.map((toElement) {
                return DropdownMenuItem<ParserApiEntity>(
                  value: toElement,
                  child: Text(
                    toElement.basisUrl,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: TabBarWidget(
        isScrollable: true,
        tabList: Utils.weekdays,
        tabs: (p1) =>
            List.generate(p1.length, (i) => Tab(text: p1[i])).toList(),
        children: Utils.weekdays
            .map((e) => TabBarViewWidget(weekday: e, apiType: apiType))
            .toList(),
      ),
    );
  }
}

class TabBarViewWidget extends ConsumerWidget {
  final String weekday;
  final ApiType apiType;

  const TabBarViewWidget({
    super.key,
    required this.weekday,
    required this.apiType,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(fetchDataProvider(weekday, apiType));
    double width = MediaQuery.of(context).size.width;
    return data.when(
      data: (data) => Container(
        padding: EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (width.toInt() / 300).toInt(), // 列数
            crossAxisSpacing: 20, // 垂直间距
            mainAxisSpacing: 20, // 水平间距
            childAspectRatio: 1.618, // 适合图片的宽高比
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return ComicsCardH(comics: data[index]);
          },
        ),
      ),
      error: (e, _) => Center(child: Text("Error: $e")),
      loading: () => Center(child: CircularProgressIndicator()),
    );
  }
}

// 视频卡片 - 垂直布局
class ComicsCardH extends StatelessWidget {
  const ComicsCardH({
    super.key,
    required this.comics,
    this.canTap = true,
    this.enableHero = true,
  });

  final ScheduleEntity comics;
  final bool canTap;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final httpHeaders = BrowserHeaders.generate();

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          DetailsRoute($extra: comics).push(context);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Hero(
                transitionOnUserGestures: true,
                tag: comics.vodId,
                child: AspectRatio(
                  aspectRatio: 0.7, // 16:9 比例
                  child: CachedNetworkImage(
                    imageUrl: comics.vodPic,
                    httpHeaders: httpHeaders,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    unsupportedImageBuilder: (context, url, bytes) =>
                        SvgPicture.memory(bytes, fit: BoxFit.contain),
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),

                  // Image.network(
                  //   comics.vodPic,
                  //   fit: BoxFit.cover,
                  //   frameBuilder:
                  //       (context, child, frame, wasSynchronouslyLoaded) {
                  //         if (frame == null) {
                  //           return Center(child: CircularProgressIndicator());
                  //         }
                  //         return child;
                  //       },
                  // ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        comics.vodName,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    getText(context, comics.vodBlurb),
                    getText(context, comics.vodActor),
                    getText(context, '更新到第${comics.vodSerial}集'),
                    // getText(comics.vodTag),
                    getText(context, comics.vodDoubanScore),
                    getText(context, comics.vodRemarks),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getText(BuildContext context, String? title) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Text(
        title ?? '',
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// 视频卡片 - 垂直布局
class ComicsCardV extends StatelessWidget {
  const ComicsCardV({
    super.key,
    required this.comics,
    this.canTap = true,
    this.enableHero = true,
  });

  final ScheduleEntity comics;
  final bool canTap;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: GestureDetector(
        child: InkWell(
          onTap: () {
            // Modular.to.pushNamed('/detail/${comics.vodId}/', arguments: comics);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 0.85,
                  child: LayoutBuilder(
                    builder: (context, boxConstraints) {
                      final double maxWidth = boxConstraints.maxWidth;
                      final double maxHeight = boxConstraints.maxHeight;
                      return Hero(
                        transitionOnUserGestures: true,
                        tag: comics.vodId,
                        child: Image.network(
                          comics.vodPic,
                          width: maxWidth,
                          height: maxHeight,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  comics.vodName,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  textScaler: MediaQuery.of(context).textScaler,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabBarWidget<T> extends StatefulWidget {
  final bool isScrollable;
  final EdgeInsetsGeometry labelPadding;
  final List<T> tabList;
  final List<Tab> Function(List<T>) tabs;
  final List<Widget> children;
  final void Function(int)? onTap;

  const TabBarWidget({
    super.key,
    required this.tabList,
    required this.tabs,
    required this.children,
    this.onTap,
    this.isScrollable = false,
    this.labelPadding = kTabLabelPadding,
  });

  @override
  State<TabBarWidget<T>> createState() => _TabBarWidgetState<T>();
}

class _TabBarWidgetState<T> extends State<TabBarWidget<T>>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabList.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            onTap: widget.onTap,
            controller: _tabController,
            isScrollable: widget.isScrollable,
            labelPadding: widget.labelPadding,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: widget.tabs(widget.tabList),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.children,
            ),
          ),
        ],
      ),
    );
  }
}
