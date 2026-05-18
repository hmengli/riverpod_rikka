import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

part 'parser_entity.g.dart'; // 自动生成

enum VideoType { movie, comics }

class ParseResult {
  final String step1Content; // 第一步获取的原始HTML
  final List<String> step1Items; // 第一步提取的链接/内容
  final String step2Content; // 第二步获取的HTML（点击第一个链接）
  final List<Map<String, String>> finalData; // 最终提取的数据

  ParseResult({
    required this.step1Content,
    required this.step1Items,
    required this.step2Content,
    required this.finalData,
  });
}

@HiveType(typeId: 0)
class ParserEntity {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String basisUrl;
  @HiveField(3)
  String searchUrl;
  @HiveField(4)
  String searchHref;
  @HiveField(5)
  String searchTitle;
  @HiveField(6)
  String chapterRoad;
  @HiveField(7)
  String chapterList;
  @HiveField(8)
  String selectorIframe;
  @HiveField(9)
  String selectorM3u8;
  @HiveField(10)
  String selectorVideo;
  @HiveField(11)
  String referer;
  @HiveField(12)
  bool verify;
  @HiveField(13)
  String verifyPng;
  @HiveField(14)
  String verifyInput;
  @HiveField(15)
  String verifySubmit;

  @HiveField(20)
  DateTime createdAt;

  String cookie;

  ParserEntity({
    this.id = 0,
    this.name = '',
    this.basisUrl = '',
    this.searchUrl = '',
    this.searchHref = '',
    this.searchTitle = '',
    this.chapterRoad = '',
    this.chapterList = '',
    this.selectorIframe = '',
    this.selectorM3u8 = '',
    this.selectorVideo = '',
    this.referer = '',

    this.verify = false,
    this.verifyPng = '',
    this.verifyInput = '',
    this.verifySubmit = '',
    this.cookie = '',

    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'basisUrl': basisUrl,
    'searchUrl': searchUrl,
    'searchHref': searchHref,
    'searchTitle': searchTitle,
    'chapterRoad': chapterRoad,
    'chapterList': chapterList,
    'selectorIframe': selectorIframe,
    'selectorM3u8': selectorM3u8,
    'selectorVideo': selectorVideo,
    'referer': referer,

    'verify': verify,
    'verifyPng': verifyPng,
    'verifyInput': verifyInput,
    'verifySubmit': verifySubmit,
  };

  factory ParserEntity.fromJson(Map<String, dynamic> json) {
    return ParserEntity(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      basisUrl: json['basisUrl'] ?? '',
      searchUrl: json['searchUrl'] ?? '',
      searchHref: json['searchHref'] ?? '',
      searchTitle: json['searchTitle'] ?? '',
      chapterRoad: json['chapterRoad'] ?? '',
      chapterList: json['chapterList'] ?? '',
      selectorIframe: json['selectorIframe'] ?? '',
      selectorM3u8: json['selectorM3u8'] ?? '',
      selectorVideo: json['selectorVideo'] ?? '',
      referer: json['referer'] ?? '',

      verify: json['verify'] ?? false,
      verifyPng: json['verifyPng'] ?? '',
      verifyInput: json['verifyInput'] ?? '',
      verifySubmit: json['verifySubmit'] ?? '',

      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now()),
    );
  }

  ParserEntity fromJson(Map<String, dynamic> json) {
    return ParserEntity(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      basisUrl: json['basisUrl'] ?? '',
      searchUrl: json['searchUrl'] ?? '',
      searchHref: json['searchHref'] ?? '',
      searchTitle: json['searchTitle'] ?? '',
      chapterRoad: json['chapterRoad'] ?? '',
      chapterList: json['chapterList'] ?? '',
      selectorIframe: json['selectorIframe'] ?? '',
      selectorM3u8: json['selectorM3u8'] ?? '',
      selectorVideo: json['selectorVideo'] ?? '',
      referer: json['referer'] ?? '',

      verify: json['verify'] ?? false,
      verifyPng: json['verifyPng'] ?? '',
      verifyInput: json['verifyInput'] ?? '',
      verifySubmit: json['verifySubmit'] ?? '',

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, TextEditingController> getFieldsEdit() {
    return {
      'name': TextEditingController(text: name),
      'basisUrl': TextEditingController(text: basisUrl),
      'searchUrl': TextEditingController(text: searchUrl),
      'searchHref': TextEditingController(text: searchHref),
      'searchTitle': TextEditingController(text: searchTitle),
      'chapterRoad': TextEditingController(text: chapterRoad),
      'chapterList': TextEditingController(text: chapterList),
      'selectorIframe': TextEditingController(text: selectorIframe),
      'selectorM3u8': TextEditingController(text: selectorM3u8),
      'selectorVideo': TextEditingController(text: selectorVideo),
      'referer': TextEditingController(text: referer),
    };
  }
}
