import 'dart:convert';

import 'package:hive_ce/hive.dart';

class SettingKey {
  static const String hAenable = 'hAenable';

  static const String exitBehavior = "exitBehavior";
}

class GStorage {
  static late final Box<dynamic> setting;
}

class HiveUtil {
  HiveUtil._internal(); // 私有的构造方法，防止外部实例化

  factory HiveUtil() => _instance; // 工厂方法，返回 HiveUtil 唯一实例

  static final HiveUtil _instance = HiveUtil._internal(); // HiveUtil 唯一实例

  static late Box _box; // Hive Box 对象

  static Future<HiveUtil> getInstance(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox(boxName); // 打开 Hive Box 实例
    } else {
      _box = Hive.box(boxName); // 如果已经打开，则获取实例
    }
    return _instance;
  }

  //根据hive删除整个文件
  Future<bool> deleteBox(String boxName) async {
    try {
      await Hive.deleteBoxFromDisk(boxName);
      return true; // 删除成功
    } catch (e) {
      return false; // 删除失败
    }
  }

  // 根据 key 删除数据，并返回删除是否成功
  static Future<bool> deleteKey(String key) async {
    try {
      await _box.delete(key);

      // 验证键是否仍存在
      bool isDeleted = !_box.containsKey(key);
      return isDeleted;
    } catch (e) {
      return false; // 删除失败
    }
  }

  /// 根据 key 存储 int 类型
  static Future<void> setInt(String key, int value) async {
    await _box.put(key, value); // 使用 Hive 存储 int 类型的数据
  }

  /// 根据 key 获取 int 类型
  static int? getInt(String key, {int defaultValue = 0}) {
    return _box.get(
      key,
      defaultValue: defaultValue,
    ); // 使用 Hive 获取 int 类型数据，如果不存在则返回默认值
  }

  /// 根据 key 存储 double 类型
  static Future<void> setDouble(String key, double value) async {
    await _box.put(key, value); // 使用 Hive 存储 double 类型的数据
  }

  /// 根据 key 获取 double 类型
  static double? getDouble(String key, {double defaultValue = 0.0}) {
    return _box.get(
      key,
      defaultValue: defaultValue,
    ); // 使用 Hive 获取 double 类型数据，如果不存在则返回默认值
  }

  /// 根据 key 存储字符串类型
  static Future<void> setString(String key, String value) async {
    await _box.put(key, value); // 使用 Hive 存储字符串类型的数据
  }

  /// 根据 key 获取字符串类型
  static String? getString(String key, {String defaultValue = ""}) {
    return _box.get(
      key,
      defaultValue: defaultValue,
    ); // 使用 Hive 获取字符串类型数据，如果不存在则返回默认值
  }

  /// 根据 key 存储布尔类型
  static Future<void> setBool(String key, bool value) async {
    await _box.put(key, value); // 使用 Hive 存储布尔类型的数据
  }

  /// 根据 key 获取布尔类型
  static bool? getBool(String key, {bool defaultValue = false}) {
    return _box.get(
      key,
      defaultValue: defaultValue,
    ); // 使用 Hive 获取布尔类型数据，如果不存在则返回默认值
  }

  /// 根据 key 存储字符串类型数组
  static Future<void> setStringList(String key, List<String> value) async {
    await _box.put(key, value); // 使用 Hive 存储字符串类型数组
  }

  /// 根据 key 获取字符串类型数组
  static List<String> getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) {
    return _box.get(
      key,
      defaultValue: defaultValue,
    ); // 使用 Hive 获取字符串类型数组，如果不存在则返回默认值
  }

  /// 根据 key 存储 Map 类型
  static Future<void> setMap(String key, Map<String, dynamic> value) async {
    await _box.put(
      key,
      json.encode(value),
    ); // 使用 Hive 存储 Map 类型的数据，将 Map 转为 json 字符串存储
  }

  /// 根据 key 获取 Map 类型
  static Map<String, dynamic> getMap(String key) {
    String jsonStr = _box.get(key, defaultValue: ""); // 使用 Hive 获取存储的 json 字符串
    return jsonStr.isEmpty
        ? {}
        : json.decode(jsonStr); // 将 json 字符串解码为 Map 对象，如果 json 为空则返回空 Map 对象
  }
}
