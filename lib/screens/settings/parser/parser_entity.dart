import 'package:flutter/material.dart';

abstract class Entity {
  String basisUrl;
  Entity({required this.basisUrl});
}

enum VideoType { movie, comics, comicsApi, movieApi }

class ParserEntity extends Entity {
  int id;
  String name;
  String searchUrl;
  String searchHref;
  String searchTitle;
  String chapterRoad;
  String chapterList;
  String selectorIframe;
  String selectorM3u8;
  String selectorVideo;
  String referer;
  bool verify;
  String verifyPng;
  String verifyInput;
  String verifySubmit;

  DateTime? createdAt;
  String cookie;
  VideoType? videoType;

  ParserEntity({
    this.id = 0,
    this.name = '',
    super.basisUrl = '',
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
    this.videoType,

    this.createdAt,
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
