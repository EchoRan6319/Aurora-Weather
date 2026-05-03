# 极光天气 (Aurora Weather)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20Web-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.41+-02569B?logo=flutter)

一款使用 **Aurora UI** 构建的现代化跨平台天气应用，支持玻璃质感主题、多城市管理和 AI 天气助手。

（本项目近期正在重构，稳定性略有不足，请知悉）

## 预览

![极光天气应用界面](App_Screenshot.jpg)

## 功能特性

- **🌤 多源天气数据** — 和风天气（实时/逐时/逐日/预警/空气质量）+ 彩云天气（分钟级降水预报）
- **🎨 Aurora UI** — 玻璃质感卡片、天气驱动动态渐变背景、深色/浅色主题
- **📍 城市管理** — 多城市支持、自动定位、城市搜索
- **📊 天气详情** — 当前温度、24 小时预报、7 日预报、空气质量、生活指数、天气预警
- **🤖 天气助手** — 基于 DeepSeek V4 的智能问答，支持天气分析与建议
- **🔔 定时播报** — 每日早晚天气推送，Android 16+ 支持实时更新通知

## 平台支持

| 平台 | 安装包 | 状态 |
|------|--------|------|
| Android | APK (arm64-v8a) | ✅ |
| Windows | MSIX / Inno Setup EXE | ✅ |
| Linux | tar.gz | ✅ |
| macOS | DMG (universal) | ✅ |
| iOS | IPA（未签名） | ✅ |
| Web | ZIP | ✅ |

> 所有平台构建产物均由 GitHub Actions 自动发布到 [Releases](https://github.com/EchoRan6319/PureWeather/releases)。 

---

## 快速开始

### 环境要求

- Flutter SDK >= 3.41
- VS Code

```bash
# 克隆项目
git clone https://github.com/EchoRan6319/PureWeather.git
cd PureWeather

# 获取依赖
flutter pub get
```

### 配置 API

在项目根目录创建 `.env` 文件：

```env
QWEATHER_API_KEY=你的和风天气API密钥
CAIYUN_API_KEY=你的彩云天气API密钥
AMAP_API_KEY=你的高德地图API密钥
AMAP_WEB_KEY=你的高德Web端API密钥
DEEPSEEK_API_KEY=你的DeepSeek API密钥
```

> **提示**：API 密钥也可以通过 `--dart-define` 或环境变量传入，详见 [API 配置](/lib/core/constants/api_config.dart)。

### 运行

```bash
# Android
flutter run

# Windows
flutter run -d windows

# Linux
flutter run -d linux

# macOS
flutter run -d macos

# Web
flutter run -d chrome
```

> 调试版使用 `applicationId` 后缀 `.debug`，可与正式版同时安装在手机上互不冲突。

---

## 构建

### 本地构建

```bash
# Android（arm64-v8a）
flutter build apk --release --target-platform=android-arm64

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release

# iOS（需 Xcode，不签名）
flutter build ios --release --no-codesign

# Web
flutter build web --release
```

### CI 自动构建（推荐）

推送 Git 标签即可触发 GitHub Actions 构建并发布 Release：

```bash
git tag v5.4.1-1
git push origin v5.4.1-1
```

自动生成的安装包：

| 平台 | 产物 |
|------|------|
| Android | `AuroraWeather-{version}-android-arm64-v8a-release.apk` |
| Android | `AuroraWeather-{version}-android-arm64-v8a-debug.apk` |
| Windows | `AuroraWeather-{version}-windows-x64-installer.msix` |
| Windows | `AuroraWeather-{version}-windows-x64-setup.exe` |
| Linux | `AuroraWeather-{version}-linux-x64.tar.gz` |
| macOS | `AuroraWeather-{version}-macos-universal.dmg` |
| iOS | `AuroraWeather-{version}-ios-unsigned.ipa` |
| Web | `AuroraWeather-{version}-web-release.zip` |

---

## 项目结构

```
lib/
├── core/                   # 常量、主题、工具
│   ├── constants/
│   └── theme/
├── models/                 # 数据模型（freezed）
│   └── weather_models.dart
├── providers/              # Riverpod 状态管理
│   ├── weather_provider.dart
│   ├── city_provider.dart
│   ├── settings_provider.dart
│   └── theme_provider.dart
├── services/               # API 及系统服务
│   ├── qweather_service.dart         # 和风天气
│   ├── caiyun_service.dart           # 彩云天气
│   ├── location_service.dart         # 高德定位
│   ├── deepseek_service.dart         # AI 助手
│   ├── notification_service.dart
│   └── scheduled_broadcast_service.dart
├── screens/                # 页面
│   ├── weather/
│   ├── settings/
│   └── ai_assistant/
└── widgets/                # 可复用组件
```

### 状态管理

使用 **Riverpod** 进行状态管理，`StateNotifierProvider` 处理可变状态，`FutureProvider` 处理异步数据。

### 数据流

```
用户操作 → Riverpod Provider → Service (Dio) → 外部 API
                 ↓
         UI 通过 ref.watch() 自动更新
```

---

## 技术栈

| 类别 | 选型 |
|------|------|
| 框架 | Flutter 3.41+ |
| 状态管理 | Riverpod 2.x |
| 数据模型 | Freezed + json_serializable |
| 网络请求 | Dio |
| 通知 | flutter_local_notifications |
| 本地存储 | SharedPreferences |
| 主题 | Aurora Palette（固定色彩体系） |
| AI | DeepSeek V4（OpenAI 兼容接口） |

---

## 开源协议

[MIT](LICENSE) © EchoRan
