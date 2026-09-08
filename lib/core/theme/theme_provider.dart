import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeSelection { system, light, dark }

final themeProvider = NotifierProvider<ThemeNotifier, ThemeSelection>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeSelection> {
  static const _key = 'theme_selection';
  late SharedPreferences _prefs;

  @override
  ThemeSelection build() {
    _init();
    return ThemeSelection.system;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs.getString(_key);
    if (saved != null) {
      state = ThemeSelection.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => ThemeSelection.system,
      );
    }
  }

  Future<void> setTheme(ThemeSelection selection) async {
    state = selection;
    await _prefs.setString(_key, selection.name);
  }

  ThemeMode get themeMode {
    return switch (state) {
      ThemeSelection.system => ThemeMode.system,
      ThemeSelection.light => ThemeMode.light,
      ThemeSelection.dark => ThemeMode.dark,
    };
  }
}
