import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';

class ThemeController extends ChangeNotifier {
  static const _prefKey = 'active_theme_id';

  AppTheme _current = AppThemes.all.first;

  AppTheme get current => _current;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefKey);
    if (id != null) {
      _current = AppThemes.byId(id);
      notifyListeners();
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    if (_current.id == theme.id) return;
    _current = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, theme.id);
  }
}
