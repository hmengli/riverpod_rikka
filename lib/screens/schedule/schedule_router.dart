import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rikka/screens/settings/parser/tests/detail_entity.dart';

import '../settings/parserapi/comics_entity.dart';
import 'detail/detail_page.dart';
import 'detail/video/playlist_page.dart';

part 'schedule_router.g.dart';

@TypedGoRoute<DetailsRoute>(path: '/details')
class DetailsRoute extends GoRouteData with $DetailsRoute {
  const DetailsRoute({this.$extra});
  final ComicsEntity? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DetailPage(comics: $extra!);
}

@TypedGoRoute<VideoPlayerRoute>(path: '/videoplayer')
class VideoPlayerRoute extends GoRouteData with $VideoPlayerRoute {
  const VideoPlayerRoute({this.$extra});
  final DetailEntity? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      VideoPlayerPage(detail: $extra!);
}
