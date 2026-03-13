import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';

/// 应用常量类
/// 包含应用的基本配置和常量
class AppConstants {
  /// 应用名称
  static const String appName = '轻氧天气';
  
  /// 应用版本号
  static const String appVersion = '3.7.0';

  /// API 请求超时时间
  static const Duration apiTimeout = Duration(seconds: 15);
  
  /// 缓存有效期
  static const Duration cacheValidDuration = Duration(minutes: 30);

  /// 最大城市数量
  static const int maxCities = 10;
  
  /// 默认动画持续时间（毫秒）
  static const int defaultAnimationDuration = 300;
}

/// 天气代码工具类
/// 提供天气代码的描述、图标和温度转换功能
class WeatherCode {
  /// 天气代码到描述的映射
  static const Map<int, String> descriptions = {
    100: '晴',
    101: '多云',
    102: '少云',
    103: '晴间多云',
    104: '阴',
    150: '晴',
    151: '多云',
    152: '少云',
    153: '晴间多云',
    300: '阵雨',
    301: '强阵雨',
    302: '雷阵雨',
    303: '强雷阵雨',
    304: '雷阵雨伴有冰雹',
    305: '小雨',
    306: '中雨',
    307: '大雨',
    308: '极端降雨',
    309: '毛毛雨',
    310: '暴雨',
    311: '大暴雨',
    312: '特大暴雨',
    313: '冻雨',
    314: '小到中雨',
    315: '中到大雨',
    316: '大到暴雨',
    317: '暴雨到大暴雨',
    318: '大暴雨到特大暴雨',
    399: '雨',
    350: '阵雨',
    351: '强阵雨',
    400: '小雪',
    401: '中雪',
    402: '大雪',
    403: '暴雪',
    404: '雨夹雪',
    405: '雨雪天气',
    406: '阵雨夹雪',
    407: '阵雪',
    408: '小到中雪',
    409: '中到大雪',
    410: '大到暴雪',
    456: '阵雨夹雪',
    457: '阵雪',
    499: '雪',
    500: '薄雾',
    501: '雾',
    502: '霾',
    503: '扬沙',
    504: '浮尘',
    507: '沙尘暴',
    508: '强沙尘暴',
    509: '浓雾',
    510: '强浓雾',
    511: '中度霾',
    512: '重度霾',
    513: '严重霾',
    514: '大雾',
    515: '特强浓雾',
    900: '热',
    901: '冷',
    999: '未知',
  };

  /// 根据天气代码获取描述
  ///
  /// [code] 天气代码
  /// 返回对应的天气描述，如果没有找到则返回 '未知'
  static String getDescription(int code) {
    return descriptions[code] ?? '未知';
  }

  /// 中文天气描述到本地化键的映射
  static const Map<String, String> _descriptionToKey = {
    '晴': 'condition_sunny',
    '多云': 'condition_cloudy',
    '少云': 'condition_few_clouds',
    '晴间多云': 'condition_partly_cloudy',
    '阴': 'condition_overcast',
    '阵雨': 'condition_shower',
    '强阵雨': 'condition_heavy_shower',
    '雷阵雨': 'condition_thundershower',
    '强雷阵雨': 'condition_heavy_thundershower',
    '雷阵雨伴有冰雹': 'condition_hail',
    '小雨': 'condition_light_rain',
    '中雨': 'condition_moderate_rain',
    '大雨': 'condition_heavy_rain',
    '极端降雨': 'condition_extreme_rain',
    '毛毛雨': 'condition_drizzle',
    '暴雨': 'condition_storm',
    '大暴雨': 'condition_heavy_storm',
    '特大暴雨': 'condition_extreme_storm',
    '冻雨': 'condition_freezing_rain',
    '小雪': 'condition_light_snow',
    '中雪': 'condition_moderate_snow',
    '大雪': 'condition_heavy_snow',
    '暴雪': 'condition_blizzard',
    '雨夹雪': 'condition_sleet',
    '薄雾': 'condition_mist',
    '雾': 'condition_fog',
    '霾': 'condition_haze',
    '扬沙': 'condition_dust',
    '浮尘': 'condition_sand',
    '沙尘暴': 'condition_sandstorm',
    '强沙尘暴': 'condition_heavy_sandstorm',
    '浓雾': 'condition_dense_fog',
    '热': 'condition_heat',
    '冷': 'condition_cold',
    '未知': 'condition_unknown',
    '雨': 'condition_light_rain',
    '雪': 'condition_light_snow',
    '小到中雨': 'condition_light_rain',
    '中到大雨': 'condition_moderate_rain',
    '大到暴雨': 'condition_heavy_rain',
    '暴雨到大暴雨': 'condition_storm',
    '大暴雨到特大暴雨': 'condition_extreme_storm',
    '小到中雪': 'condition_light_snow',
    '中到大雪': 'condition_moderate_snow',
    '大到暴雪': 'condition_heavy_snow',
    '阵雨夹雪': 'condition_sleet',
    '阵雪': 'condition_light_snow',
    '雨雪天气': 'condition_sleet',
    '强浓雾': 'condition_dense_fog',
    '中度霾': 'condition_haze',
    '重度霾': 'condition_haze',
    '严重霾': 'condition_haze',
    '大雾': 'condition_fog',
    '特强浓雾': 'condition_dense_fog',
  };

  /// 获取本地化的天气描述
  ///
  /// [context] BuildContext
  /// [chineseDescription] 中文天气描述
  /// 返回本地化的天气描述
  static String getLocalizedDescription(BuildContext context, String chineseDescription) {
    final l10n = AppLocalizations.of(context);
    final key = _descriptionToKey[chineseDescription];
    if (key == null) return chineseDescription;

    switch (key) {
      case 'condition_sunny':
        return l10n.condition_sunny;
      case 'condition_cloudy':
        return l10n.condition_cloudy;
      case 'condition_few_clouds':
        return l10n.condition_few_clouds;
      case 'condition_partly_cloudy':
        return l10n.condition_partly_cloudy;
      case 'condition_overcast':
        return l10n.condition_overcast;
      case 'condition_shower':
        return l10n.condition_shower;
      case 'condition_heavy_shower':
        return l10n.condition_heavy_shower;
      case 'condition_thundershower':
        return l10n.condition_thundershower;
      case 'condition_heavy_thundershower':
        return l10n.condition_heavy_thundershower;
      case 'condition_hail':
        return l10n.condition_hail;
      case 'condition_light_rain':
        return l10n.condition_light_rain;
      case 'condition_moderate_rain':
        return l10n.condition_moderate_rain;
      case 'condition_heavy_rain':
        return l10n.condition_heavy_rain;
      case 'condition_extreme_rain':
        return l10n.condition_extreme_rain;
      case 'condition_drizzle':
        return l10n.condition_drizzle;
      case 'condition_storm':
        return l10n.condition_storm;
      case 'condition_heavy_storm':
        return l10n.condition_heavy_storm;
      case 'condition_extreme_storm':
        return l10n.condition_extreme_storm;
      case 'condition_freezing_rain':
        return l10n.condition_freezing_rain;
      case 'condition_light_snow':
        return l10n.condition_light_snow;
      case 'condition_moderate_snow':
        return l10n.condition_moderate_snow;
      case 'condition_heavy_snow':
        return l10n.condition_heavy_snow;
      case 'condition_blizzard':
        return l10n.condition_blizzard;
      case 'condition_sleet':
        return l10n.condition_sleet;
      case 'condition_mist':
        return l10n.condition_mist;
      case 'condition_fog':
        return l10n.condition_fog;
      case 'condition_haze':
        return l10n.condition_haze;
      case 'condition_dust':
        return l10n.condition_dust;
      case 'condition_sand':
        return l10n.condition_sand;
      case 'condition_sandstorm':
        return l10n.condition_sandstorm;
      case 'condition_heavy_sandstorm':
        return l10n.condition_heavy_sandstorm;
      case 'condition_dense_fog':
        return l10n.condition_dense_fog;
      case 'condition_heat':
        return l10n.condition_heat;
      case 'condition_cold':
        return l10n.condition_cold;
      default:
        return chineseDescription;
    }
  }

  /// 中文风向到本地化键的映射
  static const Map<String, String> _windDirToKey = {
    '北': 'wind_dir_n',
    '北风': 'wind_dir_n',
    '东北': 'wind_dir_ne',
    '东北风': 'wind_dir_ne',
    '东': 'wind_dir_e',
    '东风': 'wind_dir_e',
    '东南': 'wind_dir_se',
    '东南风': 'wind_dir_se',
    '南': 'wind_dir_s',
    '南风': 'wind_dir_s',
    '西南': 'wind_dir_sw',
    '西南风': 'wind_dir_sw',
    '西': 'wind_dir_w',
    '西风': 'wind_dir_w',
    '西北': 'wind_dir_nw',
    '西北风': 'wind_dir_nw',
    '静风': 'wind_dir_calm',
    '风向不定': 'wind_dir_variable',
    'N': 'wind_dir_n',
    'NE': 'wind_dir_ne',
    'E': 'wind_dir_e',
    'SE': 'wind_dir_se',
    'S': 'wind_dir_s',
    'SW': 'wind_dir_sw',
    'W': 'wind_dir_w',
    'NW': 'wind_dir_nw',
    'Calm': 'wind_dir_calm',
    'Variable': 'wind_dir_variable',
  };

  /// 获取本地化的风向描述
  ///
  /// [context] BuildContext
  /// [chineseWindDir] 中文风向描述
  /// 返回本地化的风向描述
  static String getLocalizedWindDirection(BuildContext context, String chineseWindDir) {
    final l10n = AppLocalizations.of(context);
    final key = _windDirToKey[chineseWindDir];
    if (key == null) return chineseWindDir;

    switch (key) {
      case 'wind_dir_n':
        return l10n.wind_dir_n;
      case 'wind_dir_ne':
        return l10n.wind_dir_ne;
      case 'wind_dir_e':
        return l10n.wind_dir_e;
      case 'wind_dir_se':
        return l10n.wind_dir_se;
      case 'wind_dir_s':
        return l10n.wind_dir_s;
      case 'wind_dir_sw':
        return l10n.wind_dir_sw;
      case 'wind_dir_w':
        return l10n.wind_dir_w;
      case 'wind_dir_nw':
        return l10n.wind_dir_nw;
      case 'wind_dir_calm':
        return l10n.wind_dir_calm;
      case 'wind_dir_variable':
        return l10n.wind_dir_variable;
      default:
        return chineseWindDir;
    }
  }

  /// 根据天气代码获取对应的图标
  /// 
  /// [code] 天气代码
  /// [isNight] 是否为夜间
  /// 返回对应的天气图标
  static IconData getWeatherIcon(int code, {bool isNight = false}) {
    if (code == 100 || code == 150) {
      return isNight ? Icons.nightlight_round : Icons.wb_sunny;
    } else if (code == 101 ||
        code == 102 ||
        code == 103 ||
        code == 151 ||
        code == 152 ||
        code == 153) {
      return isNight ? Icons.nights_stay : Icons.wb_cloudy;
    } else if (code == 104) {
      return Icons.cloud;
    } else if ((code >= 300 && code <= 399) || code == 350 || code == 351) {
      return Icons.water_drop;
    } else if ((code >= 400 && code <= 499) || code == 456 || code == 457) {
      return Icons.ac_unit;
    } else if (code >= 500 && code <= 515) {
      return Icons.blur_on;
    } else if (code == 900) {
      return Icons.thermostat;
    } else if (code == 901) {
      return Icons.severe_cold;
    }
    return Icons.cloud_queue;
  }

  /// 温度单位转换
  /// 
  /// [celsiusTemp] 摄氏度温度字符串
  /// [toFahrenheit] 是否转换为华氏度
  /// 返回转换后的温度字符串
  static String convertTemperature(
    String celsiusTemp, {
    bool toFahrenheit = false,
  }) {
    final celsius = double.tryParse(celsiusTemp);
    if (celsius == null) return celsiusTemp;

    if (toFahrenheit) {
      final fahrenheit = (celsius * 9 / 5) + 32;
      return fahrenheit.round().toString();
    }
    return celsius.round().toString();
  }

  /// 风速单位转换
  /// 
  /// [kmhSpeed] 公里/小时风速字符串
  /// [unit] 目标单位 (ms, kmph, mph)
  /// 返回转换后的风速字符串
  static String convertWindSpeed(
    String kmhSpeed, {
    String unit = 'kmph',
  }) {
    final speed = double.tryParse(kmhSpeed);
    if (speed == null) return kmhSpeed;

    switch (unit) {
      case 'ms':
        // km/h to m/s: divide by 3.6
        return (speed / 3.6).toStringAsFixed(1);
      case 'mph':
        // km/h to mph: multiply by 0.621371
        return (speed * 0.621371).toStringAsFixed(1);
      case 'kmph':
      default:
        return speed.round().toString();
    }
  }

  /// 能见度单位转换
  /// 
  /// [kmVis] 公里能见度字符串
  /// [useImperial] 是否使用英制单位 (英里)
  /// 返回转换后的能见度字符串
  static String convertVisibility(
    String kmVis, {
    bool useImperial = false,
  }) {
    final vis = double.tryParse(kmVis);
    if (vis == null) return kmVis;

    if (useImperial) {
      // km to miles: multiply by 0.621371
      return (vis * 0.621371).toStringAsFixed(1);
    }
    return vis.round().toString();
  }
}
