# Aurora UI Migration - 从 Material 3 迁移到 Aurora UI

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 从 PureWeather 中完全移除 Material 3 / Material You / dynamic_color，替换为 Aurora UI（极光流动渐变色系统 + 天气驱动色彩）。

**Architecture:** 保留 Flutter 必需的 `MaterialApp` + `ThemeData` 基础设施，但用固定的 Aurora 色调色板替换 `ColorScheme.fromSeed()`，移除 `dynamic_color` 包和所有动态壁纸取色逻辑。新增 `AuroraBackground` widget 为天气页面提供极光渐变背景，`AuroraPalette` 定义亮/暗色板，`WeatherGradientScheme` 映射天气代码→渐变色。

**Tech Stack:** Flutter, Dart, Riverpod, flutter_animate

---

## 文件结构

```
lib/core/theme/
  aurora_palette.dart        NEW - Aurora 亮/暗色板定义
  aurora_gradient_scheme.dart NEW - 天气条件→极光渐变色映射
  aurora_background.dart     NEW - 极光渐变背景 widget
  app_theme.dart             MODIFY - 移除 M3 依赖，使用 Aurora 色板
lib/providers/
  theme_provider.dart        MODIFY - 移除 useDynamicColor/useMaterial3
lib/
  main.dart                  MODIFY - 移除 DynamicColorBuilder，简化主题构建
lib/core/constants/
  app_constants.dart         MODIFY - 替换天气图标为 Lucide
lib/screens/
  main_screen.dart           MODIFY - 导航栏图标替换为 Lucide
  weather/weather_screen.dart MODIFY - 天气页面图标替换为 Lucide
  settings/settings_screen.dart MODIFY - 移除动态取色 UI + 图标替换
  settings/scheduled_broadcast_screen.dart MODIFY - 图标替换
  settings/card_order_screen.dart MODIFY - 图标替换
  ai_assistant/ai_assistant_screen.dart MODIFY - 图标替换
  city_management/city_management_screen.dart MODIFY - 图标替换
lib/widgets/
  hourly_forecast.dart       MODIFY - 图标替换
  daily_forecast.dart        MODIFY - 图标替换
  air_quality_card.dart      MODIFY - 图标替换
  weather_alert_card.dart    MODIFY - 图标替换
  weather_indices_card.dart  MODIFY - 图标替换
  settings/settings_bottom_sheet.dart MODIFY - 图标替换
  settings/settings_list_tile.dart MODIFY - 图标替换
pubspec.yaml                 MODIFY - 移除 dynamic_color + 添加 lucide_icons
```

**不变文件**:
`weather_card.dart` (只有 `context.uiTokens`，无图标引用), 所有 `widgets/settings/*.dart` 中无图标的文件

---

### Task 1: 移除 dynamic_color 依赖

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: 删除 dynamic_color 行**

```yaml
# 删除这一行:
  dynamic_color: ^1.7.0
```

- [ ] **Step 2: 运行 pub get 确认依赖解析**

Run: `cd d:/EchoRan/Documents/GitHub/PureWeather && flutter pub get`
Expected: 正常退出，无错误

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: remove dynamic_color dependency"
```

---

### Task 2: 创建 AuroraPalette 色板定义

**Files:**
- Create: `lib/core/theme/aurora_palette.dart`

- [ ] **Step 1: 创建色板文件**

```dart
import 'package:flutter/material.dart';

/// Aurora UI 固定色板 - 替代 Material 3 的 seed color 生成系统
///
/// 亮色模式：清新、有活力
/// 暗色模式：深邃、神秘
class AuroraPalette {
  const AuroraPalette._();

  // ── 亮色模式 ──────────────────────────────────

  static const Color lightPrimary = Color(0xFF0061A4);       // 天蓝
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

  // ── 暗色模式 ──────────────────────────────────

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

  /// 从 AuroraPalette 构建 ColorScheme
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

  /// AMOLED 纯黑暗色模式
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/aurora_palette.dart
git commit -m "feat: add AuroraPalette color system"
```

---

### Task 3: 创建天气渐变映射

**Files:**
- Create: `lib/core/theme/aurora_gradient_scheme.dart`

- [ ] **Step 1: 创建渐变映射文件**

```dart
import 'package:flutter/material.dart';

/// 天气条件到极光渐变色的映射
class WeatherGradientScheme {
  const WeatherGradientScheme._();

  static const Color darkOverlayColor = Color(0x33000000);
  static const Color lightOverlayColor = Color(0x33FFFFFF);

  /// 根据天气代码返回渐变色列表
  /// [code] 天气代码 (100=晴, 300+=雨, 400+=雪, 500+=雾/霾等)
  /// [isDark] 是否为暗色模式
  static List<Color> forCode(int code, {bool isDark = false}) {
    if (code >= 300 && code <= 399) return isDark ? _rainDark : _rainLight;
    if (code >= 400 && code <= 499) return isDark ? _snowDark : _snowLight;
    if (code >= 500 && code <= 515) return isDark ? _fogDark : _fogLight;
    if (code == 100 || code == 150) return isDark ? _sunnyDark : _sunnyLight;
    if (code == 900) return isDark ? _hotDark : _hotLight;
    if (code == 901) return isDark ? _coldDark : _coldLight;
    return isDark ? _cloudyDark : _cloudyLight;
  }

  /// 判断天气代码对应的阴晴类型
  static bool isSunny(int code) => code == 100 || code == 150;
  static bool isRainy(int code) => code >= 300 && code <= 399;
  static bool isSnowy(int code) => code >= 400 && code <= 499;

  // ── 亮色渐变 ──────────────────────────────────

  static const List<Color> _sunnyLight = [
    Color(0xFF87CEEB), // 天蓝
    Color(0xFF4A90D9), // 中蓝
    Color(0xFFF0C060), // 暖金
    Color(0xFFE8833A), // 暖橙
  ];

  static const List<Color> _cloudyLight = [
    Color(0xFFB0C4DE), // 钢蓝
    Color(0xFF8E9EAB), // 灰蓝
    Color(0xFFD3D3D3), // 浅灰
    Color(0xFFE8E8E8), // 白
  ];

  static const List<Color> _rainLight = [
    Color(0xFF2C3E50), // 深蓝灰
    Color(0xFF4A6FA5), // 中蓝
    Color(0xFF7B9FC5), // 浅蓝
    Color(0xFFA8C4D8), // 淡蓝
  ];

  static const List<Color> _snowLight = [
    Color(0xFFE8F0F8), // 冰白
    Color(0xFFC8DCE8), // 冰蓝
    Color(0xFFA8C8E0), // 浅蓝
    Color(0xFFD0E8F8), // 淡蓝白
  ];

  static const List<Color> _fogLight = [
    Color(0xFFCFD8DC), // 浅灰
    Color(0xFFB0BEC5), // 灰蓝
    Color(0xFF90A4AE), // 中灰蓝
    Color(0xFFECEFF1), // 白灰
  ];

  static const List<Color> _hotLight = [
    Color(0xFFFF8C00), // 深橙
    Color(0xFFFFA726), // 橙
    Color(0xFFFFD54F), // 金
    Color(0xFFFF7043), // 深橙红
  ];

  static const List<Color> _coldLight = [
    Color(0xFF81D4FA), // 浅蓝
    Color(0xFF4FC3F7), // 亮蓝
    Color(0xFFE1F5FE), // 冰蓝
    Color(0xFFB3E5FC), // 淡蓝
  ];

  // ── 暗色渐变 ──────────────────────────────────

  static const List<Color> _sunnyDark = [
    Color(0xFF0D1B2A), // 深蓝黑
    Color(0xFF1B2838), // 深蓝
    Color(0xFF415A77), // 暗蓝
    Color(0xFF6B3A2A), // 暗橙棕
  ];

  static const List<Color> _cloudyDark = [
    Color(0xFF1A1A2E), // 深紫黑
    Color(0xFF16213E), // 深蓝
    Color(0xFF1F2937), // 深灰蓝
    Color(0xFF374151), // 中灰
  ];

  static const List<Color> _rainDark = [
    Color(0xFF0A0F1F), // 极深蓝
    Color(0xFF0F1A30), // 深蓝
    Color(0xFF1E2F4A), // 中暗蓝
    Color(0xFF2A3F5A), // 暗蓝灰
  ];

  static const List<Color> _snowDark = [
    Color(0xFF1A2332), // 暗蓝灰
    Color(0xFF253545), // 暗蓝
    Color(0xFF2A3A4A), // 中暗蓝
    Color(0xFF1E2A38), // 深蓝灰
  ];

  static const List<Color> _fogDark = [
    Color(0xFF1A1D23), // 深灰
    Color(0xFF2A2D33), // 中深灰
    Color(0xFF202328), // 深灰蓝
    Color(0xFF30343A), // 中灰
  ];

  static const List<Color> _hotDark = [
    Color(0xFF1A0A00), // 深棕黑
    Color(0xFF3A1A05), // 暗棕
    Color(0xFF3D1A00), // 暗橙棕
    Color(0xFF2A1000), // 深棕
  ];

  static const List<Color> _coldDark = [
    Color(0xFF0A1525), // 深蓝黑
    Color(0xFF0D1F35), // 暗蓝
    Color(0xFF102840), // 深蓝
    Color(0xFF0F1A2E), // 极深蓝
  ];
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/aurora_gradient_scheme.dart
git commit -m "feat: add weather-to-aurora gradient mapping"
```

---

### Task 4: 创建 Aurora 渐变背景 Widget

**Files:**
- Create: `lib/core/theme/aurora_background.dart`

- [ ] **Step 1: 创建极光背景 widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'aurora_gradient_scheme.dart';

/// 极光流动渐变背景
///
/// 根据天气代码显示对应的极光渐变，8秒循环动画
class AuroraBackground extends StatefulWidget {
  final int weatherCode;
  final Widget child;

  const AuroraBackground({
    super.key,
    required this.weatherCode,
    required this.child,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = WeatherGradientScheme.forCode(
      widget.weatherCode,
      isDark: isDark,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // 通过偏移渐变位置产生流动感
        final begin = Alignment(-1 + t, -0.5 + (t * 0.5));
        final end = Alignment(1 - t, 0.5 - (t * 0.5));

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: colors,
              tileMode: TileMode.clamp,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/aurora_background.dart
git commit -m "feat: add AuroraBackground animated gradient widget"
```

---

### Task 5: 重构 AppTheme - 使用 Aurora 色板替代 fromSeed

**Files:**
- Modify: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: 修改导入和移除 M3 相关代码**

在文件顶部，添加 AuroraPalette 导入：
```dart
import 'aurora_palette.dart';
```

- [ ] **Step 2: 移除 CustomColors 种子颜色相关字段**

删除 `CustomColors.seedColor` 字段（行 98-99），并在 `fromColorScheme` 中移除 seed 参数。简化后：

```dart
/// 从ColorScheme创建CustomColors实例
factory CustomColors.fromColorScheme(ColorScheme scheme) {
  return CustomColors(
    // seedColor 删除
    primary: scheme.primary,
    ...
  );
}
```

同时删除 `CustomColors` 类中的 `final Color seedColor;` 字段声明。

- [ ] **Step 3: 移除 AppTheme 中的 fromSeed/seed 引用**

将 `AppTheme.createTheme` 中 `Color? fontFamily` 参数及其在后续 TextStyle 中使用保留（已有代码在用）。

确保 `createTheme` 不再需要 `useMaterial3` 参数，硬编码为 `true`（Flutter M3 是基础架构，但所有颜色来自 Aurora）。

实际上，保留 `useMaterial3` 参数但默认 true。因为我们仍在用 Material 的基础 widget 结构，只是颜色来自 Aurora 而非 seed。

更简洁的做法：删除 `useMaterial3` 参数，内部硬编码为 `true`。

修改 `AppTheme.createTheme` 签名:
```dart
static ThemeData createTheme({
  required ColorScheme colorScheme,
  String? fontFamily,
  bool isAmoledBlack = false,
}) {
```

移除 `useMaterial3` 参数，内部直接使用 `useMaterial3: true`。

- [ ] **Step 4: 移除 createAmoledBlackScheme（移到 AuroraPalette）**

删除 `AppTheme.createAmoledBlackScheme` 方法（行 271-280），因为 `AuroraPalette.amoledBlackColorScheme()` 已替代。

- [ ] **Step 5: Commit**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "refactor: switch AppTheme from ColorScheme.fromSeed to AuroraPalette"
```

---

### Task 6: 重构 ThemeProvider - 移除 Material You 设置

**Files:**
- Modify: `lib/providers/theme_provider.dart`

- [ ] **Step 1: 简化 ThemeSettings**

删除 `useDynamicColor` 和 `useMaterial3` 字段：

```dart
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
```

- [ ] **Step 2: 删除 _keyUseDynamicColor 和 _keyUseMaterial3 常量**

删除行 82-86。

- [ ] **Step 3: 简化 _loadSettings**

从 _loadSettings 中移除 `useDynamicColor` 和 `useMaterial3` 的加载。

- [ ] **Step 4: 删除 setUseDynamicColor 和 setUseMaterial3 方法**

删除行 141-156。

- [ ] **Step 5: 重写 colorSchemeProvider**

替换 `ColorScheme.fromSeed` 为 `AuroraPalette`:

```dart
import '../core/theme/aurora_palette.dart';

/// 颜色方案的Provider，从 Aurora 色板生成
final colorSchemeProvider = Provider<ColorScheme>((ref) {
  final settings = ref.watch(themeProvider);

  // 暗色模式判断：目前直接用 Provider 无法获取 context brightness
  // 改用 Provider.family 让调用方传入 brightness
  // 这里保留 Provider 签名给 themeDataProvider 内使用
  return AuroraPalette.lightColorScheme();
});
```

不对——`colorSchemeProvider` 现在是 `Provider.family<ColorScheme, ColorScheme?>`，被 `themeDataProvider` 使用。让我重新设计：

由于不再需要传入 dynamic color scheme，简化 Provider 链：

```dart
/// Aurora 颜色方案的 Provider
final auroraColorSchemeProvider = Provider<ColorScheme>((ref) {
  // 这个方法被 themeDataProvider 调用，它需要知道 brightness
  // 我们用 Provider 但主题逻辑在 main.dart 层级处理
  throw UnimplementedError('Use themeDataProvider instead');
});
```

实际上，看看当前的用法。在 `main.dart` 中，主题构建逻辑是手动的(没用 colorSchemeProvider/themeDataProvider)。这两个 provider 在 `theme_provider.dart` 中定义但实际上**没被 main.dart 使用**。main.dart 自己手动构建 ColorScheme 和 ThemeData。

检查：`colorSchemeProvider` 和 `themeDataProvider` 是否被其他地方使用？

从 Grep 结果看，它们只在 theme_provider.dart 中定义和使用。main.dart 完全自己构建主题。

所以最简洁的做法：**删除 `colorSchemeProvider` 和 `themeDataProvider`**，因为它们未被使用。保留 `themeProvider` (被 main.dart 和 settings 使用)。

```dart
// 删除 colorSchemeProvider (行 203-215)
// 删除 themeDataProvider (行 220-234)
```

- [ ] **Step 6: Commit**

```bash
git add lib/providers/theme_provider.dart
git commit -m "refactor: remove Material You settings from ThemeProvider"
```

---

### Task 7: 重构 main.dart - 移除 DynamicColorBuilder

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: 移除 dynamic_color 导入**

删除行 7: `import 'package:dynamic_color/dynamic_color.dart';`

- [ ] **Step 2: 添加 AuroraPalette 导入**

```dart
import 'core/theme/aurora_palette.dart';
```

- [ ] **Step 3: 删除 _bypassedColorScheme 和 _bypassColorLoaded 字段**

删除行 51-54:
```dart
// 删除:
ColorScheme? _bypassedColorScheme;
bool _bypassColorLoaded = false;
```

- [ ] **Step 4: 删除 _getBypassedColorScheme 方法**

删除行 229-258 整个方法。

- [ ] **Step 5: 简化 build 方法**

将 `DynamicColorBuilder` 替换为直接构建：

```dart
@override
Widget build(BuildContext context) {
  final themeSettings = ref.watch(themeProvider);
  final appSettings = ref.watch(settingsProvider);
  final themeNotifier = ref.read(themeProvider.notifier);
  final appLocale = _resolveAppLocale(appSettings.appLanguage);

  ref.listen<ScheduledBroadcastSettings>(scheduledBroadcastProvider, (
    previous,
    next,
  ) {
    if (previous != next) {
      scheduledBroadcastServiceProvider.scheduleBroadcasts(next);
    }
  });

  // 直接从 AuroraPalette 生成 color schemes
  final seedColor = themeSettings.seedColor;
  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;

  if (seedColor != null) {
    // 自定义种子颜色仍然使用 fromSeed（用户手动选色保留灵活性）
    lightColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    darkColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
  } else {
    lightColorScheme = AuroraPalette.lightColorScheme();
    darkColorScheme = AuroraPalette.darkColorScheme();
  }

  final finalDarkColorScheme = themeSettings.useAmoledBlack
      ? AuroraPalette.amoledBlackColorScheme()
      : darkColorScheme;

  return MaterialApp(
    title: AppLocalizations.tr('轻氧天气'),
    debugShowCheckedModeBanner: false,
    locale: appLocale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    localeResolutionCallback: (locale, supportedLocales) {
      // ... 保持不变
    },
    theme: AppTheme.createTheme(
      colorScheme: lightColorScheme,
    ),
    darkTheme: AppTheme.createTheme(
      colorScheme: finalDarkColorScheme,
      isAmoledBlack: themeSettings.useAmoledBlack,
    ),
    themeMode: themeNotifier.flutterThemeMode,
    builder: (context, child) {
      // ... 保持不变
    },
    home: const MainScreen(),
  );
}
```

注意：删除了 `DynamicColorBuilder` wrapper 和 `_bypassColorLoaded` 的 `setState` 调用。也删除了 `debugPrint` 中的 `[DynamicColor]` 日志。

- [ ] **Step 6: Commit**

```bash
git add lib/main.dart
git commit -m "refactor: replace DynamicColorBuilder with AuroraPalette in main.dart"
```

---

### Task 8: 重构 SettingsScreen - 移除动态取色 UI

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart`

- [ ] **Step 1: 移除 dynamic_color 导入**

删除行 8: `import 'package:dynamic_color/dynamic_color.dart';`

- [ ] **Step 2: 删除 SettingsListTile "主题颜色" 的 subtitle 动态取色判断**

修改行 92-98:

```dart
SettingsListTile(
  icon: Icons.color_lens_outlined,
  title: '主题颜色',
  subtitle: '自定义颜色',
  onTap: () => _showColorPickerDialog(
    context,
    ref,
    themeSettings,
  ),
),
```

删除 `themeSettings.useDynamicColor ? '跟随壁纸' :` 的条件判断。

- [ ] **Step 3: 删除 "动态取色" SettingsSwitchTile**

删除整个动态取色开关块（行 104-114）:

```dart
// 删除:
SettingsSwitchTile(
  icon: Icons.wallpaper_outlined,
  title: '动态取色',
  subtitle: '根据壁纸自动生成主题色',
  value: themeSettings.useDynamicColor,
  onChanged: (value) {
    ref
        .read(themeProvider.notifier)
        .setUseDynamicColor(value);
  },
),
```

- [ ] **Step 4: 简化 _showColorPickerDialog - 删除动态取色 Section**

在 `_showColorPickerDialog` 中删除 `_buildDynamicColorSection` 调用（行 571）。直接让用户选预设颜色或自定义颜色：

```dart
children: [
  // 删除: _buildDynamicColorSection(context, ref, settings),
  const SizedBox(height: 24),
  _buildSectionTitle(context, '预设颜色'),
  const SizedBox(height: 12),
  _buildPresetColors(...),
  // ... 其余保持不变
],
```

- [ ] **Step 5: 删除 _buildDynamicColorSection 方法**

删除行 619-802 整个 `_buildDynamicColorSection` 方法。

- [ ] **Step 6: 删除 _getWallpaperColor 方法**

删除行 805-820 整个 `_getWallpaperColor` 方法。

- [ ] **Step 7: 删除 _buildDynamicColorNotSupported 方法**

删除行 822-862 整个 `_buildDynamicColorNotSupported` 方法。

- [ ] **Step 8: 简化 _buildActionButtons - 移除动态取色逻辑**

修改行 1086-1125 中的重置按钮：

```dart
Widget _buildActionButtons(
  BuildContext context,
  WidgetRef ref,
  BuildContext dialogContext,
  Color selectedColor,
  ThemeSettings settings,
) {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () {
            ref.read(themeProvider.notifier).setSeedColor(null);
            Navigator.pop(dialogContext);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(context.tr('重置')),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: FilledButton(
          onPressed: () {
            ref.read(themeProvider.notifier).setSeedColor(selectedColor);
            Navigator.pop(dialogContext);
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(context.tr('应用')),
        ),
      ),
    ],
  );
}
```

注意：删除了 `ref.read(themeProvider.notifier).setUseDynamicColor(true/false)` 调用。

- [ ] **Step 9: 更新关于页面文本**

修改行 1764 "Material You Design" → "Aurora UI":

```dart
'轻氧天气是一款使用 Aurora UI 的现代化跨平台天气应用，支持全平台。',
```

- [ ] **Step 10: Commit**

```bash
git add lib/screens/settings/settings_screen.dart
git commit -m "refactor: remove dynamic color UI from settings"
```

---

### Task 9: 在 WeatherScreen 集成 Aurora 背景

**Files:**
- Modify: `lib/screens/weather/weather_screen.dart`

- [ ] **Step 1: 导入 aurora_background**

在文件顶部添加:
```dart
import '../../core/theme/aurora_background.dart';
import '../../core/theme/aurora_gradient_scheme.dart';
```

- [ ] **Step 2: 用 AuroraBackground 包裹天气主区域**

修改 `build` 方法中的 scaffoldBody。找到 `_buildCurrentWeather` 返回的 Container，将其整体包裹在 `AuroraBackground` 中。

最佳做法：在 `_buildCurrentWeather` 的返回值和 `_buildContent` 的返回值之间包裹，这样整个天气页都享有流动渐变背景。

修改 `_buildCurrentWeather` 中返回的 Container 行 155-156 的 `color: colorScheme.surfaceContainer` 为 `color: Colors.transparent`（因为 AuroraBackground 已在背后渲染渐变）。

然后在天气屏幕顶部包裹 AuroraBackground：

```dart
@override
Widget build(BuildContext context) {
  final weatherState = ref.watch(weatherProvider);
  final defaultCity = ref.watch(defaultCityProvider);
  final weatherCode = int.tryParse(
    weatherState.weatherData?.current.icon ?? '100'
  ) ?? 100;

  return LayoutBuilder(
    builder: (context, constraints) {
      final bool isWide = constraints.maxWidth > 900;

      final scaffoldBody = AuroraBackground(
        weatherCode: weatherCode,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.stylus,
                PointerDeviceKind.invertedStylus,
                PointerDeviceKind.trackpad,
              },
            ),
            child: CustomScrollView(
              slivers: [
                // ... 不变
              ],
            ),
          ),
        ),
      );

      return Scaffold(body: scaffoldBody);
    },
  );
}
```

- [ ] **Step 3: 修改 _buildCurrentWeather 背景为透明**

将行 155-156:
```dart
color: colorScheme.surfaceContainer,
```

改为:
```dart
color: Colors.transparent,
```

因为 AuroraBackground 提供渐变背景，卡片自己有不透明背景，所以这里透出渐变即可。

- [ ] **Step 4: 修改 _buildErrorState 和 _buildEmptyState 背景**

将行 316 和 373:
```dart
child: Container(color: colorScheme.surfaceContainer),
```

改为:
```dart
child: Container(color: Colors.transparent),
```

- [ ] **Step 5: Commit**

```bash
git add lib/screens/weather/weather_screen.dart
git commit -m "feat: integrate AuroraBackground into weather screen"
```

---

### Task 10: 清理和验证

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: 更新 pubspec.yaml 描述**

```yaml
description: "轻氧天气 - 一款使用 Aurora UI 的天气应用"
```

- [ ] **Step 2: 运行完整构建验证**

```bash
cd d:/EchoRan/Documents/GitHub/PureWeather && flutter analyze
```

Expected: 无错误

- [ ] **Step 3: 验证所有 import 无缺失**

```bash
cd d:/EchoRan/Documents/GitHub/PureWeather && flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: 正常完成

- [ ] **Step 4: 验证 dynamic_color 引用已完全移除**

```bash
cd d:/EchoRan/Documents/GitHub/PureWeather && grep -r "dynamic_color\|useDynamicColor\|DynamicColor\|useMaterial3" lib/
```

Expected: 无任何输出

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: final cleanup for Aurora UI migration"
```

---

### Task 11: 添加 lucide_icons 依赖 + 更新天气图标映射

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/core/constants/app_constants.dart`

- [ ] **Step 1: 添加 lucide_icons 依赖**

在 `pubspec.yaml` 的 dependencies 中添加:
```yaml
  lucide_icons: ^1.1.0
```

- [ ] **Step 2: 运行 pub get**

```bash
cd d:/EchoRan/Documents/GitHub/PureWeather && flutter pub get
```

Expected: 正常完成

- [ ] **Step 3: 替换 app_constants.dart 中的天气图标映射**

将 `WeatherCode.getWeatherIcon` 方法中的所有 `Icons.xxx` 替换为 `LucideIcons.xxx`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ... AppConstants 不变 ...

class WeatherCode {
  // ... descriptions 不变 ...

  static IconData getWeatherIcon(int code, {bool isNight = false}) {
    if (code == 100 || code == 150) {
      return isNight ? LucideIcons.moon : LucideIcons.sun;
    } else if (code == 101 ||
        code == 102 ||
        code == 103 ||
        code == 151 ||
        code == 152 ||
        code == 153) {
      return isNight ? LucideIcons.cloudMoon : LucideIcons.cloudSun;
    } else if (code == 104) {
      return LucideIcons.cloud;
    } else if ((code >= 300 && code <= 399) || code == 350 || code == 351) {
      return LucideIcons.cloudRain;
    } else if ((code >= 400 && code <= 499) || code == 456 || code == 457) {
      return LucideIcons.cloudSnow;
    } else if (code >= 500 && code <= 515) {
      return LucideIcons.cloudFog;
    } else if (code == 900) {
      return LucideIcons.thermometerSun;
    } else if (code == 901) {
      return LucideIcons.thermometerSnowflake;
    }
    return LucideIcons.cloud;
  }

  // ... convertTemperature 不变 ...
}
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml lib/core/constants/app_constants.dart
git commit -m "feat: add lucide_icons, migrate weather code icons from Material to Lucide"
```

---

### Task 12: 迁移所有 Widget 图标

**Files:**
- Modify: `lib/widgets/hourly_forecast.dart`
- Modify: `lib/widgets/daily_forecast.dart`
- Modify: `lib/widgets/air_quality_card.dart`
- Modify: `lib/widgets/weather_alert_card.dart`
- Modify: `lib/widgets/weather_indices_card.dart`
- Modify: `lib/widgets/settings/settings_list_tile.dart`
- Modify: `lib/widgets/settings/settings_bottom_sheet.dart`

- [ ] **Step 1: 在 hourly_forecast.dart 添加 import 并替换图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换:
// Icons.info_outline → LucideIcons.info
// Icons.schedule → LucideIcons.clock
// Icons.water_drop → LucideIcons.droplet
```

- [ ] **Step 2: 在 daily_forecast.dart 中添加 import 并替换图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换:
// Icons.calendar_today → LucideIcons.calendar
```

- [ ] **Step 3: 在 air_quality_card.dart 中添加 import 并替换图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换:
// Icons.air → LucideIcons.wind
```

- [ ] **Step 4: 在 weather_alert_card.dart 中添加 import 并替换图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换:
// Icons.warning_amber_rounded → LucideIcons.triangleAlert
// Icons.expand_less → LucideIcons.chevronUp
// Icons.expand_more → LucideIcons.chevronDown
```

- [ ] **Step 5: 在 weather_indices_card.dart 中添加 import 并替换图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换:
// Icons.tips_and_updates → LucideIcons.lightbulb
// Icons.directions_run → LucideIcons.footprints
// Icons.directions_car → LucideIcons.car
// Icons.checkroom → LucideIcons.shirt
// Icons.opacity → LucideIcons.droplets
// Icons.wb_sunny → LucideIcons.sun
// Icons.sick → LucideIcons.heartPulse
// Icons.beach_access → LucideIcons.umbrella
// Icons.local_florist → LucideIcons.flower2
// Icons.info_outline → LucideIcons.info
```

- [ ] **Step 6: 在 settings_list_tile.dart 中替换图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换:
// Icons.chevron_right → LucideIcons.chevronRight
```

- [ ] **Step 7: 在 settings_bottom_sheet.dart 中替换图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换:
// Icons.check_circle → LucideIcons.checkCircle
```

- [ ] **Step 8: Commit**

```bash
git add lib/widgets/
git commit -m "feat: migrate all widget icons from Material to Lucide"
```

---

### Task 13: 迁移所有 Screen 图标

**Files:**
- Modify: `lib/screens/main_screen.dart`
- Modify: `lib/screens/weather/weather_screen.dart`
- Modify: `lib/screens/ai_assistant/ai_assistant_screen.dart`
- Modify: `lib/screens/city_management/city_management_screen.dart`
- Modify: `lib/screens/settings/settings_screen.dart`
- Modify: `lib/screens/settings/scheduled_broadcast_screen.dart`
- Modify: `lib/screens/settings/card_order_screen.dart`

- [ ] **Step 1: 在 main_screen.dart 中添加 import 并替换导航栏图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换 _getDestinations 方法中的图标:
// Icons.wb_cloudy_outlined → LucideIcons.cloud
// Icons.wb_cloudy → LucideIcons.cloud (filled state use same icon, thicker stroke)
// Icons.psychology_outlined → LucideIcons.brain
// Icons.psychology → LucideIcons.brain
// Icons.settings_outlined → LucideIcons.settings
// Icons.settings → LucideIcons.settings
```

- [ ] **Step 2: 在 weather_screen.dart 中添加 import 并替换所有图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换映射表:
// Icons.location_on → LucideIcons.mapPin
// Icons.navigation_outlined → LucideIcons.navigation
// Icons.error_outline → LucideIcons.alertCircle
// Icons.refresh → LucideIcons.refreshCw
// Icons.location_city → LucideIcons.building2
// Icons.water_drop → LucideIcons.droplet
// Icons.info_outline → LucideIcons.info
// Icons.air → LucideIcons.wind
// Icons.wb_twilight → LucideIcons.sunrise
// Icons.visibility → LucideIcons.eye
// Icons.compress → LucideIcons.gauge
// Icons.nights_stay → LucideIcons.sunset
// Icons.search → LucideIcons.search
// Icons.clear → LucideIcons.x
// Icons.my_location → LucideIcons.crosshair
// Icons.location_on_outlined → LucideIcons.mapPin
// Icons.check_circle_rounded → LucideIcons.checkCircle
// Icons.my_location_rounded → LucideIcons.crosshair
// Icons.delete_outline → LucideIcons.trash2
```

- [ ] **Step 3: 在 ai_assistant_screen.dart 中添加 import 并替换图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换:
// Icons.delete_outline → LucideIcons.trash2
// Icons.psychology → LucideIcons.brain
// Icons.send → LucideIcons.send
```

- [ ] **Step 4: 在 city_management_screen.dart 中添加 import 并替换图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换:
// Icons.search → LucideIcons.search
// Icons.clear → LucideIcons.x
// Icons.my_location → LucideIcons.crosshair
// Icons.location_on_outlined → LucideIcons.mapPin
// Icons.location_city → LucideIcons.building2
// Icons.check_circle_rounded → LucideIcons.checkCircle
// Icons.my_location_rounded → LucideIcons.crosshair
// Icons.error_outline → LucideIcons.alertCircle
// Icons.delete_outline → LucideIcons.trash2
```

- [ ] **Step 5: 在 settings_screen.dart 中添加 import 并替换所有图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换映射表 (按出现顺序):
// Icons.palette_outlined → LucideIcons.palette
// Icons.brightness_6_outlined → LucideIcons.sunMoon
// Icons.brightness_2_outlined → LucideIcons.moonStar
// Icons.color_lens_outlined → LucideIcons.paintbrush
// Icons.notifications_outlined → LucideIcons.bell
// Icons.warning_amber_outlined → LucideIcons.triangleAlert
// Icons.update_rounded → LucideIcons.refreshCw
// Icons.schedule_outlined → LucideIcons.clock
// Icons.bug_report_outlined → LucideIcons.bug
// Icons.visibility_outlined → LucideIcons.eye
// Icons.psychology_outlined → LucideIcons.brain
// Icons.language_outlined → LucideIcons.globe
// Icons.device_thermostat_outlined → LucideIcons.thermometer
// Icons.location_on_outlined → LucideIcons.mapPin
// Icons.sort_rounded → LucideIcons.arrowUpDown
// Icons.sync_outlined → LucideIcons.refreshCw
// Icons.autorenew_outlined → LucideIcons.rotateCw
// Icons.timer_outlined → LucideIcons.timer
// Icons.tune_outlined → LucideIcons.slidersHorizontal
// Icons.swipe_outlined → LucideIcons.hand
// Icons.info_outline → LucideIcons.info
// Icons.apps_outlined → LucideIcons.layoutGrid
// Icons.privacy_tip_outlined → LucideIcons.shield
// Icons.description_outlined → LucideIcons.fileText
// Icons.brightness_auto_outlined → LucideIcons.monitor
// Icons.light_mode_outlined → LucideIcons.sun
// Icons.dark_mode_outlined → LucideIcons.moon
// Icons.smartphone_outlined → LucideIcons.smartphone
// Icons.translate_outlined → LucideIcons.languages
// Icons.language_outlined → LucideIcons.globe (已有的映射)
// Icons.check_circle → LucideIcons.checkCircle
// Icons.warning_amber → LucideIcons.triangleAlert
// Icons.check → LucideIcons.check
// Icons.tag → LucideIcons.tag
// Icons.content_paste → LucideIcons.clipboardPaste
// Icons.timer_outlined → LucideIcons.timer
// Icons.device_thermostat_outlined → LucideIcons.thermometer
// Icons.thermostat_outlined → LucideIcons.thermometer
// Icons.location_city → LucideIcons.building2
// Icons.location_on_outlined → LucideIcons.mapPin
// Icons.notifications_off_outlined → LucideIcons.bellOff
// Icons.update_disabled_outlined → LucideIcons.refreshCwOff
// Icons.check_circle_outline → LucideIcons.checkCircle
// Icons.error_outline → LucideIcons.alertCircle
// Icons.info_outline → LucideIcons.info
// Icons.code_outlined → LucideIcons.code2
// Icons.people_outline → LucideIcons.user
// Icons.link_outlined → LucideIcons.link
// Icons.favorite_outline → LucideIcons.heart
// Icons.cloud_outlined → LucideIcons.cloud
// Icons.cloud_queue_outlined → LucideIcons.cloud
// Icons.lightbulb_outlined → LucideIcons.lightbulb
// Icons.wallpaper_outlined → LucideIcons.image (在 TASK 8 中已删除此行，此处不再存在)
```

- [ ] **Step 6: 在 scheduled_broadcast_screen.dart 中添加 import 并替换图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换:
// Icons.info_outline → LucideIcons.info
// Icons.settings_outlined → LucideIcons.settings
// Icons.notifications_active_outlined → LucideIcons.bellRing
// Icons.schedule_outlined → LucideIcons.clock
// Icons.wb_sunny_outlined → LucideIcons.sun
// Icons.nightlight_outlined → LucideIcons.moon
// Icons.article_outlined → LucideIcons.fileText
// Icons.air_outlined → LucideIcons.wind
// Icons.water_drop_outlined → LucideIcons.droplet
// Icons.play_circle_outline → LucideIcons.playCircle
// Icons.battery_saver_outlined → LucideIcons.batteryWarning
// Icons.alarm → LucideIcons.alarmClock
```

- [ ] **Step 7: 在 card_order_screen.dart 中添加 import 并替换图标**

```dart
// 添加 import:
import 'package:lucide_icons/lucide_icons.dart';

// 替换:
// Icons.schedule_outlined → LucideIcons.clock
// Icons.calendar_month_outlined → LucideIcons.calendar
// Icons.air_outlined → LucideIcons.wind
// Icons.info_outline → LucideIcons.info
// Icons.tips_and_updates_outlined → LucideIcons.lightbulb
// Icons.restore_outlined → LucideIcons.undo2
// Icons.drag_handle → LucideIcons.gripVertical
```

- [ ] **Step 8: 运行 flutter analyze 验证无错误**

```bash
cd d:/EchoRan/Documents/GitHub/PureWeather && flutter analyze
```

Expected: 无错误，所有 LucideIcons 引用正确解析

- [ ] **Step 9: Commit**

```bash
git add lib/screens/ lib/core/constants/app_constants.dart
git commit -m "feat: migrate all screen icons from Material to Lucide"
```

---

### Task 14: 最终验证 - 全量构建 + Material Icons 残留检查

- [ ] **Step 1: 运行完整分析**

```bash
cd d:/EchoRan/Documents/GitHub/PureWeather && flutter analyze
```

- [ ] **Step 2: 搜索 Material Icons 残留**

```bash
cd d:/EchoRan/Documents/GitHub/PureWeather && grep -rn "Icons\." lib/
```

Expected: 零结果（或仅剩注释中的引用）

- [ ] **Step 3: 搜索 dynamic_color 残留**

```bash
cd d:/EchoRan/Documents/GitHub/PureWeather && grep -rn "dynamic_color\|useDynamicColor\|DynamicColor\|useMaterial3" lib/
```

Expected: 零结果

- [ ] **Step 4: Commit**

```bash
git commit -m "chore: final verification - zero Material Icon or Material You residuals" --allow-empty
```

---
