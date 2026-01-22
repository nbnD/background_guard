import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'background_guard_platform_interface.dart';

/// An implementation of [BackgroundGuardPlatform] that uses method channels.
class MethodChannelBackgroundGuard extends BackgroundGuardPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('background_guard');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
