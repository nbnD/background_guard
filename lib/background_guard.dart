
import 'background_guard_platform_interface.dart';
import 'src/scheduler/workmanager_adapter.dart';
import 'src/health/health_store.dart';
import 'src/device/device_checker.dart';
import 'src/device/device_report.dart';
import 'src/actions/settings_opener.dart';
export 'src/device/device_report.dart';

class BackgroundGuard {
  Future<String?> getPlatformVersion() {
    return BackgroundGuardPlatform.instance.getPlatformVersion();
  }
  static Future<void> init({bool debug = false}) async {
    await WorkmanagerAdapter.initialize();
  }

  static Future<void> scheduleHeartbeat({required int periodicTimeInMinutes}) async {
    await WorkmanagerAdapter.scheduleHeartbeatPeriodic(periodicTimeInMinutes);
  }

  static Future<void> runHeartbeatNow() async {
    await WorkmanagerAdapter.runHeartbeatNow();
  }

  static Future<Map<String, Object?>> debugReadHealth() async {
    return HealthStore.readRaw();
  }
  static Future<DeviceReport> checkDevice() => DeviceChecker.check();

  static Future<bool> openFix(FixAction action) => SettingsOpener.open(action.actionId);

}
