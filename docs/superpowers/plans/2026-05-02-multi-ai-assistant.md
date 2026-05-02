# Multi-Model AI Weather Assistant Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove hardcoded DeepSeek API key and model, replace with user-configurable multi-model AI backend (API key, base URL, model name persisted locally), and prompt users to configure when unset.

**Architecture:** DeepSeekService becomes generic AIService that reads apiKey/baseUrl/model from SettingsNotifier (SharedPreferences) at runtime. The AI assistant screen checks for configuration and shows a setup prompt when missing, with a shortcut to the new settings section. Settings page gains an "AI Model" configuration group with API key, base URL, and model name inputs.

**Tech Stack:** Flutter 3.41+, Riverpod, SharedPreferences, Dio (OpenAI-compatible chat completions API)

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `lib/services/deepseek_service.dart` | Rewrite | Generic AIService with runtime-configurable apiKey/baseUrl/model |
| `lib/services/services.dart` | Modify | Update barrel export |
| `lib/core/constants/api_config.dart` | Modify | Remove deepseekApiKey / deepseekBaseUrl getters |
| `lib/providers/settings_provider.dart` | Modify | Add aiApiKey / aiBaseUrl / aiModel fields + persistence |
| `lib/screens/ai_assistant/ai_assistant_screen.dart` | Modify | Check AI config; show setup prompt when unconfigured |
| `lib/screens/settings/settings_screen.dart` | Modify | Add AI model config section; update DeepSeek references |
| `lib/app_localizations.dart` | Modify | Add new localization keys |
| `.env` | Modify | Remove DEEPSEEK_API_KEY / DEEPSEEK_BASE_URL |
| `.env.example` | Modify | Remove DEEPSEEK_API_KEY / DEEPSEEK_BASE_URL |
| `.github/workflows/build-and-release.yml` | Modify | Remove all DEEPSEEK_API_KEY injection (6 jobs) |

---

### Task N: AI Config in AppSettings

**Files:**
- Modify: `lib/providers/settings_provider.dart`

- [ ] **Step 1: Add fields to AppSettings**

```dart
// In class AppSettings, add fields after showAIAssistant:
  final String aiApiKey;
  final String aiBaseUrl;
  final String aiModel;
```

Update the constructor with defaults:

```dart
  const AppSettings({
    // ... existing fields ...
    this.showAIAssistant = true,
    this.aiApiKey = '',
    this.aiBaseUrl = 'https://api.deepseek.com/v1',
    this.aiModel = 'deepseek-chat',
    // ... rest ...
  });
```

- [ ] **Step 2: Update AppSettings.copyWith**

```dart
  AppSettings copyWith({
    // ... existing params ...
    bool? showAIAssistant,
    String? aiApiKey,
    String? aiBaseUrl,
    String? aiModel,
    // ... rest ...
  }) {
    return AppSettings(
      // ... existing fields ...
      showAIAssistant: showAIAssistant ?? this.showAIAssistant,
      aiApiKey: aiApiKey ?? this.aiApiKey,
      aiBaseUrl: aiBaseUrl ?? this.aiBaseUrl,
      aiModel: aiModel ?? this.aiModel,
      // ... rest ...
    );
  }
```

- [ ] **Step 3: Add SharedPreferences keys and load logic**

Add keys in SettingsNotifier:

```dart
  static const String _keyAiApiKey = 'ai_api_key';
  static const String _keyAiBaseUrl = 'ai_base_url';
  static const String _keyAiModel = 'ai_model';
```

Update `_loadSettings()` — add to the `AppSettings(...)` constructor call:

```dart
      state = AppSettings(
        // ... existing fields ...
        showAIAssistant: prefs.getBool(_keyShowAIAssistant) ?? true,
        aiApiKey: prefs.getString(_keyAiApiKey) ?? '',
        aiBaseUrl: prefs.getString(_keyAiBaseUrl) ?? 'https://api.deepseek.com/v1',
        aiModel: prefs.getString(_keyAiModel) ?? 'deepseek-chat',
        // ... rest ...
      );
```

- [ ] **Step 4: Add setter methods**

```dart
  Future<void> setAiApiKey(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAiApiKey, value);
    state = state.copyWith(aiApiKey: value);
  }

  Future<void> setAiBaseUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAiBaseUrl, value);
    state = state.copyWith(aiBaseUrl: value);
  }

  Future<void> setAiModel(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAiModel, value);
    state = state.copyWith(aiModel: value);
  }
```

- [ ] **Step 5: Commit**

```bash
git add lib/providers/settings_provider.dart
git commit -m "feat: add AI config fields to settings (apiKey, baseUrl, model)"
```

---

### Task 2: Remove DeepSeek-specific config from ApiConfig

**Files:**
- Modify: `lib/core/constants/api_config.dart`

- [ ] **Step 1: Remove DeepSeek getters**

Remove these two getters from ApiConfig:

```dart
  static String get deepseekApiKey { ... }
  static String get deepseekBaseUrl { ... }
```

Keep all other getters (qweather, caiyun, amap) unchanged.

- [ ] **Step 2: Commit**

```bash
git add lib/core/constants/api_config.dart
git commit -m "refactor: remove DeepSeek API key / base URL from ApiConfig"
```

---

### Task 3: Refactor DeepSeekService to generic AIService

**Files:**
- Rewrite: `lib/services/deepseek_service.dart` (rename conceptually; keep filename for now to minimize diff, will rename in a follow-up)
- Modify: `lib/services/services.dart`

- [ ] **Step 1: Rewrite the service class**

Replace `DeepSeekService` with `AIService` in `lib/services/deepseek_service.dart`. The class reads config from `AppSettings` at runtime:

```dart
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_localizations.dart';
import '../providers/settings_provider.dart';

class AIService {
  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;
  final String _model;

  AIService({
    Dio? dio,
    required String apiKey,
    required String baseUrl,
    required String model,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 60),
                receiveTimeout: const Duration(seconds: 120),
                headers: const {'Content-Type': 'application/json'},
              ),
            ),
        _apiKey = apiKey,
        _baseUrl = baseUrl,
        _model = model;

  bool get isConfigured => _apiKey.isNotEmpty;

  // _buildSystemPrompt — identical, keep unchanged

  // _sanitizeAiResponse — identical, keep unchanged

  Stream<String> chatStream({
    required String userMessage,
    required List<ChatMessage> history,
    String? weatherContext,
  }) async* {
    if (!isConfigured) {
      yield AppLocalizations.tr('请先在设置中配置 AI 模型 API 密钥。');
      return;
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _buildSystemPrompt(weatherContext)},
      ...history.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await _dio.post<ResponseBody>(
        '$_baseUrl/chat/completions',
        data: {
          'model': _model,
          'messages': messages,
          'stream': true,
          'temperature': 0.7,
          'max_tokens': 2048,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $_apiKey'},
          responseType: ResponseType.stream,
        ),
      );

      // ... rest of stream handling is identical ...
    } catch (e) {
      yield AppLocalizations.tr(
        '抱歉，发生了错误：{error}',
        args: {'error': e.toString()},
      );
    }
  }

  // chat() — identical, keep unchanged
  // sanitizeResponse() — identical, keep unchanged
}
```

Key changes from original:
- Constructor takes `required String apiKey`, `required String baseUrl`, `required String model` (no defaults from ApiConfig)
- `model` field used instead of hardcoded `'deepseek-v4-flash'`
- `isConfigured` getter added
- No import of `api_config.dart`

- [ ] **Step 2: Update Riverpod providers**

Replace the `deepSeekServiceProvider` with an `aiServiceProvider` that reads from `settingsProvider`:

```dart
final aiServiceProvider = Provider<AIService>((ref) {
  final settings = ref.watch(settingsProvider);
  return AIService(
    apiKey: settings.aiApiKey,
    baseUrl: settings.aiBaseUrl,
    model: settings.aiModel,
  );
});
```

Keep `ChatMessage`, `ChatSession`, `ChatNotifier`, and `chatProvider` unchanged.

- [ ] **Step 3: Update barrel export**

In `lib/services/services.dart`:
```dart
export 'qweather_service.dart';
export 'caiyun_service.dart';
export 'location_service.dart';
export 'deepseek_service.dart';  // keep filename; class inside is now AIService
export 'notification_service.dart';
```

- [ ] **Step 4: Run existing tests to verify no breakage**

```bash
flutter test
```

- [ ] **Step 5: Commit**

```bash
git add lib/services/deepseek_service.dart lib/services/services.dart
git commit -m "refactor: rename DeepSeekService to AIService with runtime config from settings"
```

---

### Task 4: Handle unconfigured state in AI Assistant screen

**Files:**
- Modify: `lib/screens/ai_assistant/ai_assistant_screen.dart`

- [ ] **Step 1: Check config before sending and show unconfigured empty state**

Update `_sendMessage()` to use `aiServiceProvider` instead of `deepSeekServiceProvider`:

```dart
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isTyping) return;

    final aiSettings = ref.read(settingsProvider);
    if (aiSettings.aiApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('请先在设置中配置 AI 模型的 API 密钥。'))),
      );
      return;
    }

    // ... rest unchanged, but use aiServiceProvider ...
    final service = ref.read(aiServiceProvider);
    // ...
  }
```

Update the import to use `aiServiceProvider` instead of `deepSeekServiceProvider`.

- [ ] **Step 2: Replace `_buildEmptyState()` with conditional logic**

When `aiApiKey` is empty, show a config prompt instead of the quick-action chips:

```dart
  Widget _buildEmptyState() {
    final settings = ref.watch(settingsProvider);
    final isConfigured = settings.aiApiKey.isNotEmpty;

    if (!isConfigured) {
      return _buildUnconfiguredPrompt();
    }

    return Center(
      child: SingleChildScrollView(
        // ... existing empty state with robot icon and quick actions unchanged ...
      ),
    );
  }
```

- [ ] **Step 3: Add navigation tab provider**

To allow the unconfigured prompt's "去配置" button to switch to the settings tab, add a small provider in `lib/providers/settings_provider.dart`:

```dart
/// Navigation tab index provider — allows child screens to request tab switches.
final navigationTabProvider = StateProvider<int>((ref) => 0);
```

- [ ] **Step 4: Wire MainScreen to sync with navigationTabProvider**

In `lib/screens/main_screen.dart`, update `_MainScreenState`:

Add a listener in `build()`:
```dart
  @override
  Widget build(BuildContext context) {
    // Sync local _currentIndex with navigationTabProvider
    ref.listen(navigationTabProvider, (prev, next) {
      if (_currentIndex != next) {
        setState(() { _currentIndex = next; });
      }
    });
    // ... rest unchanged ...
  }
```

And in `onDestinationSelected`, sync back:
```dart
        onDestinationSelected: (index) {
          setState(() { _currentIndex = index; });
          ref.read(navigationTabProvider.notifier).state = index;
        },
```

- [ ] **Step 5: Add `_buildUnconfiguredPrompt()` widget**

```dart
  Widget _buildUnconfiguredPrompt() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings_suggest_outlined,
                  size: 40,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ).animate().scale(duration: 400.ms),
              const SizedBox(height: 24),
              Text(
                context.tr('尚未配置 AI 模型'),
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                context.tr('请配置您自己的 AI 模型 API 密钥后使用天气助手。支持 OpenAI、DeepSeek 等兼容接口。'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: const Icon(Icons.settings),
                label: Text(context.tr('去配置')),
                onPressed: () {
                  final showAI = ref.read(settingsProvider).showAIAssistant;
                  ref.read(navigationTabProvider.notifier).state = showAI ? 2 : 1;
                },
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ref.read(settingsProvider.notifier).setShowAIAssistant(false);
                },
                child: Text(context.tr('隐藏天气助手')),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
```

Import `navigationTabProvider` from `'../../providers/settings_provider.dart'` in `ai_assistant_screen.dart`.

- [ ] **Step 6: Commit**

```bash
git add lib/providers/settings_provider.dart lib/screens/main_screen.dart lib/screens/ai_assistant/ai_assistant_screen.dart
git commit -m "feat: show AI config prompt when API key is not set, hide option, tab navigation provider"
```

---

### Task 5: Add AI model configuration UI to settings screen

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart`

- [ ] **Step 1: Add "AI 模型" section to settings**

Insert a new `SettingsSection` before the "显示" section (or create a dedicated section). Add it after the "个性化" section and before the "显示" section. In the build method, find the "显示" section and insert before it:

```dart
  // AI 模型配置组 (insert before 显示 section)
  SettingsSection(
    title: 'AI 模型',
    icon: Icons.psychology_outlined,
    animationDelay: 75,
    children: [
      SettingsListTile(
        icon: Icons.vpn_key_outlined,
        title: 'API 密钥',
        subtitle: appSettings.aiApiKey.isNotEmpty
            ? '已设置 (${_maskApiKey(appSettings.aiApiKey)})'
            : '未设置',
        onTap: () => _showAiApiKeyDialog(context, ref, appSettings),
      ),
      SettingsListTile(
        icon: Icons.link_outlined,
        title: 'API 地址',
        subtitle: appSettings.aiBaseUrl,
        onTap: () => _showAiBaseUrlDialog(context, ref, appSettings),
      ),
      SettingsListTile(
        icon: Icons.model_training_outlined,
        title: '模型名称',
        subtitle: appSettings.aiModel,
        onTap: () => _showAiModelDialog(context, ref, appSettings),
      ),
    ],
  ),
```

- [ ] **Step 2: Add `_maskApiKey` helper**

```dart
  String _maskApiKey(String key) {
    if (key.length <= 8) return '****';
    return '${key.substring(0, 4)}****${key.substring(key.length - 4)}';
  }
```

- [ ] **Step 3: Add `_showAiApiKeyDialog`**

```dart
  void _showAiApiKeyDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final controller = TextEditingController(text: settings.aiApiKey);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: 'API 密钥',
        bottomAction: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.tr('取消')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  ref.read(settingsProvider.notifier).setAiApiKey(controller.text.trim());
                  Navigator.pop(ctx);
                },
                child: Text(context.tr('保存')),
              ),
            ),
          ],
        ),
        children: [
          _BottomSheetTokenCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '输入您的 AI 模型 API 密钥（如 OpenAI、DeepSeek 等）',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'sk-...',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.uiTokens.cardBorder),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
```

- [ ] **Step 4: Add `_showAiBaseUrlDialog`**

```dart
  void _showAiBaseUrlDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final controller = TextEditingController(text: settings.aiBaseUrl);
    final presets = const [
      ('DeepSeek', 'https://api.deepseek.com/v1'),
      ('OpenAI', 'https://api.openai.com/v1'),
      ('OpenAI 代理', 'https://api.openai-proxy.com/v1'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: 'API 地址',
        bottomAction: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.tr('取消')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  ref.read(settingsProvider.notifier).setAiBaseUrl(controller.text.trim());
                  Navigator.pop(ctx);
                },
                child: Text(context.tr('保存')),
              ),
            ),
          ],
        ),
        children: [
          ...presets.map((preset) => SettingsSelectionItem(
            title: preset.$1,
            subtitle: preset.$2,
            icon: Icons.cloud_outlined,
            isSelected: settings.aiBaseUrl == preset.$2,
            onTap: () {
              controller.text = preset.$2;
              ref.read(settingsProvider.notifier).setAiBaseUrl(preset.$2);
              Navigator.pop(ctx);
            },
          )),
          _BottomSheetTokenCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '自定义地址',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'https://api.example.com/v1',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.uiTokens.cardBorder),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
```

- [ ] **Step 5: Add `_showAiModelDialog`**

```dart
  void _showAiModelDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final controller = TextEditingController(text: settings.aiModel);
    final presets = const [
      ('DeepSeek V4', 'deepseek-v4-flash'),
      ('DeepSeek Chat', 'deepseek-chat'),
      ('DeepSeek Reasoner', 'deepseek-reasoner'),
      ('GPT-4o', 'gpt-4o'),
      ('GPT-4o Mini', 'gpt-4o-mini'),
      ('Claude Opus 4.7', 'claude-opus-4-7'),
      ('Claude Sonnet 4.6', 'claude-sonnet-4-6'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsBottomSheet(
        title: '模型名称',
        bottomAction: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.tr('取消')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  ref.read(settingsProvider.notifier).setAiModel(controller.text.trim());
                  Navigator.pop(ctx);
                },
                child: Text(context.tr('保存')),
              ),
            ),
          ],
        ),
        children: [
          ...presets.map((preset) => SettingsSelectionItem(
            title: preset.$1,
            subtitle: preset.$2,
            icon: Icons.smart_toy_outlined,
            isSelected: settings.aiModel == preset.$2,
            onTap: () {
              ref.read(settingsProvider.notifier).setAiModel(preset.$2);
              Navigator.pop(ctx);
            },
          )),
          _BottomSheetTokenCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '自定义模型',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'your-model-name',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.uiTokens.cardBorder),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
```

- [ ] **Step 6: Commit**

```bash
git add lib/screens/settings/settings_screen.dart
git commit -m "feat: add AI model configuration UI (API key, URL, model) in settings"
```

---

### Task 6: Add localization strings

**Files:**
- Modify: `lib/app_localizations.dart`

- [ ] **Step 1: Add new string key-value pairs**

In the `_data` map, add these entries under both the Chinese and English sections.

In the Chinese section (add near the existing assistant keys):
```dart
    'AI 模型': 'AI 模型',
    'API 密钥': 'API 密钥',
    'API 地址': 'API 地址',
    '模型名称': '模型名称',
    '已设置': '已设置',
    '未设置': '未设置',
    '尚未配置 AI 模型': '尚未配置 AI 模型',
    '请配置您自己的 AI 模型 API 密钥后使用天气助手。支持 OpenAI、DeepSeek 等兼容接口。': '请配置您自己的 AI 模型 API 密钥后使用天气助手。支持 OpenAI、DeepSeek 等兼容接口。',
    '去配置': '去配置',
    '隐藏天气助手': '隐藏天气助手',
    '请先在设置中配置 AI 模型的 API 密钥。': '请先在设置中配置 AI 模型的 API 密钥。',
    '输入您的 AI 模型 API 密钥（如 OpenAI、DeepSeek 等）': '输入您的 AI 模型 API 密钥（如 OpenAI、DeepSeek 等）',
    '保存': '保存',
    '自定义地址': '自定义地址',
    '自定义模型': '自定义模型',
```

In the English section:
```dart
    'AI 模型': 'AI Model',
    'API 密钥': 'API Key',
    'API 地址': 'API URL',
    '模型名称': 'Model Name',
    '已设置': 'Set',
    '未设置': 'Not Set',
    '尚未配置 AI 模型': 'AI Model Not Configured',
    '请配置您自己的 AI 模型 API 密钥后使用天气助手。支持 OpenAI、DeepSeek 等兼容接口。': 'Please configure your own AI model API key to use the weather assistant. Supports OpenAI-compatible APIs.',
    '去配置': 'Configure',
    '隐藏天气助手': 'Hide Weather Assistant',
    '请先在设置中配置 AI 模型的 API 密钥。': 'Please configure the AI model API key in settings first.',
    '输入您的 AI 模型 API 密钥（如 OpenAI、DeepSeek 等）': 'Enter your AI model API key (e.g. OpenAI, DeepSeek)',
    '保存': 'Save',
    '自定义地址': 'Custom URL',
    '自定义模型': 'Custom Model',
```

- [ ] **Step 2: Commit**

```bash
git add lib/app_localizations.dart
git commit -m "feat: add AI model configuration localization strings"
```

---

### Task 7: Update DeepSeek → generic references in settings (privacy, about)

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart`

- [ ] **Step 1: Update privacy policy text**

In `_showPrivacyPolicy`, update the third-party services section (line ~1608). Change:
```
• DeepSeek：提供天气助手的AI问答功能，您的天气查询问题将发送至其服务器以获取智能回答。
```
To:
```
• AI 模型服务：提供天气助手的AI问答功能，您自行配置的 API 服务商将收到您的天气查询问题以获取智能回答。
```

In the English version:
```
• AI model service: provides AI Q&A for the weather assistant. The API provider you configure will receive your weather questions to generate responses.
```

- [ ] **Step 2: Update user agreement text**

In `_showUserAgreement`, update (line ~1632). Change:
```
• 天气助手功能由DeepSeek提供，其回答基于AI模型，可能存在一定的局限性和误差，仅供参考。
```
To:
```
• 天气助手功能基于您自行配置的 AI 模型 API，其回答可能存在一定的局限性和误差，仅供参考。
```

Also update the fourth-party line:
```
本应用使用和风天气、彩云天气、高德地图和DeepSeek等第三方服务
```
To:
```
本应用使用和风天气、彩云天气、高德地图等第三方服务，天气助手功能使用您自行配置的 AI 模型接口
```

- [ ] **Step 3: Update About page acknowledgment**

In `_AboutBottomSheet`, change:
```dart
              _buildAboutItem(
                context,
                Icons.lightbulb_outlined,
                'DeepSeek',
                '提供天气助手的 AI 问答功能',
              ),
```
To:
```dart
              _buildAboutItem(
                context,
                Icons.lightbulb_outlined,
                context.tr('AI 模型'),
                context.tr('由您自行配置，为天气助手提供智能问答'),
              ),
```

- [ ] **Step 4: Commit**

```bash
git add lib/screens/settings/settings_screen.dart
git commit -m "docs: remove DeepSeek brand references, replace with generic AI model mention"
```

---

### Task 8: Remove DeepSeek API keys from .env and .env.example

**Files:**
- Modify: `.env`
- Modify: `.env.example`

- [ ] **Step 1: Remove DeepSeek lines from .env**

Remove lines 13-15:
```
# DeepSeek API密钥
DEEPSEEK_API_KEY=sk-0d51cce0b00348b3a2ab1281c9325709
DEEPSEEK_BASE_URL=https://api.deepseek.com/v1
```

- [ ] **Step 2: Remove DeepSeek lines from .env.example**

Remove lines 13-15:
```
# DeepSeek API密钥
DEEPSEEK_API_KEY=your_deepseek_api_key_here
DEEPSEEK_BASE_URL=https://api.deepseek.com/v1
```

- [ ] **Step 3: Commit**

```bash
git add .env .env.example
git commit -m "chore: remove hardcoded DeepSeek API key from .env files"
```

---

### Task 9: Remove DeepSeek API key from CI/CD workflow

**Files:**
- Modify: `.github/workflows/build-and-release.yml`

- [ ] **Step 1: Remove all DEEPSEEK_API_KEY references from build-and-release.yml**

Remove every `DEEPSEEK_API_KEY` line from the workflow. This involves:
1. Removing `DEEPSEEK_API_KEY: ${{ secrets.DEEPSEEK_API_KEY }}` from all `env:` blocks (6 jobs)
2. Removing `DEEPSEEK_API_KEY=$DEEPSEEK_API_KEY` / `DEEPSEEK_API_KEY=$env:DEEPSEEK_API_KEY` from all `.env` file generation steps
3. Removing `--dart-define=DEEPSEEK_API_KEY=...` from all `flutter build` commands

In each of the 6 job blocks (android, windows, linux, web, macos, ios):
- Remove the `DEEPSEEK_API_KEY` line from the `env:` section
- Remove the `DEEPSEEK_API_KEY=...` line from the `.env` heredoc / PowerShell block
- Remove the `--dart-define=DEEPSEEK_API_KEY=...` argument from flutter build commands

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/build-and-release.yml
git commit -m "ci: remove DeepSeek API key injection from all build jobs"
```

---

### Task 10: Full verification

**Files:** None (verification only)

- [ ] **Step 1: Run all existing tests**

```bash
flutter test
```
Expected: all tests pass; no compilation errors from removed imports or renamed classes.

- [ ] **Step 2: Run static analysis**

```bash
flutter analyze
```
Expected: no errors (warnings are OK but should be minimized).

- [ ] **Step 3: Manual smoke test checklist**

1. Launch app → settings → verify "AI 模型" section appears with API Key / URL / Model fields
2. API Key shows "Not Set" by default
3. Open weather assistant tab → verify "AI Model Not Configured" prompt appears
4. Tap "Configure" → verify it navigates to settings
5. Tap "Hide Weather Assistant" → verify it disappears from navigation
6. In settings, set an API key → verify assistant page now shows normal chat UI
7. Verify chat still works (requires a valid API key)
8. Toggle "显示天气助手" off → verify assistant tab hides
9. Toggle it back on → verify it reappears
10. Check privacy policy / user agreement / about page for removed DeepSeek references

- [ ] **Step 4: Commit any final fixes**

```bash
git add -A
git commit -m "chore: final verification fixes"
```

---
