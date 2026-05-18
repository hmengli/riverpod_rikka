class ComicsEntity {
  static List<String> list = [
    'url',
    'vod_idvod_name',
    'vod_pic',
    'vod_pic_thumb',
    'vod_actor',
    'vod_tag',
    'vod_douban_score',
    'vod_remarks',
    'vod_serial',
    'vod_blurb',
  ];

  String url;
  int vodId;
  String vodName;
  String vodPic;
  String vodPicThumb;
  String vodActor;
  String vodTag;
  String vodDoubanScore;
  String vodRemarks;
  String vodSerial;
  String vodBlurb;

  ComicsEntity({
    required this.url,
    required this.vodId,
    required this.vodName,
    required this.vodPic,
    required this.vodPicThumb,
    required this.vodActor,
    required this.vodTag,
    required this.vodDoubanScore,
    required this.vodRemarks,
    required this.vodSerial,
    required this.vodBlurb,
  });

  factory ComicsEntity.fromJson(Map<String, dynamic> json) {
    return ComicsEntity(
      url: json['url'] as String,
      vodId: json['vod_id'] as int,
      vodName: json['vod_name'] as String,
      vodPic: json['vod_pic'] as String,
      vodPicThumb: json['vod_pic_thumb'] as String,
      vodActor: json['vod_actor'] as String,
      vodTag: json['vod_tag'] as String,
      // vodScore: json['vod_score'],
      vodDoubanScore: json['vod_douban_score'] as String,
      vodRemarks: json['vod_remarks'] as String,
      vodSerial: json['vod_serial'] as String,
      vodBlurb: json['vod_blurb'] as String,
    );
  }
}
