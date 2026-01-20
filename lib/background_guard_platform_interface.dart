import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'background_guard_method_channel.dart';

abstract class BackgroundGuardPlatform extends PlatformInterface {
  /// Constructs a BackgroundGuardPlatform.
  BackgroundGuardPlatform() : super(token: _token);

  static final Object _token = Object();

  static BackgroundGuardPlatform _instance = MethodChannelBackgroundGuard();

  /// The default instance of [BackgroundGuardPlatform] to use.
  ///
  /// Defaults to [MethodChannelBackgroundGuard].
  static BackgroundGuardPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BackgroundGuardPlatform] when
  /// they register themselves.
  static set instance(BackgroundGuardPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
