import 'package:rikka/screens/settings/parser/parser_entity.dart';
import 'package:rikka/screens/settings/parser/parser_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_provider.g.dart';

@riverpod
class DetailListNotifier extends _$DetailListNotifier {
  late final ParserService service;
  @override
  List<DetailEntity> build() {
    service = ref.watch(parserServiceProvider);
    return [];
  }

  Future<void> detailList(ParserEntity parser, String vodName) async {
    String resultsStep1 = await service.parseWithConfig(
      parser.searchUrl,
      search: vodName,
      entity: parser,
    );
    final results = service.extractLinks1(
      resultsStep1,
      titleSelector: parser.searchTitle,
      hrefSelector: parser.searchHref,
    );
    state = results.map((e) {
      return DetailEntity(
        id: '${e['id']}',
        title: '${e['title']}',
        href: '${parser.basisUrl}${e['href']}',
        imageSrc: '',
        parser: parser,
      );
    }).toList();
  }
}

@riverpod
class IsCookieNotifier extends _$IsCookieNotifier {
  @override
  bool build() {
    return false; // 初始状态为 false
  }

  void setIsCookie(bool value) {
    state = value; // 更新状态，会通知所有监听者
  }
}
