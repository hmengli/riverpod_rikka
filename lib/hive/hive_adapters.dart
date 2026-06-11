import 'package:hive_ce/hive.dart';
import 'package:rikka/screens/schedule/detail/parser/parser_entity.dart';
import 'package:rikka/screens/schedule/parserapi/parser_api_entity.dart';

@GenerateAdapters([
  // 来自 parser_entity.dart
  AdapterSpec<ParserEntity>(ignoredFields: {'cookie'}),
  AdapterSpec<VideoType>(),
  AdapterSpec<FromType>(),
  AdapterSpec<SyncStatus>(),
  // 来自 api_entity.dart
  AdapterSpec<ParserApiEntity>(),
  AdapterSpec<HeadersEntity>(),
  AdapterSpec<FieldMapping>(),
  AdapterSpec<DataTransForm>(),
  AdapterSpec<ValueSourceType>(),
  AdapterSpec<TransFormType>(),
  AdapterSpec<Methods>(),
])
part 'hive_adapters.g.dart';
