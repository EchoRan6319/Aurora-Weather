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

  // ── Dark mode — Clean blue palette ───────────

  static const Color darkPrimary = Color(0xFF60A5FA);         // Clear blue
  static const Color darkOnPrimary = Color(0xFF003061);
  static const Color darkPrimaryContainer = Color(0xFF004A8C);
  static const Color darkOnPrimaryContainer = Color(0xFFD1E4FF);

  static const Color darkSecondary = Color(0xFF90CAF9);       // Soft light blue
  static const Color darkOnSecondary = Color(0xFF0A3060);
  static const Color darkSecondaryContainer = Color(0xFF1A4070);
  static const Color darkOnSecondaryContainer = Color(0xFFD6E8FF);

  static const Color darkTertiary = Color(0xFF80CBC4);        // Muted teal
  static const Color darkOnTertiary = Color(0xFF003731);
  static const Color darkTertiaryContainer = Color(0xFF005046);
  static const Color darkOnTertiaryContainer = Color(0xFFB2F0E5);

  static const Color darkError = Color(0xFFFF6B6B);
  static const Color darkOnError = Color(0xFF3B0000);
  static const Color darkErrorContainer = Color(0xFF5F0000);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color darkSurface = Color(0xFF111827);         // Blue-gray dark
  static const Color darkOnSurface = Color(0xFFE2E8F0);
  static const Color darkOnSurfaceVariant = Color(0xFFB0BEC5);
  static const Color darkOutline = Color(0xFF6B7B8D);
  static const Color darkOutlineVariant = Color(0xFF374151);
  static const Color darkSurfaceContainerLowest = Color(0xFF0D1117);
  static const Color darkSurfaceContainer = Color(0xFF1A2332);
  static const Color darkSurfaceContainerHigh = Color(0xFF243044);
  static const Color darkSurfaceContainerHighest = Color(0xFF2E3D56);
  static const Color darkSurfaceTint = Color(0xFF60A5FA);
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

}
