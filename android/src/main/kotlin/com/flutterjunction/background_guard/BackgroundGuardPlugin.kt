package com.flutterjunction.background_guard

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

import android.content.ComponentName
import android.util.Log

class BackgroundGuardPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var appContext: Context? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    appContext = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "background_guard")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }

      "openIgnoreBatteryOptimizations" -> {
        result.success(openIgnoreBatteryOptimizations())
      }

      "openBatteryOptimizationSettings" -> {
        result.success(openBatteryOptimizationSettings())
      }

      "openOemBackgroundSettings" -> {
        result.success(openOemBackgroundSettings())
      }

      else -> result.notImplemented()
    }
  }

  private fun openIgnoreBatteryOptimizations(): Boolean {
    val ctx = activity ?: appContext ?: return false
    return try {
      val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
        data = Uri.parse("package:${ctx.packageName}")
      }
      if (activity == null) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      ctx.startActivity(intent)
      true
    } catch (e: Exception) {
      false
    }
  }

  private fun openBatteryOptimizationSettings(): Boolean {
    val ctx = activity ?: appContext ?: return false
    return try {
      val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
      if (activity == null) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      ctx.startActivity(intent)
      true
    } catch (e: Exception) {
      false
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    appContext = null
  }

  // ActivityAware
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }


    private fun openOemBackgroundSettings(): Boolean {
  val ctx = activity ?: appContext ?: return false
  val manufacturer = android.os.Build.MANUFACTURER.lowercase()

  // Try OEM-specific settings screens
  val tried = when {
    manufacturer.contains("samsung") -> openSamsung(ctx)
    manufacturer.contains("xiaomi") || manufacturer.contains("redmi") || manufacturer.contains("poco") -> openXiaomi(ctx)
    manufacturer.contains("oppo") -> openOppo(ctx)
    manufacturer.contains("vivo") -> openVivo(ctx)
    manufacturer.contains("huawei") || manufacturer.contains("honor") -> openHuawei(ctx)
    manufacturer.contains("oneplus") -> openOnePlus(ctx)
    else -> false
  }

  // Fallback: app details screen (always works)
  return tried || openAppDetails(ctx)
}

private fun openAppDetails(ctx: Context): Boolean {
  return try {
    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
      data = Uri.parse("package:${ctx.packageName}")
      addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    }
    ctx.startActivity(intent)
    true
  } catch (e: Exception) {
    false
  }
}

private fun startActivitySafely(ctx: Context, intent: Intent): Boolean {
  return try {
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    ctx.startActivity(intent)
    true
  } catch (e: Exception) {
    Log.w("BackgroundGuard", "Intent failed: $intent", e)
    false
  }
}

private fun openSamsung(ctx: Context): Boolean {
  // Samsung battery / background is spread out; best fallback is App Details.
  // Try known screen (may vary by OS):
  val intent = Intent().apply {
    component = ComponentName(
      "com.samsung.android.lool",
      "com.samsung.android.sm.ui.battery.BatteryActivity"
    )
  }
  return startActivitySafely(ctx, intent)
}


/*
private fun openSamsung(ctx: Context): Boolean {
  val intents = listOf(
    // Device Care / Battery (varies by One UI version)
    Intent().setComponent(ComponentName(
      "com.samsung.android.lool",
      "com.samsung.android.sm.ui.battery.BatteryActivity"
    )),
    Intent().setComponent(ComponentName(
      "com.samsung.android.lool",
      "com.samsung.android.sm.ui.battery.BatteryUsageActivity"
    )),
    Intent().setComponent(ComponentName(
      "com.samsung.android.lool",
      "com.samsung.android.sm.ui.MainActivity"
    )),

    // Generic Android screens that usually exist
    Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS),
    Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS)
  )

  for (i in intents) {
    if (startActivitySafely(ctx, i)) return true
  }
  return false
}

*/

/* private fun openSamsung(ctx: Context): Boolean {
  val intents = listOf(
    // Device care battery screen (varies by version)
    Intent().setComponent(ComponentName(
      "com.samsung.android.lool",
      "com.samsung.android.sm.ui.battery.BatteryActivity"
    )),
    // Battery usage
    Intent().setComponent(ComponentName(
      "com.samsung.android.lool",
      "com.samsung.android.sm.ui.battery.BatteryUsageActivity"
    )),
    // Device care main
    Intent().setComponent(ComponentName(
      "com.samsung.android.lool",
      "com.samsung.android.sm.ui.MainActivity"
    )),
    // Generic battery saver settings as fallback before App Info
    Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS)
  )

  for (i in intents) {
    if (startActivitySafely(ctx, i)) return true
  }
  return false
}

*/

private fun openXiaomi(ctx: Context): Boolean {
  // MIUI: Auto-start / battery saver screens vary a lot.
  val intents = listOf(
    Intent().setComponent(ComponentName(
      "com.miui.securitycenter",
      "com.miui.permcenter.autostart.AutoStartManagementActivity"
    )),
    Intent("miui.intent.action.OP_AUTO_START").addCategory(Intent.CATEGORY_DEFAULT),
    Intent().setComponent(ComponentName(
      "com.miui.powerkeeper",
      "com.miui.powerkeeper.ui.HiddenAppsConfigActivity"
    )).putExtra("package_name", ctx.packageName)
      .putExtra("package_label", ctx.applicationInfo.loadLabel(ctx.packageManager).toString())
  )

  for (i in intents) {
    if (startActivitySafely(ctx, i)) return true
  }
  return false
}

private fun openOppo(ctx: Context): Boolean {
  val intents = listOf(
    Intent().setComponent(ComponentName(
      "com.coloros.safecenter",
      "com.coloros.safecenter.permission.startup.StartupAppListActivity"
    )),
    Intent().setComponent(ComponentName(
      "com.oppo.safe",
      "com.oppo.safe.permission.startup.StartupAppListActivity"
    )),
    Intent().setComponent(ComponentName(
      "com.coloros.oppoguardelf",
      "com.coloros.powermanager.fuelgaue.PowerUsageModelActivity"
    ))
  )

  for (i in intents) {
    if (startActivitySafely(ctx, i)) return true
  }
  return false
}

private fun openVivo(ctx: Context): Boolean {
  val intents = listOf(
    Intent().setComponent(ComponentName(
      "com.vivo.permissionmanager",
      "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"
    )),
    Intent().setComponent(ComponentName(
      "com.iqoo.secure",
      "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"
    ))
  )

  for (i in intents) {
    if (startActivitySafely(ctx, i)) return true
  }
  return false
}

private fun openHuawei(ctx: Context): Boolean {
  val intents = listOf(
    Intent().setComponent(ComponentName(
      "com.huawei.systemmanager",
      "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
    )),
    Intent().setComponent(ComponentName(
      "com.huawei.systemmanager",
      "com.huawei.systemmanager.optimize.process.ProtectActivity"
    ))
  )

  for (i in intents) {
    if (startActivitySafely(ctx, i)) return true
  }
  return false
}

private fun openOnePlus(ctx: Context): Boolean {
  // OnePlus often routes to battery optimization or app details; try a known settings page
  val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
  return startActivitySafely(ctx, intent)
}
}
