import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Application theme mode enumeration.
enum AppThemeMode { system, light, dark }

/// Theme settings persisted to SharedPreferences.
class ThemeSettings {
  final AppThemeMode themeMode;
  final Color? seedColor;
  final bool useAmoledBlack;

  const ThemeSettings({
    this.themeMode = AppThemeMode.system,
    this.seedColor,
    this.useAmoledBlack = false,
  });

  ThemeSettings copyWith({
    AppThemeMode? themeMode,
    Color? seedColor,
    bool? useAmoledBlack,
    bool clearSeedColor = false,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      seedColor: clearSeedColor ? null : (seedColor ?? this.seedColor),
      useAmoledBlack: useAmoledBlack ?? this.useAmoledBlack,
    );
  }
}

/// Theme notifier managing persisted theme settings state.
class ThemeNotifier extends StateNotifier<ThemeSettings> {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keySeedColor = 'seed_color';
  static const String _keyUseAmoledBlack = 'use_amoled_black';

  ThemeNotifier() : super(const ThemeSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    final safeThemeModeIndex =
        (themeModeIndex >= 0 && themeModeIndex < AppThemeMode.values.length)
            ? themeModeIndex
            : 0;
    final seedColorValue = prefs.getInt(_keySeedColor);
    final useAmoledBlack = prefs.getBool(_keyUseAmoledBlack) ?? false;

    state = ThemeSettings(
      themeMode: AppThemeMode.values[safeThemeModeIndex],
      seedColor: seedColorValue != null ? Color(seedColorValue) : null,
      useAmoledBlack: useAmoledBlack,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setSeedColor(Color? color) async {
    final prefs = await SharedPreferences.getInstance();
    if (color != null) {
      await prefs.setInt(_keySeedColor, color.toARGB32());
    } else {
      await prefs.remove(_keySeedColor);
    }
    state = state.copyWith(seedColor: color, clearSeedColor: color == null);
  }

  Future<void> setUseAmoledBlack(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseAmoledBlack, value);
    state = state.copyWith(useAmoledBlack: value);
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

  bool get isAmoledBlackEnabled {
    if (state.themeMode == AppThemeMode.light) return false;
    return state.useAmoledBlack;
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
