import 'package:flutter_test/flutter_test.dart';
import 'package:background_guard/background_guard.dart';
import 'package:background_guard/background_guard_platform_interface.dart';
import 'package:background_guard/background_guard_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBackgroundGuardPlatform
    with MockPlatformInterfaceMixin
    implements BackgroundGuardPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BackgroundGuardPlatform initialPlatform = BackgroundGuardPlatform.instance;

  test('$MethodChannelBackgroundGuard is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBackgroundGuard>());
  });

  test('getPlatformVersion', () async {
    BackgroundGuard backgroundGuardPlugin = BackgroundGuard();
    MockBackgroundGuardPlatform fakePlatform = MockBackgroundGuardPlatform();
    BackgroundGuardPlatform.instance = fakePlatform;

    expect(await backgroundGuardPlugin.getPlatformVersion(), '42');
  });
}
