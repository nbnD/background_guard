import 'package:workmanager/workmanager.dart';
import '../health/health_store.dart';

const String kHeartbeatTask = 'bg_heartbeat';
const String kHeartbeatOneOffTask = 'bg_heartbeat_oneoff';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await HealthStore.recordAttempt();
    try {
      await HealthStore.recordSuccess();
      return true;
    } catch (e) {
      await HealthStore.recordError(e.toString());
      return false;
    }
  });
}

class WorkmanagerAdapter {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> scheduleHeartbeatPeriodic(
    int periodicTimeInMinutes,
  ) async {
    await Workmanager().registerPeriodicTask(
      'bg_heartbeat_periodic_unique',
      kHeartbeatTask,
      frequency: Duration(minutes: periodicTimeInMinutes),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  static Future<void> runHeartbeatNow() async {
    await Workmanager().registerOneOffTask(
      'bg_heartbeat_oneoff_unique',
      kHeartbeatOneOffTask,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }
}
