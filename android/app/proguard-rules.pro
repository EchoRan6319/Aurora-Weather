# Flutter ProGuard rules - 平衡版本（混淆+轻度压缩）

# Flutter wrapper - 保留核心类
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.embedding.** { *; }

# 保留插件方法调用处理器
-keepclassmembers class * implements io.flutter.plugin.common.MethodChannel$MethodCallHandler {
    public void onMethodCall(io.flutter.plugin.common.MethodCall, io.flutter.plugin.common.MethodChannel$Result);
}

# 保留 Dart VM 类
-keep class com.dartlang.vm.** { *; }

# 保留所有 Flutter 插件类（防止被混淆）
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * implements io.flutter.plugin.common.ActivityAware { *; }
-keep class * implements io.flutter.plugin.common.ServiceAware { *; }

# 保留所有生成的类
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# 保留所有 MethodChannel 相关类
-keep class io.flutter.plugin.common.MethodChannel { *; }
-keep class io.flutter.plugin.common.MethodCall { *; }
-keep class io.flutter.plugin.common.MethodChannel$Result { *; }

# 保留枚举类
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 保留 native 方法
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保留 Parcelable 实现类
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# 保留 Serializable 实现类
-keep class * implements java.io.Serializable { *; }

# 保留 R 类
-keep class **.R$* { *; }
-keep class **.R { *; }

# 保留 BuildConfig
-keep class **.BuildConfig { *; }

# 保留所有 Activity、Application
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application

# 保留注解
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions,InnerClasses,Synthetic
-keepattributes SourceFile,LineNumberTable
-keepattributes EnclosingMethod

# 保留 Kotlin 元数据
-keep class kotlin.Metadata { *; }
-keepattributes RuntimeVisibleAnnotations

# 忽略 Google Play Core 缺失类警告
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.tasks.**

# 优化配置 - 启用混淆和轻度压缩，但禁用激进优化
# 混淆类名、方法名、字段名
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# 禁用可能导致崩溃的优化
-optimizations !code/allocation/variable,!code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*

# 保留行号信息（便于调试崩溃）
-keepattributes SourceFile,LineNumberTable

# 删除日志代码
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}
