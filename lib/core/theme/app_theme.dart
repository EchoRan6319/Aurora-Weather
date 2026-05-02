import 'package:flutter/material.dart';

@immutable
class AppUiTokens extends ThemeExtension<AppUiTokens> {
  final Color cardBackground;
  final Color cardBorder;
  final Color selectedBackground;
  final Color selectedBorder;
  final Color selectedForeground;
  final Color dangerBackground;
  final Color dangerBorder;
  final Color divider;
  final Color pressedOverlay;

  const AppUiTokens({
    required this.cardBackground,
    required this.cardBorder,
    required this.selectedBackground,
    required this.selectedBorder,
    required this.selectedForeground,
    required this.dangerBackground,
    required this.dangerBorder,
    required this.divider,
    required this.pressedOverlay,
  });

  factory AppUiTokens.fromColorScheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return AppUiTokens(
      // Translucent glass cards let the Aurora gradient show through
      cardBackground: colorScheme.surfaceContainerHigh
          .withValues(alpha: isDark ? 0.55 : 0.65),
      cardBorder: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.45),
      selectedBackground: colorScheme.secondaryContainer
          .withValues(alpha: isDark ? 0.65 : 0.75),
      selectedBorder: colorScheme.secondary.withValues(alpha: isDark ? 0.7 : 0.8),
      selectedForeground: colorScheme.onSecondaryContainer,
      dangerBackground: colorScheme.errorContainer.withValues(alpha: isDark ? 0.45 : 0.35),
      dangerBorder: colorScheme.error.withValues(alpha: isDark ? 0.75 : 0.6),
      divider: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.6),
      pressedOverlay: colorScheme.primary.withValues(alpha: 0.08),
    );
  }

  @override
  AppUiTokens copyWith({
    Color? cardBackground,
    Color? cardBorder,
    Color? selectedBackground,
    Color? selectedBorder,
    Color? selectedForeground,
    Color? dangerBackground,
    Color? dangerBorder,
    Color? divider,
    Color? pressedOverlay,
  }) {
    return AppUiTokens(
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      selectedBackground: selectedBackground ?? this.selectedBackground,
      selectedBorder: selectedBorder ?? this.selectedBorder,
      selectedForeground: selectedForeground ?? this.selectedForeground,
      dangerBackground: dangerBackground ?? this.dangerBackground,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      divider: divider ?? this.divider,
      pressedOverlay: pressedOverlay ?? this.pressedOverlay,
    );
  }

  @override
  AppUiTokens lerp(ThemeExtension<AppUiTokens>? other, double t) {
    if (other is! AppUiTokens) {
      return this;
    }
    return AppUiTokens(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      selectedBackground: Color.lerp(selectedBackground, other.selectedBackground, t)!,
      selectedBorder: Color.lerp(selectedBorder, other.selectedBorder, t)!,
      selectedForeground: Color.lerp(selectedForeground, other.selectedForeground, t)!,
      dangerBackground: Color.lerp(dangerBackground, other.dangerBackground, t)!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      pressedOverlay: Color.lerp(pressedOverlay, other.pressedOverlay, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppUiTokens get uiTokens {
    final theme = Theme.of(this);
    return theme.extension<AppUiTokens>() ??
        AppUiTokens.fromColorScheme(theme.colorScheme);
  }
}

/// Custom color accessor wrapping ColorScheme.
class CustomColors {
  /// 主要颜色，用于关键UI元素
  final Color primary;
  
  /// 主要颜色上的文字颜色
  final Color onPrimary;
  
  /// 主要容器颜色，用于背景
  final Color primaryContainer;
  
  /// 主要容器上的文字颜色
  final Color onPrimaryContainer;
  
  /// 次要颜色，用于辅助UI元素
  final Color secondary;
  
  /// 次要颜色上的文字颜色
  final Color onSecondary;
  
  /// 次要容器颜色，用于背景
  final Color secondaryContainer;
  
  /// 次要容器上的文字颜色
  final Color onSecondaryContainer;
  
  /// 第三颜色，用于强调UI元素
  final Color tertiary;
  
  /// 第三颜色上的文字颜色
  final Color onTertiary;
  
  /// 第三容器颜色，用于背景
  final Color tertiaryContainer;
  
  /// 第三容器上的文字颜色
  final Color onTertiaryContainer;
  
  /// 错误颜色，用于错误提示
  final Color error;
  
  /// 错误颜色上的文字颜色
  final Color onError;
  
  /// 错误容器颜色，用于错误提示背景
  final Color errorContainer;
  
  /// 错误容器上的文字颜色
  final Color onErrorContainer;
  
  /// 表面颜色，用于卡片和背景
  final Color surface;
  
  /// 表面上的文字颜色
  final Color onSurface;
  
  /// 最高级表面容器颜色，用于需要突出的背景
  final Color surfaceContainerHighest;
  
  /// 表面变体上的文字颜色
  final Color onSurfaceVariant;
  
  /// 轮廓颜色，用于边框和分隔线
  final Color outline;
  
  /// 轮廓变体颜色，用于次要边框
  final Color outlineVariant;

  /// 创建自定义颜色实例
  /// 
  /// [seedColor] 种子颜色
  /// [primary] 主要颜色
  /// [onPrimary] 主要颜色上的文字颜色
  /// [primaryContainer] 主要容器颜色
  /// [onPrimaryContainer] 主要容器上的文字颜色
  /// [secondary] 次要颜色
  /// [onSecondary] 次要颜色上的文字颜色
  /// [secondaryContainer] 次要容器颜色
  /// [onSecondaryContainer] 次要容器上的文字颜色
  /// [tertiary] 第三颜色
  /// [onTertiary] 第三颜色上的文字颜色
  /// [tertiaryContainer] 第三容器颜色
  /// [onTertiaryContainer] 第三容器上的文字颜色
  /// [error] 错误颜色
  /// [onError] 错误颜色上的文字颜色
  /// [errorContainer] 错误容器颜色
  /// [onErrorContainer] 错误容器上的文字颜色
  /// [surface] 表面颜色
  /// [onSurface] 表面上的文字颜色
  /// [surfaceContainerHighest] 最高级表面容器颜色
  /// [onSurfaceVariant] 表面变体上的文字颜色
  /// [outline] 轮廓颜色
  /// [outlineVariant] 轮廓变体颜色
  const CustomColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainerHighest,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
  });

  /// 从ColorScheme创建CustomColors实例
  factory CustomColors.fromColorScheme(ColorScheme scheme) {
    return CustomColors(
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      primaryContainer: scheme.primaryContainer,
      onPrimaryContainer: scheme.onPrimaryContainer,
      secondary: scheme.secondary,
      onSecondary: scheme.onSecondary,
      secondaryContainer: scheme.secondaryContainer,
      onSecondaryContainer: scheme.onSecondaryContainer,
      tertiary: scheme.tertiary,
      onTertiary: scheme.onTertiary,
      tertiaryContainer: scheme.tertiaryContainer,
      onTertiaryContainer: scheme.onTertiaryContainer,
      error: scheme.error,
      onError: scheme.onError,
      errorContainer: scheme.errorContainer,
      onErrorContainer: scheme.onErrorContainer,
      surface: scheme.surface,
      onSurface: scheme.onSurface,
      surfaceContainerHighest: scheme.surfaceContainerHighest,
      onSurfaceVariant: scheme.onSurfaceVariant,
      outline: scheme.outline,
      outlineVariant: scheme.outlineVariant,
    );
  }
}

/// 应用主题类，提供主题相关的工具方法和预设颜色
class AppTheme {
  /// 预设的种子颜色列表，用于用户选择主题颜色
  static const List<Color> presetSeedColors = [
    Color(0xFF6750A4), // 紫色
    Color(0xFF0061A4), // 蓝色
    Color(0xFF006E1C), // 绿色
    Color(0xFFBA1A1A), // 红色
    Color(0xFF984061), // 粉色
    Color(0xFF7C5800), // 橙色
    Color(0xFF006A6A), // 青色
    Color(0xFF4758A9), // 靛蓝色
    Color(0xFF7D5260), // 棕色
    Color(0xFF006494), // 深蓝色
  ];

  /// 创建 Aurora UI 主题 — 玻璃质感、半透明、无阴影
  static ThemeData createTheme({
    required ColorScheme colorScheme,
    String? fontFamily,
    bool isAmoledBlack = false,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final glassBg = colorScheme.surfaceContainerHigh
        .withValues(alpha: isDark ? 0.55 : 0.65);
    final glassBorder = colorScheme.outlineVariant
        .withValues(alpha: isDark ? 0.30 : 0.40);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      fontFamily: fontFamily,
      extensions: <ThemeExtension<dynamic>>[
        AppUiTokens.fromColorScheme(colorScheme),
      ],
      // Transparent scaffold lets Aurora gradient show through
      scaffoldBackgroundColor: Colors.transparent,

      // AppBar — translucent glass
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Cards — glass panels, zero elevation
      cardTheme: CardThemeData(
        color: glassBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: glassBorder, width: 1),
        ),
      ),

      // FAB — glass
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer
            .withValues(alpha: isDark ? 0.7 : 0.8),
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // NavigationBar — Aurora glass, no Material 3 pill indicator
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface
            .withValues(alpha: isDark ? 0.50 : 0.65),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: Colors.transparent,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              fontFamily: fontFamily,
            );
          }
          return TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
            fontSize: 11,
            fontFamily: fontFamily,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.primary,
              size: 22,
            );
          }
          return IconThemeData(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 22,
          );
        }),
      ),

      // Chips — translucent
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.6),
        selectedColor: colorScheme.secondaryContainer
            .withValues(alpha: 0.7),
        labelStyle: TextStyle(color: colorScheme.onSurface, fontFamily: fontFamily),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Input fields — glass fill
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest
            .withValues(alpha: isDark ? 0.4 : 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // ElevatedButton — glass with primary tint
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary
              .withValues(alpha: isDark ? 0.8 : 0.9),
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // FilledButton — Aurora glass (not Material filled)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary
              .withValues(alpha: isDark ? 0.7 : 0.75),
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),


      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // OutlinedButton — glass border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      // BottomSheet — glass top surface
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface
            .withValues(alpha: isDark ? 0.85 : 0.90),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // Dialog — glass panel
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh
            .withValues(alpha: isDark ? 0.85 : 0.90),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),

      // SnackBar — glass floating
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface
            .withValues(alpha: 0.85),
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface, fontFamily: fontFamily),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: colorScheme.secondaryContainer
            .withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
      ),

      // ProgressIndicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
