import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    String? build = GetStorage().read('ThemeMode');
    return ThemeMode.values.firstWhere(
      (e) => e.name == build,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    await GetStorage().write('ThemeMode', mode.name);
    state = mode;
  }
}

@riverpod
class ThemeIndexNotifier extends _$ThemeIndexNotifier {
  @override
  int build() => 0;

  void setSelectedIndex(int newValue) {
    state = newValue;
  }
}

// class ThemeProvider extends ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.system; // 默认跟随系统
//   bool _onChanged = false; // 默认跟随系统
//   int _selectedIndex = 0;

//   ThemeMode get themeMode => _themeMode;
//   bool get onChanged => _onChanged;
//   int get selectedIndex => _selectedIndex;

//   String selectedValue = 'light';

//   void setSelectedIndex(int newValue) {
//     _selectedIndex = newValue;
//     notifyListeners();
//   }

//   void changeThemeMode(bool b) {
//     _themeMode = b ? ThemeMode.dark : ThemeMode.system;
//     _onChanged = b;
//     notifyListeners();
//   }
// }
