import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API configuration.
///
/// Lookup order (high to low priority):
/// 1) --dart-define
/// 2) Process environment variables
/// 3) .env (flutter_dotenv)
class ApiConfig {
  static String get qweatherApiKey {
    const fromDefine = String.fromEnvironment('QWEATHER_API_KEY', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.environment['QWEATHER_API_KEY'] ?? dotenv.env['QWEATHER_API_KEY'] ?? '';
  }

  static String get qweatherBaseUrl {
    const fromDefine = String.fromEnvironment('QWEATHER_BASE_URL', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.environment['QWEATHER_BASE_URL'] ?? dotenv.env['QWEATHER_BASE_URL'] ?? 'https://devapi.qweather.com/v7';
  }

  static String get caiyunApiKey {
    const fromDefine = String.fromEnvironment('CAIYUN_API_KEY', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.environment['CAIYUN_API_KEY'] ?? dotenv.env['CAIYUN_API_KEY'] ?? '';
  }

  static String get caiyunBaseUrl {
    const fromDefine = String.fromEnvironment('CAIYUN_BASE_URL', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.environment['CAIYUN_BASE_URL'] ?? dotenv.env['CAIYUN_BASE_URL'] ?? 'https://api.caiyunapp.com/v2.6';
  }

  static String get amapApiKey {
    const fromDefine = String.fromEnvironment('AMAP_API_KEY', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.environment['AMAP_API_KEY'] ?? dotenv.env['AMAP_API_KEY'] ?? '';
  }

  static String get amapWebKey {
    const fromDefine = String.fromEnvironment('AMAP_WEB_KEY', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.environment['AMAP_WEB_KEY'] ?? dotenv.env['AMAP_WEB_KEY'] ?? '';
  }

  static String get deepseekApiKey {
    const fromDefine = String.fromEnvironment('DEEPSEEK_API_KEY', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.environment['DEEPSEEK_API_KEY'] ?? dotenv.env['DEEPSEEK_API_KEY'] ?? '';
  }

  static String get deepseekBaseUrl {
    const fromDefine = String.fromEnvironment('DEEPSEEK_BASE_URL', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return Platform.environment['DEEPSEEK_BASE_URL'] ?? dotenv.env['DEEPSEEK_BASE_URL'] ?? 'https://api.deepseek.com/v1';
  }

  static bool get isConfigured {
    return qweatherApiKey.isNotEmpty && amapApiKey.isNotEmpty;
  }
}
