import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';

class Utils {
  static const String m3u8 = '.m3u8';
  static const String png = '.png';
  static const String ts = '.ts';

  static const List<String> ua_list = [
    'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Maxthon 2.0',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11',
    'User-Agent:Opera/9.80 (Windows NT 6.1; U; en) Presto/2.8.131 Version/11.11',
    'Mozilla/5.0 (Windows NT 6.1; rv:2.0.1) Gecko/20100101 Firefox/4.0.1',
    'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)',
    'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-us) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50',
    'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0',
    ' Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1',
    'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1',
    ' Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1',
  ];

  static String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36';

  /// 检查分片文件的真实格式（魔数检查）
  void checkFileFormat(File file) async {
    final bytes = await file.openRead(0, 16).first;

    // 常见文件头魔数
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    debugPrint('文件头魔数: $hex');

    if (hex.startsWith('47')) {
      debugPrint('✅ 这是 TS 视频分片 (0x47 同步字节)');
    } else if (hex.startsWith('ff d8 ff')) {
      debugPrint('❌ 这是 JPEG 图片！说明下载到的是伪装图片');
    } else if (hex.startsWith('52 49 46 46')) {
      debugPrint('❌ 这是 WEBP 图片！说明下载到的是伪装图片');
    } else if (hex.startsWith('89 50 4e 47')) {
      debugPrint('❌ 这是 PNG 图片！说明下载到的是伪装图片');
    } else {
      debugPrint('⚠️ 未知格式: $hex');
      // 打印前 200 个可见字符，看看是不是文本
      final sample = await file.openRead(0, 200).first;
      final text = String.fromCharCodes(
        sample.where((b) => b >= 32 && b <= 126),
      );
      debugPrint('内容预览: $text');
    }
  }

  /// 判断是否为桌面设备
  static bool isDesktop() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  static bool isTablet() {
    return true;
  }

  static String stringToHex(String input) {
    // 1. 转成 UTF-8 字节列表
    List<int> bytes = utf8.encode(input);
    // 2. 每个字节 => 两位十六进制（小写）
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  static String hexToString(String hex) {
    // 确保长度为偶数
    if (hex.length % 2 != 0) throw ArgumentError('Invalid hex string');

    // 每两个字符转成一个字节
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      String byteStr = hex.substring(i, i + 2);
      bytes.add(int.parse(byteStr, radix: 16));
    }
    // UTF-8 解码
    return utf8.decode(bytes);
  }

  /// 将 URL 编码为十六进制字符串
  static String encode(String url) {
    List<int> bytes = utf8.encode(url);
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// 将十六进制字符串解码为 URL
  static String decode(String hex) {
    if (hex.isEmpty) return '';

    // 移除可能的前缀
    String clean = hex;
    if (clean.startsWith('0x')) {
      clean = clean.substring(2);
    }

    // 确保长度为偶数
    if (clean.length % 2 != 0) {
      clean = '0$clean';
    }

    List<int> bytes = [];
    for (int i = 0; i < clean.length; i += 2) {
      String byteStr = clean.substring(i, i + 2);
      bytes.add(int.parse(byteStr, radix: 16));
    }

    return utf8.decode(bytes);
  }

  static const List<String> weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  // 获取中文星期几（完整版）
  static String getChineseWeekday(DateTime date, {bool short = false}) {
    if (short) {
      List<String> weekdays = ['一', '二', '三', '四', '五', '六', '日'];
      return weekdays[date.weekday - 1];
    } else {
      List<String> weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
      return weekdays[date.weekday - 1];
    }
  }

  // 获取英文星期几
  static String getEnglishWeekday(DateTime date, {bool short = false}) {
    if (short) {
      List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else {
      List<String> weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return weekdays[date.weekday - 1];
    }
  }

  // 判断是否是周末
  static bool isWeekend(DateTime date) {
    return date.weekday == 6 || date.weekday == 7;
  }

  // 判断是否是工作日
  static bool isWeekday(DateTime date) {
    return !isWeekend(date);
  }

  // 判断是否是周一
  static bool isMonday(DateTime date) {
    return date.weekday == 1;
  }

  // 判断是否是周日
  static bool isSunday(DateTime date) {
    return date.weekday == 7;
  }

  // 判断是否是周日
  static bool isToday(DateTime date, int index) {
    return date.weekday - 1 == index;
  }

  // 获取星期几的数字（可自定义起始）
  static int getWeekdayNumber(DateTime date, {bool startFromMonday = true}) {
    if (startFromMonday) {
      return date.weekday; // 1-7 周一到周日
    } else {
      // 周日为0，周六为6
      return date.weekday % 7;
    }
  }

  // 获取星期几的emoji
  static String getWeekdayEmoji(DateTime date) {
    List<String> emojis = ['📅', '📅', '📅', '📅', '📅', '🎉', '🎉'];
    return emojis[date.weekday - 1];
  }

  static String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  static final List<String> desktopChrome = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  ];

  // 移动端 Chrome
  static final List<String> mobileChrome = [
    'Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/120.0.0.0 Mobile/15E148 Safari/604.1',
  ];

  // Safari
  static final List<String> safari = [
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Mobile/15E148 Safari/604.1',
  ];

  // Firefox
  static final List<String> firefox = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:120.0) Gecko/20100101 Firefox/120.0',
  ];

  // 全部合并
  static final List<String> all = [
    ...desktopChrome,
    ...mobileChrome,
    ...safari,
    ...firefox,
  ];

  static String getRandomUA() {
    final Random random = Random();
    return desktopChrome[random.nextInt(desktopChrome.length)];
  }
}
