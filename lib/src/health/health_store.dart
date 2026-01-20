import 'package:shared_preferences/shared_preferences.dart';

class HealthStore {
  static const _lastAttemptKey = 'bg_last_attempt';
  static const _lastSuccessKey = 'bg_last_success';
  static const _lastErrorKey = 'bg_last_error';

  static Future<void> recordAttempt() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_lastAttemptKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> recordSuccess() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_lastSuccessKey, DateTime.now().millisecondsSinceEpoch);
    await p.remove(_lastErrorKey);
  }

  static Future<void> recordError(String error) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_lastErrorKey, error);
  }

  static Future<Map<String, Object?>> readRaw() async {
    final p = await SharedPreferences.getInstance();
    return {
      'lastAttempt': p.getInt(_lastAttemptKey),
      'lastSuccess': p.getInt(_lastSuccessKey),
      'lastError': p.getString(_lastErrorKey),
    };
  }
}
