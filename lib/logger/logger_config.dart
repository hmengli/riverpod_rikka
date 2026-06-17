import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

part 'logger_config.freezed.dart';

// ---------- 日志等级 ----------
enum LogLevel { debug, info, warning, error, none }

// ---------- 日志配置 ----------

@freezed
abstract class LogConfig with _$LogConfig {
  const factory LogConfig({
    @Default(LogLevel.debug) LogLevel level, // 最低输出等级
    @Default('yyyyMMdd_HHmmss') String dateFormat, // 日志输出格式
    @Default('/') String fileDirectory, // 自定义文件目录（不指定则使用默认）
    @Default(true) bool enableConsole, // 是否输出到控制台
    @Default(false) bool enableFile, // 是否输出到文件
    @Default(false) bool isRelease, // 是否 Release 模式（影响控制台颜色等）
    @Default(Duration(days: 7)) Duration fileMaxAge, // 日志文件最长保留时间
    @Default(10) int maxFileCount, // 最多保留日志文件数量
  }) = _LogConfig;
}

class RikkaPrinter extends LogPrinter {
  final AnsiColor Function(Level) levelColor;

  final bool printTime;

  final String dateFormat;

  RikkaPrinter({
    this.printTime = true,
    this.dateFormat = 'yyyy-MM-dd HH:mm:ss',
    this.levelColor = defaultLevelColors,
  });

  @override
  List<String> log(LogEvent event) {
    final color = levelColor(event.level);
    final level = emojis(event.level.name[0].toUpperCase());
    final time = emojis(DateFormat(dateFormat).format(DateTime.now()));
    return [color.call('$level $time ${event.message}')];
  }

  static String emojis(String val) => '[$val]';

  static AnsiColor defaultLevelColors(Level level) {
    return switch (level) {
      Level.debug => AnsiColor.fg(12),
      Level.info => AnsiColor.fg(46),
      Level.warning => AnsiColor.fg(208),
      Level.error => AnsiColor.fg(196),
      Level.fatal => AnsiColor.fg(199),
      _ => AnsiColor.fg(AnsiColor.grey(0.5)),
    };
  }

  static String Function(String) getBackgroundColor(Level level) {
    return switch (level) {
      Level.trace => (msg) => '\x1B[45m$msg\x1B[0m',
      Level.debug => (msg) => '\x1B[44m$msg\x1B[0m',
      Level.info => (msg) => '\x1B[42m$msg\x1B[0m',
      Level.warning => (msg) => '\x1B[43m$msg\x1B[0m',
      Level.error => (msg) => '\x1B[41m$msg\x1B[0m',
      Level.fatal => (msg) => '\x1B[40m$msg\x1B[0m',
      _ => (msg) => msg,
    };
  }
}

// 2. JSON 样式
class JsonPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final json = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': event.level.name,
      'message': event.message,
      'error': event.error?.toString(),
    };
    return [jsonEncode(json)];
  }
}

// 3. 表格样式
class TablePrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    final level = event.level.name.padRight(7);
    return [
      '┌─────────────────────────────────────────',
      '│ $time │ $level │ ${event.message}',
      '└─────────────────────────────────────────',
    ];
  }
}
