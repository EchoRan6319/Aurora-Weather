import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Application theme mode enumeration.
enum AppThemeMode { system, light, dark }

/// Theme settings persisted to SharedPreferences.
class ThemeSettings {
  final AppThemeMode themeMode;

  const ThemeSettings({
    this.themeMode = AppThemeMode.system,
  });

  ThemeSettings copyWith({AppThemeMode? themeMode}) {
    return ThemeSettings(themeMode: themeMode ?? this.themeMode);
  }
}

/// Theme notifier managing persisted theme settings state.
class ThemeNotifier extends StateNotifier<ThemeSettings> {
  static const String _keyThemeMode = 'theme_mode';

  /// Preloaded settings, set by [preload] before runApp.
  static ThemeSettings? _preloaded;

  /// Call in main() before runApp to avoid flash of default theme.
  static Future<void> preload() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    final safeThemeModeIndex =
        (themeModeIndex >= 0 && themeModeIndex < AppThemeMode.values.length)
            ? themeModeIndex
            : 0;

    _preloaded = ThemeSettings(
      themeMode: AppThemeMode.values[safeThemeModeIndex],
    );
  }

  ThemeNotifier() : super(_preloaded ?? const ThemeSettings());

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  ThemeMode get flutterThemeMode {
    switch (state.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  bool isDarkMode(BuildContext context) {
    if (state.themeMode == AppThemeMode.dark) return true;
    if (state.themeMode == AppThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }
}

/// Theme settings provider.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  return ThemeNotifier();
});
