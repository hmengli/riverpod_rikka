import '../parser_entity.dart';

class DetailEntity {
  String id;
  String title;
  String href;
  String imageSrc;
  ParserEntity parser;

  DetailEntity({
    required this.id,
    required this.title,
    required this.href,
    required this.imageSrc,
    required this.parser,
  });
}
