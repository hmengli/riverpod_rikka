import 'package:hive_ce/hive.dart';

import '../screens/settings/api/parser_api_entity.dart';
import '../screens/settings/parser/parser_entity.dart';

@GenerateAdapters([
  AdapterSpec<ParserEntity>(
    ignoredFields: {'createdAt', 'cookie', 'videoType'},
  ), // 来自 parser_entity.dart
  AdapterSpec<ParserApiEntity>(), // 来自 api_entity.dart
])
part 'hive_adapters.g.dart';
