import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:rikka/utils/utils.dart';

import 'logger_config.dart';

// 快速配置
final jsonLog = Logger(printer: JsonPrinter());
final tableLog = Logger(printer: TablePrinter());

// ---------- 全局日志类 ----------
class Log {
  static Logger? _logger;
  static LogConfig _config = LogConfig();
  static bool _initialized = false;
  static AppFileOutput? _fileOutput;

  Log._(); // 禁止实例化

  /// 初始化日志系统（建议在 main() 中调用）
  static Future<void> init(LogConfig config) async {
    // 先关闭旧的输出
    if (_initialized) {
      await _closeCurrentLogger();
    }
    _config = config;

    final level = _mapLevel(_config.level);
    final filter = LogFilterByLevel(level);

    // 构建输出目标
    final outputs = <LogOutput>[];
    if (_config.enableConsole) {
      outputs.add(ConsoleOutput());
    }

    if (_config.enableFile) {
      String dirPath = _config.fileDirectory;
      dirPath = await Utils.getDirectory();
      final logDir = Directory('$dirPath/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      _fileOutput = AppFileOutput(
        logDir: logDir,
        maxFileCount: _config.maxFileCount,
        maxAge: _config.fileMaxAge,
      );
      outputs.add(_fileOutput!);
    } else {
      _fileOutput = null; // 未启用文件日志时清空引用
    }

    final combinedOutput = outputs.length == 1
        ? outputs.single
        : MultiOutput(outputs);

    _logger = Logger(
      filter: filter,
      output: combinedOutput,
      printer: RikkaPrinter(),
    );

    _initialized = true;
  }

  /// 默认快速初始化（开发用）
  static Future<void> initDefault() async {
    await init(
      LogConfig(
        enableConsole: true,
        enableFile: false,
        isRelease: kReleaseMode,
        level: kDebugMode ? LogLevel.debug : LogLevel.warning,
      ),
    );
  }

  static Level _mapLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Level.debug;
      case LogLevel.info:
        return Level.info;
      case LogLevel.warning:
        return Level.warning;
      case LogLevel.error:
        return Level.error;
      case LogLevel.none:
        return Level.off;
    }
  }

  // ---------- 对外日志方法 ----------
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }

  // ★ 关闭时清空引用
  static Future<void> _closeCurrentLogger() async {
    if (_fileOutput != null) {
      await _fileOutput!.close();
    }
    _fileOutput = null;
    _logger = null;
  }

  // ★ 清理日志直接用 _fileOutput
  static Future<void> clearLogs() async {
    await _fileOutput?.clearAll();
  }

  // ★ 获取日志目录
  static Future<String?> getLogDirectory() async {
    return _fileOutput?.logDir.path;
  }
}

// ---------- 自定义日志拦截器 ----------
class LogFilterByLevel extends LogFilter {
  final Level filter;
  LogFilterByLevel(this.filter);

  @override
  bool shouldLog(LogEvent event) {
    return event.level.value >= filter.value;
  }
}

// ---------- 自定义文件输出（自动切割/清理） ----------
class AppFileOutput extends LogOutput {
  final Directory logDir;
  final int? maxFileCount;
  final Duration? maxAge;

  IOSink? _sink;
  File? _currentFile;
  DateTime _currentFileDate = DateTime.now();

  AppFileOutput({required this.logDir, this.maxFileCount, this.maxAge});

  @override
  void output(OutputEvent event) {
    // 同步写入（logger 内部已在 isolate 中调用，不会阻塞 UI）
    final line = '${event.lines.join('\n')}\n';
    _writeLine(line);
  }

  void _writeLine(String line) {
    try {
      _rotateIfNeeded();
      _sink?.write(line);
    } catch (_) {
      // 忽略写入异常
    }
  }

  /// 检查是否需要创建新文件
  void _rotateIfNeeded() {
    final now = DateTime.now();
    if (_currentFile == null ||
        now.difference(_currentFileDate).inDays > 0 ||
        (_currentFile!.existsSync() &&
            _currentFile!.lengthSync() > 10 * 1024 * 1024)) {
      _closeSink();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
      _currentFile = File('${logDir.path}/app_log_$timestamp.log');
      _sink = _currentFile!.openWrite(mode: FileMode.append);
      _currentFileDate = now;
      _cleanOldLogs();
    }
  }

  void _closeSink() {
    try {
      _sink?.close();
    } catch (_) {}
    _sink = null;
  }

  /// 清理超过数量或过期的日志文件
  Future<void> _cleanOldLogs() async {
    try {
      final files = logDir.listSync().whereType<File>().toList()
        ..sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

      // 按数量清理
      if (maxFileCount != null && files.length > maxFileCount!) {
        final toRemove = files.sublist(0, files.length - maxFileCount!);
        for (final file in toRemove) {
          await file.delete();
        }
      }

      // 按时间清理
      if (maxAge != null) {
        final cutoff = DateTime.now().subtract(maxAge!);
        for (final file in files) {
          if (file.lastModifiedSync().isBefore(cutoff)) {
            await file.delete();
          }
        }
      }
    } catch (_) {}
  }

  /// 清除所有日志文件
  Future<void> clearAll() async {
    _closeSink();
    _currentFile = null;
    try {
      if (logDir.existsSync()) {
        for (final entity in logDir.listSync()) {
          if (entity is File) await entity.delete();
        }
      }
    } catch (_) {}
  }

  /// 关闭输出流（重初始化时调用）
  Future<void> close() async {
    _closeSink();
  }
}
