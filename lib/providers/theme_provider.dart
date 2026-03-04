import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

enum AppThemeMode { system, light, dark }

class ThemeSettings {
  final AppThemeMode themeMode;
  final Color? seedColor;
  final bool useDynamicColor;
  final bool useMaterial3;
  final bool useCustomFont;

  const ThemeSettings({
    this.themeMode = AppThemeMode.system,
    this.seedColor,
    this.useDynamicColor = true,
    this.useMaterial3 = true,
    this.useCustomFont = false,
  });

  ThemeSettings copyWith({
    AppThemeMode? themeMode,
    Color? seedColor,
    bool? useDynamicColor,
    bool? useMaterial3,
    bool? useCustomFont,
    bool clearSeedColor = false,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      seedColor: clearSeedColor ? null : (seedColor ?? this.seedColor),
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      useCustomFont: useCustomFont ?? this.useCustomFont,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeSettings> {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keySeedColor = 'seed_color';
  static const String _keyUseDynamicColor = 'use_dynamic_color';
  static const String _keyUseMaterial3 = 'use_material3';
  static const String _keyUseCustomFont = 'use_custom_font';

  ThemeNotifier() : super(const ThemeSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeModeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    final seedColorValue = prefs.getInt(_keySeedColor);
    final useDynamicColor = prefs.getBool(_keyUseDynamicColor) ?? true;
    final useMaterial3 = prefs.getBool(_keyUseMaterial3) ?? true;
    final useCustomFont = prefs.getBool(_keyUseCustomFont) ?? false;

    state = ThemeSettings(
      themeMode: AppThemeMode.values[themeModeIndex],
      seedColor: seedColorValue != null ? Color(seedColorValue) : null,
      useDynamicColor: useDynamicColor,
      useMaterial3: useMaterial3,
      useCustomFont: useCustomFont,
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

  Future<void> setUseDynamicColor(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseDynamicColor, value);
    state = state.copyWith(useDynamicColor: value);
  }

  Future<void> setUseMaterial3(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseMaterial3, value);
    state = state.copyWith(useMaterial3: value);
  }

  Future<void> setUseCustomFont(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseCustomFont, value);
    state = state.copyWith(useCustomFont: value);
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
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  return ThemeNotifier();
});

final colorSchemeProvider = Provider.family<ColorScheme, ColorScheme?>((ref, dynamicColorScheme) {
  final settings = ref.watch(themeProvider);
  
  if (settings.useDynamicColor && dynamicColorScheme != null) {
    return dynamicColorScheme;
  }
  
  final seedColor = settings.seedColor ?? AppTheme.presetSeedColors.first;
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: dynamicColorScheme?.brightness ?? Brightness.light,
  );
});

final themeDataProvider = Provider.family<ThemeData, ColorScheme?>((ref, dynamicColorScheme) {
  final settings = ref.watch(themeProvider);
  final colorScheme = ref.watch(colorSchemeProvider(dynamicColorScheme));
  
  return AppTheme.createTheme(
    colorScheme: colorScheme,
    useMaterial3: settings.useMaterial3,
    fontFamily: settings.useCustomFont ? 'OPPOSans' : null,
  );
});
