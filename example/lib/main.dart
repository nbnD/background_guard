import 'package:flutter/material.dart';
import 'package:background_guard/background_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundGuard.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, Object?> _health = const {};
  DeviceReport? _report;
  String? _lastFixResult;

  Future<void> _runNow() async {
    await BackgroundGuard.runHeartbeatNow();
    await Future.delayed(const Duration(seconds: 2));
    await _readHealth();
  }

  Future<void> _schedulePeriodic() async {
    await BackgroundGuard.scheduleHeartbeat(periodicTimeInMinutes: 3);
  }

  Future<void> _readHealth() async {
    final h = await BackgroundGuard.debugReadHealth();
    setState(() => _health = h);
  }

  Future<void> _checkDevice() async {
    final r = await BackgroundGuard.checkDevice();
    setState(() {
      _report = r;
      _lastFixResult = null;
    });
  }

  Future<void> _openFix(FixAction action) async {
    setState(() => _lastFixResult = null);
    final ok = await BackgroundGuard.openFix(action);
    setState(() {
      _lastFixResult = ok
          ? 'Opened: ${action.title}'
          : 'Could not open: ${action.title} (OEM action may be coming next)';
    });
  }

  String _fmtMillis(Object? millis) {
    if (millis is! int) return '—';
    return DateTime.fromMillisecondsSinceEpoch(millis).toLocal().toString();
  }

  @override
  Widget build(BuildContext context) {
    final lastAttempt = _health['lastAttempt'];
    final lastSuccess = _health['lastSuccess'];
    final lastError = _health['lastError'];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('BackgroundGuard Demo')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ----- Background heartbeat demo -----
            const Text(
              'Background Execution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _runNow,
              child: const Text('Run Heartbeat Now'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _schedulePeriodic,
              child: const Text('Schedule Periodic Heartbeat '),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _readHealth,
              child: const Text('Read Health'),
            ),
            const SizedBox(height: 12),
            _kv('Last Attempt', _fmtMillis(lastAttempt)),
            _kv('Last Success', _fmtMillis(lastSuccess)),
            _kv('Last Error', (lastError as String?) ?? '—'),
            const Divider(height: 32),

            // ----- Device report demo -----
            const Text(
              'Device Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _checkDevice,
              child: const Text('Check Device'),
            ),
            const SizedBox(height: 12),

            if (_report == null)
              const Text('Press “Check Device” to generate a report.')
            else ...[
              _kv('Manufacturer', _report!.manufacturer),
              _kv('Model', _report!.model),
              _kv('Android SDK', _report!.sdkInt.toString()),
              _kv('Status', _report!.status.name),
              const SizedBox(height: 12),

              const Text(
                'Issues',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              if (_report!.issues.isEmpty)
                const Text('No issues detected.')
              else
                ..._report!.issues.map((e) => _bullet(e)),

              const SizedBox(height: 16),
              const Text(
                'Fix Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              if (_report!.fixActions.isEmpty)
                const Text('No fix actions available.')
              else
                ..._report!.fixActions.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      onPressed: () => _openFix(a),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(a.title),
                      ),
                    ),
                  ),
                ),

              if (_lastFixResult != null) ...[
                const SizedBox(height: 8),
                Text(
                  _lastFixResult!,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$k:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
