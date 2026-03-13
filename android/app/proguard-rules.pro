# Flutter ProGuard rules

# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.common.**  { *; }
-keep class io.flutter.embedding.**  { *; }

# Don't obfuscate Flutter's generated plugin classes
-keep class io.flutter.plugins.**.*Plugin* { *; }

# Keep method names for plugins
-keepclassmembers class * implements io.flutter.plugin.common.MethodChannel$MethodCallHandler {
    public void onMethodCall(io.flutter.plugin.common.MethodCall, io.flutter.plugin.common.MethodChannel$Result);
}

# Keep Dart VM classes
-keep class com.dartlang.vm.** { *; }

# Keep Firebase classes if used
-keep class com.google.firebase.** { *; }

# Keep Google Play Services classes if used
-keep class com.google.android.gms.** { *; }

# Keep AndroidX classes
-keep class androidx.** { *; }

# Keep Kotlin classes
-keep class kotlin.** { *; }

# Keep basic Android classes
-keep class android.** { *; }

# Keep support library classes
-keep class android.support.** { *; }

# Keep okhttp classes
-keep class okhttp3.** { *; }

# Keep retrofit classes
-keep class retrofit2.** { *; }

# Keep gson classes
-keep class com.google.gson.** { *; }

# Keep jackson classes
-keep class com.fasterxml.jackson.** { *; }

# Keep okio classes
-keep class okio.** { *; }

# Keep protobuf classes
-keep class com.google.protobuf.** { *; }

# Keep dagger classes
-keep class dagger.** { *; }

# Keep butterknife classes
-keep class butterknife.** { *; }

# Keep eventbus classes
-keep class org.greenrobot.eventbus.** { *; }

# Keep rxjava classes
-keep class io.reactivex.** { *; }

# Keep glide classes
-keep class com.bumptech.glide.** { *; }

# Keep picasso classes
-keep class com.squareup.picasso.** { *; }

# Keep fresco classes
-keep class com.facebook.fresco.** { *; }

# Keep leakcanary classes
-keep class com.squareup.leakcanary.** { *; }

# Keep timber classes
-keep class timber.log.** { *; }

# Keep crashlytics classes
-keep class com.crashlytics.** { *; }

# Keep fabric classes
-keep class com.crashlytics.** { *; }

# Keep analytics classes
-keep class com.google.analytics.** { *; }

# Keep ads classes
-keep class com.google.android.gms.ads.** { *; }

# Keep in-app billing classes
-keep class com.android.billingclient.** { *; }

# Keep location classes
-keep class com.google.android.gms.location.** { *; }

# Keep maps classes
-keep class com.google.android.gms.maps.** { *; }

# Keep auth classes
-keep class com.google.android.gms.auth.** { *; }

# Keep Google Play Core classes if present
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.tasks.**