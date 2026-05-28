import 'package:supabase_flutter/supabase_flutter.dart';

import '../parser/parser_entity.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 查询数据
  Future<List<ParserEntity>> getParser() async {
    final response = await _supabase
        .from('ParserEntity')
        .select(' * ')
        // .eq('isActive', true)
        .order('created_at', ascending: false);

    return response.map((element) {
      return ParserEntity.fromJson(element);
    }).toList();
  }

  // 插入数据
  Future<void> upsert(Map<String, dynamic> user) async {
    await _supabase.from('ParserEntity').upsert(user);
  }

  // 实时订阅
  // void subscribeToMessages(Function(List<dynamic>) onData) {
  //   _supabase
  //       .channel('messages')
  //       .on(
  //     RealtimeListenTypes.postgresChanges,
  //     ChannelFilter(event: 'INSERT', schema: 'public', table: 'messages'),
  //         (payload) => onData(payload['new'] as List),
  //   )
  //       .subscribe();
  // }

  // 调用存储过程
  // Future<void> callFunction() async {
  //   await _supabase.rpc('my_function', params: {'param1': 'value'});
  // }
}
