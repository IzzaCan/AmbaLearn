import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme modes available in the app
enum ThemeModeOption { system, light, dark }

/// Provider to manage theme state and persistence
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeModeOption _themeMode = ThemeModeOption.system;
  SharedPreferences? _prefs;

  ThemeModeOption get themeMode => _themeMode;

  /// Returns the actual ThemeMode for MaterialApp
  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  /// Returns true if currently in dark mode (considering system preference)
  bool get isDarkMode {
    if (_themeMode == ThemeModeOption.dark) return true;
    if (_themeMode == ThemeModeOption.light) return false;
    // System mode - check platform brightness
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  /// Get theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeModeOption.system:
        return 'System';
      case ThemeModeOption.light:
        return 'Light';
      case ThemeModeOption.dark:
        return 'Dark';
    }
  }

  /// Initialize and load saved theme preference
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadTheme();
  }

  /// Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    final savedTheme = _prefs?.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = ThemeModeOption.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => ThemeModeOption.system,
      );
      notifyListeners();
    }
  }

  /// Set theme mode and persist
  Future<void> setThemeMode(ThemeModeOption mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _prefs?.setString(_themeKey, mode.name);
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeModeOption.dark) {
      await setThemeMode(ThemeModeOption.light);
    } else {
      await setThemeMode(ThemeModeOption.dark);
    }
  }

  /// Cycle through theme modes: System -> Light -> Dark -> System
  Future<void> cycleThemeMode() async {
    switch (_themeMode) {
      case ThemeModeOption.system:
        await setThemeMode(ThemeModeOption.light);
        break;
      case ThemeModeOption.light:
        await setThemeMode(ThemeModeOption.dark);
        break;
      case ThemeModeOption.dark:
        await setThemeMode(ThemeModeOption.system);
        break;
    }
  }

  /// Get icon for current theme mode
  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeModeOption.system:
        return Icons.brightness_auto;
      case ThemeModeOption.light:
        return Icons.light_mode;
      case ThemeModeOption.dark:
        return Icons.dark_mode;
    }
  }
}
