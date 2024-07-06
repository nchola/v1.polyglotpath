import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferences {
  static const String _selectedLanguageKey = 'selectedLanguage';

  Future<void> saveSelectedLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLanguageKey, language);
  }

  Future<String?> getSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedLanguageKey);
  }
}
