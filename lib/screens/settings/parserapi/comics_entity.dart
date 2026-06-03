import 'package:freezed_annotation/freezed_annotation.dart';

part 'comics_entity.freezed.dart';

@freezed
abstract class ComicsEntity with _$ComicsEntity {
  const factory ComicsEntity({
    required String url,
    required int vodId,
    required String vodName,
    required String vodPic,
    String? vodPicThumb,
    String? vodClass,
    String? vodActor,
    String? vodTag,
    String? vodScore,
    String? vodDoubanScore,
    String? vodRemarks,
    String? vodSerial,
    String? vodBlurb,
  }) = _ComicsEntity;

  static List<String> list = [
    'url',
    'vod_id',
    'vod_name',
    'vod_pic',
    'vod_pic_thumb',
    'vod_class',
    'vod_actor',
    'vod_tag',
    'vod_douban_score',
    'vod_remarks',
    'vod_serial',
    'vod_blurb',
  ];

  factory ComicsEntity.fromJson(Map<String, dynamic> json) {
    return ComicsEntity(
      url: json['url'] ?? '',
      vodId: json['vod_id'] as int,
      vodName: json['vod_name'] as String,
      vodPic: json['vod_pic'] ?? '',
      vodPicThumb: json['vod_pic_thumb'],
      vodClass: json['vod_class'],
      vodActor: json['vod_actor'],
      vodTag: json['vod_tag'],
      vodScore: json['vod_score'],
      vodDoubanScore: json['vod_douban_score'],
      vodRemarks: json['vod_remarks'],
      vodSerial: json['vod_serial'],
      vodBlurb: json['vod_blurb'],
    );
  }
}
