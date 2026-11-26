package com.draevix.launchdesk

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "launchdesk/mobile")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "listApps" -> {
                            // Only apps advertising a launcher activity; no broad
                            // QUERY_ALL_PACKAGES permission is requested.
                            val intent = Intent(Intent.ACTION_MAIN)
                                .addCategory(Intent.CATEGORY_LAUNCHER)
                            val apps = packageManager.queryIntentActivities(intent, 0)
                                .filter { it.activityInfo.packageName != packageName }
                                .map {
                                    mapOf(
                                        "name" to it.loadLabel(packageManager).toString(),
                                        "package" to it.activityInfo.packageName
                                    )
                                }
                                .distinctBy { it["package"] }
                                .sortedBy { it["name"]?.lowercase() }
                            result.success(apps)
                        }
                        "launchPackage" -> {
                            val target = call.argument<String>("package")
                            if (target.isNullOrBlank()) {
                                result.success(false)
                            } else {
                                val launchIntent = packageManager.getLaunchIntentForPackage(target)
                                if (launchIntent == null) {
                                    result.success(false)
                                } else {
                                    startActivity(launchIntent)
                                    result.success(true)
                                }
                            }
                        }
                        "openSettings" -> {
                            val intent = when (call.argument<String>("destination")) {
                                "battery" -> Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS)
                                "wifi" -> Intent(Settings.ACTION_WIFI_SETTINGS)
                                "app" -> Intent(
                                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                    Uri.parse("package:" + packageName)
                                )
                                else -> Intent(Settings.ACTION_SETTINGS)
                            }
                            startActivity(intent)
                            result.success(true)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("ANDROID_UNAVAILABLE", e.message, null)
                }
            }
    }
}
