import 'dart:io';
import 'package:flutter/services.dart';

class IosProbe {
  static const _ch = MethodChannel('background_guard');

  static Future<bool> start() async {
    if (!Platform.isIOS) return false;
    return (await _ch.invokeMethod<bool>('ios_startProbe')) ?? false;
  }

  static Future<bool> scheduleRefresh() async {
    if (!Platform.isIOS) return false;
    return (await _ch.invokeMethod<bool>('ios_scheduleRefresh')) ?? false;
  }

  static Future<String> exportLogs() async {
    if (!Platform.isIOS) return '';
    return (await _ch.invokeMethod<String>('ios_exportLogs')) ?? '';
  }
}
