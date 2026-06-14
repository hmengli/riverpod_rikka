import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'schedule_entity.dart';
import 'detail/detail_page.dart';

part 'schedule_router.g.dart';

@TypedGoRoute<DetailsRoute>(path: '/details')
class DetailsRoute extends GoRouteData with $DetailsRoute {
  const DetailsRoute({this.$extra});
  final ScheduleEntity? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DetailPage(comics: $extra!);
}
