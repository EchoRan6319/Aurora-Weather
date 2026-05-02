import 'package:flutter/material.dart';

/// Maps weather codes to Aurora gradient color palettes.
class WeatherGradientScheme {
  const WeatherGradientScheme._();

  /// Returns gradient colors for [code] and [isDark] mode.
  static List<Color> forCode(int code, {bool isDark = false}) {
    if (code >= 300 && code <= 399) return isDark ? _rainDark : _rainLight;
    if (code >= 400 && code <= 499) return isDark ? _snowDark : _snowLight;
    if (code >= 500 && code <= 515) return isDark ? _fogDark : _fogLight;
    if (code == 100 || code == 150) return isDark ? _sunnyDark : _sunnyLight;
    if (code == 900) return isDark ? _hotDark : _hotLight;
    if (code == 901) return isDark ? _coldDark : _coldLight;
    return isDark ? _cloudyDark : _cloudyLight;
  }

  static bool isSunny(int code) => code == 100 || code == 150;
  static bool isRainy(int code) => code >= 300 && code <= 399;
  static bool isSnowy(int code) => code >= 400 && code <= 499;

  // ── Light gradients ────────────────────────────

  static const List<Color> _sunnyLight = [
    Color(0xFF87CEEB),
    Color(0xFF4A90D9),
    Color(0xFFF0C060),
    Color(0xFFE8833A),
  ];

  static const List<Color> _cloudyLight = [
    Color(0xFFB0C4DE),
    Color(0xFF8E9EAB),
    Color(0xFFD3D3D3),
    Color(0xFFE8E8E8),
  ];

  static const List<Color> _rainLight = [
    Color(0xFF2C3E50),
    Color(0xFF4A6FA5),
    Color(0xFF7B9FC5),
    Color(0xFFA8C4D8),
  ];

  static const List<Color> _snowLight = [
    Color(0xFFE8F0F8),
    Color(0xFFC8DCE8),
    Color(0xFFA8C8E0),
    Color(0xFFD0E8F8),
  ];

  static const List<Color> _fogLight = [
    Color(0xFFCFD8DC),
    Color(0xFFB0BEC5),
    Color(0xFF90A4AE),
    Color(0xFFECEFF1),
  ];

  static const List<Color> _hotLight = [
    Color(0xFFFF8C00),
    Color(0xFFFFA726),
    Color(0xFFFFD54F),
    Color(0xFFFF7043),
  ];

  static const List<Color> _coldLight = [
    Color(0xFF81D4FA),
    Color(0xFF4FC3F7),
    Color(0xFFE1F5FE),
    Color(0xFFB3E5FC),
  ];

  // ── Dark gradients — Aurora midnight ────────────

  static const List<Color> _sunnyDark = [
    Color(0xFF0B0A1A),
    Color(0xFF1A1040),
    Color(0xFF003544),
    Color(0xFF4A1025),
  ];

  static const List<Color> _cloudyDark = [
    Color(0xFF0B0A1A),
    Color(0xFF1D1838),
    Color(0xFF2D1750),
    Color(0xFF120F28),
  ];

  static const List<Color> _rainDark = [
    Color(0xFF070618),
    Color(0xFF003544),
    Color(0xFF1D1838),
    Color(0xFF282348),
  ];

  static const List<Color> _snowDark = [
    Color(0xFF0B0A1A),
    Color(0xFF282348),
    Color(0xFF443068),
    Color(0xFF1D1838),
  ];

  static const List<Color> _fogDark = [
    Color(0xFF0B0A1A),
    Color(0xFF1D1838),
    Color(0xFF2D1750),
    Color(0xFF120F28),
  ];

  static const List<Color> _hotDark = [
    Color(0xFF1A0510),
    Color(0xFF6B003B),
    Color(0xFF3A0020),
    Color(0xFF4A0025),
  ];

  static const List<Color> _coldDark = [
    Color(0xFF070618),
    Color(0xFF004D60),
    Color(0xFF003544),
    Color(0xFF120F28),
  ];
}
