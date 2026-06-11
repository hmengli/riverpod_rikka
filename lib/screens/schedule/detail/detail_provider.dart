import 'package:rikka/screens/schedule/detail/parser/parser_entity.dart';
import 'package:rikka/screens/schedule/detail/parser/tests/parser_test_provide.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../schedule_entity.dart';
import 'detail_entity.dart';

part 'detail_provider.g.dart';

@riverpod
class IsCookieNotifier extends _$IsCookieNotifier {
  @override
  bool build() => false;
  void setState(bool value) => state = value;
}

@riverpod
Future<List<DetailEntity>> detailList(
  Ref ref,
  ParserEntity parser,
  ScheduleEntity comics,
) async {
  return ref.watch(extractServiceProvider(parser).notifier).detailList(comics);
}
