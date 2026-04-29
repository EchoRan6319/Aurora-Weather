import 'dart:io' show Platform;

String envVar(String key) => Platform.environment[key] ?? '';
