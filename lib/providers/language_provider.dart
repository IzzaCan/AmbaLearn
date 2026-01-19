import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default to English

  Locale get locale => _locale;

  LanguageProvider() {
    // _loadSavedLanguage(); // Don't load in constructor
  }

  Future<void> init() async {
    await _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  bool get isIndonesian => _locale.languageCode == 'id';

  Future<void> changeLanguage(Locale newLocale) async {
    if (_locale == newLocale) return;
    
    _locale = newLocale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
  }

  // Helper for UI compatibility
  Future<void> setLanguage(String code) async {
    await changeLanguage(Locale(code));
  }
}
