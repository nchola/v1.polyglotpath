import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme =>
      _isDarkMode ? ThemeData.dark() : ThemeData.light();

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveTheme();
  }

  Future<void> _loadTheme() async {
    String? theme = await _storage.read(key: 'theme');
    if (theme != null) {
      _isDarkMode = theme == 'dark';
      notifyListeners();
    }
  }

  Future<void> _saveTheme() async {
    await _storage.write(key: 'theme', value: _isDarkMode ? 'dark' : 'light');
  }
}
