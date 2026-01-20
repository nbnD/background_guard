import 'dart:io';

import 'package:flutter/services.dart';

class SettingsOpener {
  static const _channel = MethodChannel('background_guard');

  static Future<bool> open(String actionId) async {
    if (!Platform.isAndroid) return false;

    try {
      switch (actionId) {
        case 'open_ignore_battery_optimizations':
          // best: prompts exemption for your app
          return (await _channel.invokeMethod<bool>(
                'openIgnoreBatteryOptimizations',
              )) ??
              false;

        case 'open_battery_optimization_settings':
          // fallback: general list screen
          return (await _channel.invokeMethod<bool>(
                'openBatteryOptimizationSettings',
              )) ??
              false;
              
        case 'open_oem_background_settings':
          return (await _channel.invokeMethod<bool>('openOemBackgroundSettings')) ?? false;

        default:
          return false;
      }
    } catch (_) {
      return false;
    }
  }
}
