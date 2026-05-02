import 'package:flutter/material.dart';

/// Aurora UI fixed palette - replaces Material 3 seed color generation.
///
/// Light mode: fresh, vibrant sky tones.
/// Dark mode: deep, mysterious night tones.
class AuroraPalette {
  const AuroraPalette._();

  // ── Light mode ──────────────────────────────────

  static const Color lightPrimary = Color(0xFF0061A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFD1E4FF);
  static const Color lightOnPrimaryContainer = Color(0xFF001D36);

  static const Color lightSecondary = Color(0xFF535F70);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFD7E3F7);
  static const Color lightOnSecondaryContainer = Color(0xFF101C2B);

  static const Color lightTertiary = Color(0xFF6B5778);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFF2DAFF);
  static const Color lightOnTertiaryContainer = Color(0xFF251431);

  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF410002);

  static const Color lightSurface = Color(0xFFFDFCFF);
  static const Color lightOnSurface = Color(0xFF1A1C1E);
  static const Color lightOnSurfaceVariant = Color(0xFF43474E);
  static const Color lightOutline = Color(0xFF73777F);
  static const Color lightOutlineVariant = Color(0xFFC3C7CF);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF0F4FA);
  static const Color lightSurfaceContainerHigh = Color(0xFFEAEEF5);
  static const Color lightSurfaceContainerHighest = Color(0xFFE4E8EF);
  static const Color lightSurfaceTint = Color(0xFF0061A4);
  static const Color lightShadow = Color(0xFF000000);
  static const Color lightScrim = Color(0xFF000000);

  // ── Dark mode ──────────────────────────────────

  static const Color darkPrimary = Color(0xFF9ECAFF);
  static const Color darkOnPrimary = Color(0xFF003258);
  static const Color darkPrimaryContainer = Color(0xFF00497D);
  static const Color darkOnPrimaryContainer = Color(0xFFD1E4FF);

  static const Color darkSecondary = Color(0xFFBBC7DB);
  static const Color darkOnSecondary = Color(0xFF253140);
  static const Color darkSecondaryContainer = Color(0xFF3B4858);
  static const Color darkOnSecondaryContainer = Color(0xFFD7E3F7);

  static const Color darkTertiary = Color(0xFFD7BDE4);
  static const Color darkOnTertiary = Color(0xFF3B2948);
  static const Color darkTertiaryContainer = Color(0xFF523F5F);
  static const Color darkOnTertiaryContainer = Color(0xFFF2DAFF);

  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color darkSurface = Color(0xFF1A1C1E);
  static const Color darkOnSurface = Color(0xFFE2E2E6);
  static const Color darkOnSurfaceVariant = Color(0xFFC3C7CF);
  static const Color darkOutline = Color(0xFF8D9199);
  static const Color darkOutlineVariant = Color(0xFF43474E);
  static const Color darkSurfaceContainerLowest = Color(0xFF0E1114);
  static const Color darkSurfaceContainer = Color(0xFF1E2024);
  static const Color darkSurfaceContainerHigh = Color(0xFF282A2E);
  static const Color darkSurfaceContainerHighest = Color(0xFF333539);
  static const Color darkSurfaceTint = Color(0xFF9ECAFF);
  static const Color darkShadow = Color(0xFF000000);
  static const Color darkScrim = Color(0xFF000000);

  static ColorScheme lightColorScheme() {
    return ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: lightOnPrimary,
      primaryContainer: lightPrimaryContainer,
      onPrimaryContainer: lightOnPrimaryContainer,
      secondary: lightSecondary,
      onSecondary: lightOnSecondary,
      secondaryContainer: lightSecondaryContainer,
      onSecondaryContainer: lightOnSecondaryContainer,
      tertiary: lightTertiary,
      onTertiary: lightOnTertiary,
      tertiaryContainer: lightTertiaryContainer,
      onTertiaryContainer: lightOnTertiaryContainer,
      error: lightError,
      onError: lightOnError,
      errorContainer: lightErrorContainer,
      onErrorContainer: lightOnErrorContainer,
      surface: lightSurface,
      onSurface: lightOnSurface,
      onSurfaceVariant: lightOnSurfaceVariant,
      outline: lightOutline,
      outlineVariant: lightOutlineVariant,
      surfaceContainerLowest: lightSurfaceContainerLowest,
      surfaceContainer: lightSurfaceContainer,
      surfaceContainerHigh: lightSurfaceContainerHigh,
      surfaceContainerHighest: lightSurfaceContainerHighest,
      surfaceTint: lightSurfaceTint,
      shadow: lightShadow,
      scrim: lightScrim,
    );
  }

  static ColorScheme darkColorScheme() {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimary,
      onPrimary: darkOnPrimary,
      primaryContainer: darkPrimaryContainer,
      onPrimaryContainer: darkOnPrimaryContainer,
      secondary: darkSecondary,
      onSecondary: darkOnSecondary,
      secondaryContainer: darkSecondaryContainer,
      onSecondaryContainer: darkOnSecondaryContainer,
      tertiary: darkTertiary,
      onTertiary: darkOnTertiary,
      tertiaryContainer: darkTertiaryContainer,
      onTertiaryContainer: darkOnTertiaryContainer,
      error: darkError,
      onError: darkOnError,
      errorContainer: darkErrorContainer,
      onErrorContainer: darkOnErrorContainer,
      surface: darkSurface,
      onSurface: darkOnSurface,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,
      surfaceContainerLowest: darkSurfaceContainerLowest,
      surfaceContainer: darkSurfaceContainer,
      surfaceContainerHigh: darkSurfaceContainerHigh,
      surfaceContainerHighest: darkSurfaceContainerHighest,
      surfaceTint: darkSurfaceTint,
      shadow: darkShadow,
      scrim: darkScrim,
    );
  }

  /// AMOLED pure-black dark variant.
  static ColorScheme amoledBlackColorScheme() {
    final base = darkColorScheme();
    return base.copyWith(
      surface: Colors.black,
      surfaceContainer: const Color(0xFF121212),
      surfaceContainerHigh: const Color(0xFF1E1E1E),
      surfaceContainerHighest: const Color(0xFF2C2C2C),
      surfaceTint: Colors.transparent,
      shadow: Colors.black,
    );
  }
}
