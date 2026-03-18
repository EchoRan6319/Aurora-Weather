package com.echoran.pureweather

import android.app.WallpaperManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val channelName = "com.echoran.pureweather/wallpaper"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "getWallpaperPrimaryColor" -> {
                    val color = getWallpaperPrimaryColor()
                    if (color != null) {
                        result.success(color)
                    } else {
                        result.error("UNAVAILABLE", "Wallpaper colors not available.", null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun getWallpaperPrimaryColor(): Int? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            val wallpaperManager = WallpaperManager.getInstance(this)
            val colors = wallpaperManager.getWallpaperColors(WallpaperManager.FLAG_SYSTEM)
            if (colors != null) {
                // Return ARGB format
                return colors.primaryColor?.toArgb()
            }
        }
        return null
    }
}
