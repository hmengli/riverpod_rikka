import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'extract_entity.freezed.dart';

enum Extension { mp4, m3u8 }

@freezed
abstract class ExtractEntity with _$ExtractEntity {
  const factory ExtractEntity({required Extension type, required String url}) =
      _ExtractEntity;
}

@freezed
abstract class ExtractTask with _$ExtractTask {
  const factory ExtractTask({
    required String pageUrl,
    required String selectorMp,
    required String selectorUm,
    required Completer<ExtractEntity?> completer,
  }) = _ExtractTask;
}
