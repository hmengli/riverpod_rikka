class ComicsEntity {
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

  String url;
  int vodId;
  String vodName;
  String vodPic;
  String? vodPicThumb;
  String? vodClass;
  String? vodActor;
  String? vodTag;
  String? vodScore;
  String? vodDoubanScore;
  String? vodRemarks;
  String? vodSerial;
  String? vodBlurb;

  ComicsEntity({
    required this.url,
    required this.vodId,
    required this.vodName,
    required this.vodPic,
    this.vodPicThumb,
    this.vodClass,
    this.vodActor,
    this.vodTag,
    this.vodScore,
    this.vodDoubanScore,
    this.vodRemarks,
    this.vodSerial,
    this.vodBlurb,
  });

  factory ComicsEntity.fromJson(Map<String, dynamic> json) {
    return ComicsEntity(
      url:
          json['url'] ??
          'https://www.gugu3.com/index.php/vod/search/wd/${json['vod_id']}.html',
      vodId: json['vod_id'] as int,
      vodName: json['vod_name'] as String,
      vodPic: json['vod_pic'].toString().replaceAll('\\', ''),
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
