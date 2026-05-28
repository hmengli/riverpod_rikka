import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rikka/utils/logger.dart';

import '../settings_page.dart';

class CloudPage extends StatefulWidget {
  const CloudPage({super.key, required this.title});
  final String title;

  @override
  State<CloudPage> createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {
  final box = GetStorage();
  late TextEditingController supabaseUrl;
  late TextEditingController supabaseAnonKey;

  @override
  void initState() {
    super.initState();
    String? url = box.read('supabaseUrl');
    String? anonKey = box.read('supabaseAnonKey');
    supabaseUrl = TextEditingController(text: url);
    supabaseAnonKey = TextEditingController(text: anonKey);
  }

  @override
  void dispose() {
    supabaseUrl.dispose();
    supabaseAnonKey.dispose();
    super.dispose();
  }

  void saveState(BuildContext context) {
    validate(context, (url, anonKey) {
      box.write('supabaseUrl', url);
      box.write('supabaseAnonKey', anonKey);
      return Text('保存成功！');
    });
  }

  void validateState(BuildContext context) {
    validate(context, (url, anonKey) {
      return Text('success！');
    });
  }

  Future<dynamic> validate(
    BuildContext context,
    Widget Function(String url, String anonKey) success,
  ) {
    String url = supabaseUrl.text;
    String anonKey = supabaseAnonKey.text;
    return showDialog(
      context: context,
      barrierDismissible: false, // 点击外部不关闭
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: FutureBuilder<ValidationResult>(
                  future: AppStartupValidator.validate(url, anonKey),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // 加载中
                    } else if (snapshot.hasError) {
                      Log.e('错误: ${snapshot.error}');
                      return Text("错误: ${snapshot.error}"); // 错误状态
                    } else if (snapshot.hasData) {
                      switch (snapshot.data) {
                        case ValidationResult.success:
                          return success.call(url, anonKey);
                        case null:
                          return Text('空异常！');
                        case ValidationResult.noInternet:
                          return Text('网络连接错误！');
                        case ValidationResult.supabaseUnreachable:
                          return Text('指令没有送达！');
                      }
                    } else {
                      return Text("无数据");
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('确定'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SettingsButton(
            title: 'Supabase方案',
            onPressed: () => _showCustomDialog(context),
          ),
        ],
      ),
    );
  }

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          clipBehavior: Clip.antiAlias,
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 600,
            height: 300,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: supabaseUrl,
                    decoration: InputDecoration(
                      labelText: "supabaseUrl",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: supabaseAnonKey,
                    decoration: InputDecoration(
                      labelText: "supabaseAnonKey",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SettingsButton(
                  title: '检测方案',
                  onPressed: () {
                    validateState(context);
                  },
                ),
                SettingsButton(
                  title: '保存方案',
                  onPressed: () {
                    saveState(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NetworkUtils {
  static Future<bool> hasInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }
}

class SupabaseHealthChecker {
  static Future<HealthStatus> check(String supabaseUrl, String anonKey) async {
    final Uri healthUri = Uri.parse('$supabaseUrl/auth/v1/health');

    try {
      final response = await http
          .get(healthUri, headers: {'apikey': anonKey})
          .timeout(Duration(seconds: 10));
      // 根据状态码和业务返回判断健康状况
      // 状态码为 200，且响应体中的 name 为 "GoTrue" 表示服务健康
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['name'] == 'GoTrue') {
        return HealthStatus.ok;
      } else {
        return HealthStatus.unhealthy;
      }
    } catch (e) {
      // 超时或网络错误时，返回连接失败
      return HealthStatus.unreachable;
    }
  }
}

enum HealthStatus { ok, unhealthy, unreachable }

class AppStartupValidator {
  static Future<ValidationResult> validate(
    String supabaseUrl,
    String anonKey,
  ) async {
    // 1. 网络检查
    if (!await NetworkUtils.hasInternet()) {
      return ValidationResult.noInternet;
    }
    // 2. Supabase 服务健康检查
    final health = await SupabaseHealthChecker.check(supabaseUrl, anonKey);
    if (health != HealthStatus.ok) {
      return ValidationResult.supabaseUnreachable;
    }
    // 全部通过，返回成功
    return ValidationResult.success;
  }
}

// 定义对应的 Enum 来区分不同状态的 UI 提示
enum ValidationResult { success, noInternet, supabaseUnreachable }
