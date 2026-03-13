import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../services/deepseek_service.dart';
import '../../providers/weather_provider.dart';
import '../../providers/city_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/weather_models.dart';
import '../../generated/l10n/app_localizations.dart';

/// 天气助手屏幕
class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

/// 天气助手屏幕状态
class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  /// 消息输入控制器
  final _messageController = TextEditingController();
  
  /// 滚动控制器
  final _scrollController = ScrollController();
  
  /// 焦点节点
  final _focusNode = FocusNode();
  
  /// 是否正在输入
  bool _isTyping = false;
  
  /// 当前响应内容
  String _currentResponse = '';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 发送消息
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isTyping) return;

    _messageController.clear();
    _focusNode.unfocus();

    ref.read(chatProvider.notifier).addUserMessage(message);

    setState(() {
      _isTyping = true;
      _currentResponse = '';
    });

    _scrollToBottom();

    final weatherState = ref.read(weatherProvider);
    final defaultCity = ref.read(defaultCityProvider);
    final weatherContext = _buildWeatherContext(weatherState, defaultCity);

    final service = ref.read(deepSeekServiceProvider);
    final history = ref
        .read(chatProvider)
        .messages
        .where((m) => m.role != 'system')
        .toList();

    // 获取当前语言设置
    final languageMode = ref.read(languageProvider);
    final language = languageMode == LanguageMode.en ? 'en' : 'zh';

    try {
      final response = service.chatStream(
        userMessage: message,
        history: history,
        weatherContext: weatherContext,
        language: language,
      );

      await for (final chunk in response) {
        setState(() {
          _currentResponse += chunk;
        });
        _scrollToBottom();
      }

      ref.read(chatProvider.notifier).addAssistantMessage(_currentResponse);
    } catch (e) {
      final errorMsg = AppLocalizations.of(context).ai_error_message;
      ref.read(chatProvider.notifier).addAssistantMessage(errorMsg);
    } finally {
      setState(() {
        _isTyping = false;
        _currentResponse = '';
      });
    }
  }

  /// 构建天气上下文信息
  /// 
  /// [weatherState] 天气状态
  /// [location] 位置信息
  /// 
  /// 返回天气上下文字符串
  String _buildWeatherContext(WeatherState weatherState, Location? location) {
    final weather = weatherState.weatherData;
    if (weather == null || location == null) return '';

    // 构建完整的天气数据JSON
    final weatherData = {
      'location': {
        'name': location.name,
        'adm1': location.adm1,
        'adm2': location.adm2,
        'country': location.country,
        'lat': location.lat,
        'lon': location.lon
      },
      'current': {
        'temp': weather.current.temp,
        'feelsLike': weather.current.feelsLike,
        'text': weather.current.text,
        'humidity': weather.current.humidity,
        'windSpeed': weather.current.windSpeed,
        'windDir': weather.current.windDir,
        'windScale': weather.current.windScale,
        'precip': weather.current.precip,
        'pressure': weather.current.pressure,
        'vis': weather.current.vis,
        'cloud': weather.current.cloud,
        'obsTime': weather.current.obsTime
      },
      'daily': weather.daily.map((day) => {
        'fxDate': day.fxDate,
        'tempMax': day.tempMax,
        'tempMin': day.tempMin,
        'textDay': day.textDay,
        'textNight': day.textNight,
        'windDirDay': day.windDirDay,
        'windScaleDay': day.windScaleDay,
        'windDirNight': day.windDirNight,
        'windScaleNight': day.windScaleNight,
        'humidity': day.humidity,
        'precip': day.precip,
        'uvIndex': day.uvIndex
      }).toList(),
      'hourly': weather.hourly.take(24).map((hour) => {
        'fxTime': hour.fxTime,
        'temp': hour.temp,
        'text': hour.text,
        'windDir': hour.windDir,
        'windScale': hour.windScale,
        'pop': hour.pop,
        'precip': hour.precip
      }).toList(),
      'alerts': weather.alerts.map((alert) => {
        'title': alert.title,
        'level': alert.level,
        'typeName': alert.typeName,
        'text': alert.text,
        'pubTime': alert.pubTime
      }).toList(),
      'airQuality': weatherState.airQuality != null ? {
        'aqi': weatherState.airQuality!.aqi,
        'level': weatherState.airQuality!.level,
        'category': weatherState.airQuality!.category,
        'pm2p5': weatherState.airQuality!.pm2p5,
        'pm10': weatherState.airQuality!.pm10,
        'no2': weatherState.airQuality!.no2,
        'so2': weatherState.airQuality!.so2,
        'co': weatherState.airQuality!.co,
        'o3': weatherState.airQuality!.o3
      } : null,
      'lastUpdated': weather.lastUpdated.toIso8601String()
    };

    // 将天气数据转换为字符串表示
    final weatherJson = weatherData.toString();

    // 构建系统提示，告诉AI如何使用这些数据
    return '''
你是一个智能天气助手，需要根据以下天气数据回答用户的问题。请使用提供的天气数据提供准确的天气信息。

天气数据: $weatherJson

请根据以上数据回答用户的问题，确保信息准确且符合实际天气状况。
''';
  }

  /// 滚动到底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatSession = ref.watch(chatProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ai_assistant_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(chatProvider.notifier).clearHistory();
            },
            tooltip: l10n.clear_chat,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Expanded(
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
                  child: chatSession.messages.isEmpty
                      ? _buildEmptyState()
                      : _buildChatList(chatSession),
                ),
              ),
              if (_isTyping) _buildTypingIndicator(),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    // 检查当前是否为英文
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ).animate().scale(duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              l10n.ai_assistant_greeting,
              style: Theme.of(context).textTheme.titleLarge,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              l10n.ai_assistant_description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            // 英文提示
            if (isEnglish) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Note: The AI model used by this app has limited English support. We apologize for any inconvenience.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms),
            ],
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickAction(l10n.ai_quick_action_1),
                _buildQuickAction(l10n.ai_quick_action_2),
                _buildQuickAction(l10n.ai_quick_action_3),
              ],
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  /// 构建快速操作按钮
  /// 
  /// [text] 按钮文本
  /// 
  /// 返回ActionChip实例
  Widget _buildQuickAction(String text) {
    return ActionChip(
      label: Text(text),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      side: BorderSide(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 1,
      ),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
    );
  }

  /// 构建聊天列表
  /// 
  /// [session] 聊天会话
  /// 
  /// 返回ListView.builder实例
  Widget _buildChatList(ChatSession session) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount:
          session.messages.length + (_currentResponse.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < session.messages.length) {
          final message = session.messages[index];
          return _ChatBubble(
            message: message.content,
            isUser: message.role == 'user',
          ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1);
        } else {
          return _ChatBubble(message: _currentResponse, isUser: false);
        }
      },
    );
  }

  /// 构建输入指示器
  Widget _buildTypingIndicator() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: 18,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.ai_thinking,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: l10n.ai_input_hint,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: const Icon(Icons.send),
            onPressed: _isTyping ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}

/// 聊天气泡组件
class _ChatBubble extends StatelessWidget {
  /// 消息内容
  final String message;
  
  /// 是否是用户消息
  final bool isUser;

  /// 创建聊天气泡实例
  /// 
  /// [message] 消息内容
  /// [isUser] 是否是用户消息
  const _ChatBubble({required this.message, required this.isUser});

  String _formatAssistantMessage(String input) {
    var text = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // First, apply word segmentation to fix AI's missing spaces
    text = _segmentWords(text);

    // Keep numbered items readable even when model returns one long line.
    text = text.replaceAll(RegExp(r'(?<!\n)(\d+[.、])\s*'), '\n\$1 ');

    // Break long paragraphs at sentence punctuation for readability.
    // For Chinese punctuation, add newline.
    text = text.replaceAllMapped(
      RegExp(r'(?<=[。！？；])(?=[^\n])'),
      (match) => '\n',
    );
    // For English punctuation, add newline but keep the space after punctuation.
    text = text.replaceAllMapped(
      RegExp(r'(?<=[.!?;])(\s*)(?=[^\n])'),
      (match) => '\n${match.group(1) ?? ''}',
    );

    // Avoid too many blank lines after formatting.
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    return text;
  }

  /// Segment concatenated words using a comprehensive dictionary-based approach
  String _segmentWords(String text) {
    // Split text by lines first to preserve line structure
    final lines = text.split('\n');
    final processedLines = <String>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        processedLines.add(line);
        continue;
      }

      // Process each line
      var processedLine = _processLineWithDictionary(line);
      processedLines.add(processedLine);
    }

    return processedLines.join('\n');
  }

  /// Comprehensive English word dictionary for segmentation
  static final Set<String> _wordDictionary = {
    // Common words
    'a', 'an', 'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of',
    'with', 'by', 'from', 'as', 'is', 'are', 'was', 'were', 'be', 'been',
    'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
    'should', 'may', 'might', 'can', 'cannot', 'not', 'no', 'yes', 'so',
    'if', 'then', 'than', 'when', 'where', 'what', 'who', 'why', 'how',
    'all', 'any', 'both', 'each', 'every', 'few', 'more', 'most', 'much',
    'many', 'other', 'some', 'such', 'only', 'own', 'same', 'so', 'than',
    'too', 'very', 'just', 'now', 'also', 'back', 'after', 'use', 'two',
    'way', 'even', 'new', 'want', 'because', 'give', 'day', 'most', 'us',
    'get', 'make', 'go', 'know', 'take', 'see', 'come', 'think', 'look',
    'time', 'year', 'work', 'good', 'first', 'well', 'way', 'up', 'out',
    'down', 'off', 'over', 'under', 'again', 'further', 'then', 'once',
    'here', 'there', 'up', 'down', 'in', 'out', 'on', 'off', 'over',
    'under', 'again', 'further', 'then', 'once',

    // Weather related words
    'weather', 'temperature', 'temp', 'rain', 'raining', 'rainy', 'sunny',
    'sun', 'cloud', 'cloudy', 'wind', 'windy', 'snow', 'snowy', 'storm',
    'stormy', 'fog', 'foggy', 'mist', 'humid', 'humidity', 'dry', 'wet',
    'cold', 'cool', 'warm', 'hot', 'freezing', 'mild', 'moderate', 'heavy',
    'light', 'air', 'quality', 'pollution', 'polluted', 'clear', 'overcast',
    'forecast', 'degree', 'celsius', 'fahrenheit', 'precipitation', 'uv',
    'index', 'pressure', 'visibility', 'dew', 'point', 'chill', 'heat',
    'thunder', 'thunderstorm', 'lightning', 'hail', 'sleet', 'drizzle',
    'shower', 'showers', 'blizzard', 'breeze', 'gale', 'hurricane',
    'tornado', 'cyclone', 'typhoon', 'monsoon', 'season', 'spring',
    'summer', 'autumn', 'fall', 'winter', 'climate', 'atmospheric',

    // Time related
    'today', 'tomorrow', 'yesterday', 'morning', 'afternoon', 'evening',
    'night', 'noon', 'midnight', 'dawn', 'dusk', 'sunrise', 'sunset',
    'day', 'week', 'month', 'hour', 'minute', 'second', 'now', 'later',
    'soon', 'early', 'late', 'before', 'after', 'during', 'while',
    'around', 'about', 'until', 'till', 'from', 'to', 'at', 'on', 'in',
    'pm', 'am', 'oclock', 'clock',

    // Activity related
    'outdoor', 'indoor', 'sport', 'sports', 'exercise', 'exercising',
    'activity', 'activities', 'run', 'running', 'walk', 'walking',
    'swim', 'swimming', 'cycle', 'cycling', 'bike', 'biking', 'hike',
    'hiking', 'climb', 'climbing', 'play', 'playing', 'game', 'games',
    'workout', 'gym', 'fitness', 'training', 'practice', 'match',
    'competition', 'event', 'picnic', 'camping', 'travel', 'trip',
    'journey', 'tour', 'vacation', 'holiday', 'outing',

    // Advice related
    'advice', 'advise', 'recommend', 'recommendation', 'suggest',
    'suggestion', 'tip', 'tips', 'guide', 'guideline', 'rule', 'rules',
    'should', 'must', 'need', 'needs', 'needed', 'require', 'required',
    'necessary', 'important', 'essential', 'better', 'best', 'good',
    'bad', 'worse', 'worst', 'ideal', 'suitable', 'appropriate',
    'proper', 'fit', 'fitting', 'comfortable', 'safe', 'dangerous',
    'risk', 'risky', 'caution', 'careful', 'beware', 'avoid', 'prevent',
    'protect', 'protection', 'prepare', 'preparation', 'ready',
    'plan', 'planning', 'consider', 'considering', 'think', 'thinking',

    // Health related
    'health', 'healthy', 'unhealthy', 'safe', 'safety', 'danger',
    'harm', 'harmful', 'irritate', 'irritating', 'irritated',
    'allergy', 'allergic', 'asthma', 'breathing', 'breath', 'lung',
    'lungs', 'heart', 'skin', 'eye', 'eyes', 'throat', 'cough',
    'sneeze', 'sneezing', 'symptom', 'symptoms', 'condition',
    'medical', 'medicine', 'doctor', 'hospital', 'emergency',

    // Clothing related
    'clothes', 'clothing', 'wear', 'wearing', 'dress', 'dressing',
    'jacket', 'coat', 'sweater', 'shirt', 'tshirt', 'pants', 'shorts',
    'skirt', 'dress', 'suit', 'uniform', 'shoes', 'boots', 'sandals',
    'hat', 'cap', 'gloves', 'scarf', 'umbrella', 'raincoat',
    'waterproof', 'warm', 'warmer', 'cool', 'cooler', 'layer',
    'layers', 'cover', 'protect', 'sunscreen', 'sunglasses',

    // Location related
    'outside', 'inside', 'outdoors', 'indoors', 'home', 'house',
    'building', 'room', 'office', 'school', 'park', 'garden', 'yard',
    'street', 'road', 'highway', 'path', 'trail', 'track', 'field',
    'court', 'pool', 'beach', 'mountain', 'hill', 'valley', 'river',
    'lake', 'sea', 'ocean', 'city', 'town', 'village', 'area',
    'region', 'zone', 'place', 'location', 'spot', 'site',

    // Degree and measurement
    'high', 'higher', 'highest', 'low', 'lower', 'lowest', 'level',
    'levels', 'amount', 'amounts', 'quantity', 'quantities', 'measure',
    'measurement', 'degree', 'degrees', 'percent', 'percentage', 'rate',
    'ratio', 'value', 'values', 'number', 'numbers', 'count', 'total',
    'sum', 'average', 'mean', 'maximum', 'max', 'minimum', 'min',
    'range', 'limit', 'limits', 'extreme', 'moderate', 'normal',

    // Condition related
    'condition', 'conditions', 'situation', 'state', 'status', 'case',
    'environment', 'atmosphere', 'surrounding', 'surroundings',
    'context', 'circumstance', 'circumstances', 'factor', 'factors',
    'element', 'elements', 'aspect', 'aspects', 'feature', 'features',
    'characteristic', 'characteristics', 'property', 'properties',
    'quality', 'qualities', 'nature', 'type', 'types', 'kind', 'kinds',
    'sort', 'sorts', 'form', 'forms', 'way', 'ways', 'manner', 'mode',

    // Response structure words
    'conclusion', 'conclude', 'concluding', 'summary', 'summarize',
    'reason', 'reasons', 'because', 'cause', 'causes', 'caused',
    'due', 'result', 'results', 'resulting', 'effect', 'effects',
    'affect', 'affects', 'affected', 'impact', 'impacts', 'influence',
    'factor', 'factors', 'why', 'how', 'what', 'when', 'where',
    'additional', 'additionally', 'also', 'besides', 'furthermore',
    'moreover', 'however', 'therefore', 'thus', 'hence', 'consequently',
    'otherwise', 'instead', 'alternatively', 'meanwhile', 'otherwise',
  };

  /// Process a single line using dictionary-based segmentation
  String _processLineWithDictionary(String line) {
    var result = StringBuffer();
    var i = 0;

    while (i < line.length) {
      final char = line[i];

      // If it's not a letter, just add it
      if (!RegExp(r'[a-zA-Z]').hasMatch(char)) {
        result.write(char);
        i++;
        continue;
      }

      // Find the longest matching word starting at position i
      String? bestMatch;
      int bestLength = 0;

      // Try different word lengths (max 25 characters)
      for (int len = 1; len <= 25 && i + len <= line.length; len++) {
        final substr = line.substring(i, i + len).toLowerCase();

        // Check if this is a valid word
        if (_wordDictionary.contains(substr)) {
          // Prefer longer matches
          if (len > bestLength) {
            bestMatch = substr;
            bestLength = len;
          }
        }

        // Also check if we've reached a good break point
        // (next char is uppercase or non-letter)
        if (i + len < line.length) {
          final nextChar = line[i + len];
          if (RegExp(r'[A-Z]').hasMatch(nextChar) ||
              !RegExp(r'[a-zA-Z]').hasMatch(nextChar)) {
            // If we have a match at this point, use it
            if (bestMatch != null) {
              break;
            }
          }
        }
      }

      // If we found a match, use it
      if (bestMatch != null && bestLength > 0) {
        // Add space before word if needed
        if (result.isNotEmpty &&
            !result.toString().endsWith(' ') &&
            !result.toString().endsWith('\n') &&
            !result.toString().endsWith(':') &&
            !result.toString().endsWith(',')) {
          result.write(' ');
        }

        // Write the word with original case
        result.write(line.substring(i, i + bestLength));
        i += bestLength;
      } else {
        // No match found, just copy the character
        result.write(char);
        i++;
      }
    }

    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    final displayMessage = isUser ? message : _formatAssistantMessage(message);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
        ),
        child: Text(
          displayMessage,
          softWrap: true,
          overflow: TextOverflow.visible,
          textWidthBasis: TextWidthBasis.parent,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isUser
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
