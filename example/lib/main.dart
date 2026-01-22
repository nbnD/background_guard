import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:background_guard/background_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initBackgroundGuard();
  runApp(const MyApp());
}

Future<void> _initBackgroundGuard() async {
  if (Platform.isAndroid) {
    // Android-only init (WorkManager etc.)
    await BackgroundGuard.init();
    return;
  }

  if (Platform.isIOS) {
    // Start probe lazily from UI, or optionally start here if you want:
    await IosProbe.start();
    return;
  }

  // Other platforms (web/desktop) - do nothing by design.
  if (kDebugMode) {
    debugPrint('BackgroundGuard: init skipped (unsupported platform).');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ---------------- ANDROID STATE  ----------------

  Map<String, Object?> _health = const {};
  DeviceReport? _report;
  String? _lastFixResult;

  // ---------------- iOS STATE ----------------
  String _iosLogs = '—';
  String? _iosStatus;

  // ---------------- ANDROID ACTIONS (UNCHANGED) ----------------

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

  // ---------------- iOS ACTIONS ----------------

  Future<void> _iosStartProbe() async {
    final ok = await IosProbe.start();
    setState(() {
      _iosStatus = ok
          ? 'Probe started. Export logs to view.'
          : 'Probe start failed.';
    });
  }

  Future<void> _iosScheduleRefresh() async {
    final ok = await IosProbe.scheduleRefresh();
    setState(() {
      _iosStatus = ok
          ? 'Schedule submitted (best-effort by iOS). Export logs.'
          : 'Schedule failed (see exported logs).';
    });
  }

  Future<void> _iosExportLogs() async {
    final logs = await IosProbe.exportLogs();
    setState(() {
      _iosLogs = logs.isEmpty ? 'No logs yet.' : logs;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ If iOS -> show iOS UI
    if (Platform.isIOS) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('BackgroundGuard Demo (iOS)')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'iOS Probe (Barebones)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'iOS does not support Android-style background fixing. '
                'This probe focuses on observability and exporting logs.',
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _iosStartProbe,
                child: const Text('Start iOS Probe'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: _iosScheduleRefresh,
                child: const Text('Schedule BG Refresh (best-effort)'),
              ),
              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: _iosExportLogs,
                child: const Text('Export Logs'),
              ),

              const SizedBox(height: 14),

              if (_iosStatus != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_iosStatus!),
                ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _iosLogs,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Else Android -> keep EXACT same UI

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
