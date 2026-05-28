import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'cloud/cloud_page.dart';
import 'parser/parser_entity.dart';
import 'parser/parser_upsert_page.dart';
import 'parser/parser_view_page.dart';
import 'parser/tests/parser_test_page.dart';
import 'theme/theme_page.dart';

part 'settings_route.g.dart';

@TypedGoRoute<ThemeRoute>(path: '/theme')
class ThemeRoute extends GoRouteData with $ThemeRoute {
  const ThemeRoute();

  @override
  Widget build(_, _) => ThemePage();
}

@TypedGoRoute<CloudRoute>(path: '/cloud')
class CloudRoute extends GoRouteData with $CloudRoute {
  const CloudRoute();

  @override
  Widget build(_, _) => CloudPage(title: '云存储');
}

@TypedGoRoute<ParserRoute>(
  path: '/parser/:videoType',
  routes: [
    TypedGoRoute<ParserUpsertRoute>(path: 'upsert'),
    TypedGoRoute<ParserTestRoute>(path: 'tests'),
  ],
)
class ParserRoute extends GoRouteData with $ParserRoute {
  const ParserRoute({required this.videoType});
  final VideoType videoType;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ParserPage(videoType: videoType);
}

class ParserUpsertRoute extends GoRouteData with $ParserUpsertRoute {
  const ParserUpsertRoute({this.$extra, required this.videoType});
  final VideoType videoType;
  final ParserEntity? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ParserUpsertPage(model: $extra, videoType: videoType);
}

class ParserTestRoute extends GoRouteData with $ParserTestRoute {
  const ParserTestRoute({required this.videoType, this.$extra});
  final VideoType videoType;
  final ParserEntity? $extra;
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ParserTestPage(entity: $extra);
  }
}
