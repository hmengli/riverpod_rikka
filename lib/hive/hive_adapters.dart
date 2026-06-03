import 'package:hive_ce/hive.dart';
import 'package:rikka/screens/settings/parserapi/parser_api_entity.dart';
import 'package:rikka/screens/settings/parser/parser_entity.dart';

@GenerateAdapters([
  AdapterSpec<ParserEntity>(
    ignoredFields: {'createdAt', 'cookie', 'videoType'},
  ), // 来自 parser_entity.dart
  AdapterSpec<ParserApiEntity>(), // 来自 api_entity.dart
  AdapterSpec<HeadersEntity>(),
  AdapterSpec<FieldMapping>(),
  AdapterSpec<DataTransForm>(),
  AdapterSpec<ValueSourceType>(),
  AdapterSpec<TransFormType>(),
  AdapterSpec<Methods>(),
])
part 'hive_adapters.g.dart';
