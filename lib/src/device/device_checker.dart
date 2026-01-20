// lib/src/device/device_checker.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'device_report.dart';
import 'oem.dart';

class DeviceChecker {
  static Future<DeviceReport> check() async {
    if (!Platform.isAndroid) {
      return const DeviceReport(
        manufacturer: 'unknown',
        model: 'unknown',
        sdkInt: -1,
        status: GuardStatus.warn,
        issues: ['Device checks currently support Android only.'],
        fixActions: [],
      );
    }

    final info = await DeviceInfoPlugin().androidInfo;
    final manufacturer = info.manufacturer;
    final model = info.model;
    final sdkInt = info.version.sdkInt;

    final issues = <String>[];
    final fixes = <FixAction>[];

    // We’ll mark battery-optimization as something to check/fix.
    // (If you later add a native "isIgnoringBatteryOptimizations" method,
    // you can conditionally add these actions only when needed.)
    issues.add('Battery optimization may block background tasks.');
    fixes.addAll(const [
      FixAction(
        title: 'Disable Battery Optimization (Recommended)',
        description:
            'Opens the prompt to allow this app to be excluded from battery optimizations.',
        actionId: 'open_ignore_battery_optimizations',
      ),
      FixAction(
        title: 'Battery Optimization Settings (Fallback)',
        description:
            'Opens the general battery optimization settings list (use if the prompt fails).',
        actionId: 'open_battery_optimization_settings',
      ),
    ]);

    final oem = detectOem(manufacturer);
    if (oem != Oem.google && oem != Oem.unknown) {
      issues.add('OEM background restrictions detected (${oem.name}).');
      fixes.add(const FixAction(
        title: 'Check OEM Background Settings',
        description:
            'Some phones require extra steps (Auto-start / Background activity).',
        actionId: 'open_oem_background_settings',
      ));
    }

    final status = issues.isEmpty ? GuardStatus.ok : GuardStatus.warn;

    return DeviceReport(
      manufacturer: manufacturer,
      model: model,
      sdkInt: sdkInt,
      status: status,
      issues: issues,
      fixActions: fixes,
    );
  }
}

// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'device_report.dart';
// import 'oem.dart';

// class DeviceChecker {
//   static Future<DeviceReport> check() async {
//     if (!Platform.isAndroid) {
//       return const DeviceReport(
//         manufacturer: 'unknown',
//         model: 'unknown',
//         sdkInt: -1,
//         status: GuardStatus.warn,
//         issues: ['Device checks currently support Android only.'],
//         fixActions: [],
//       );
//     }

//     final info = await DeviceInfoPlugin().androidInfo;
//     final manufacturer = info.manufacturer;
//     final model = info.model;
//     final sdkInt = info.version.sdkInt;

//     final issues = <String>[];
//     final fixes = <FixAction>[];

//     // Battery optimization exemption (best-effort via permission_handler)
//     final ignoreBatteryOpt = await Permission.ignoreBatteryOptimizations.status;
//     final isExempt = ignoreBatteryOpt.isGranted;

//     if (!isExempt) {
//       issues.add('Battery optimization is ON. This can stop background tasks.');
//       fixes.add(const FixAction(
//         title: 'Disable Battery Optimization',
//         description: 'Allow the app to run reliably in the background.',
//         actionId: 'open_ignore_battery_optimizations',
//       ));
//     }

//     final oem = detectOem(manufacturer);
//     if (oem != Oem.google && oem != Oem.unknown) {
//       issues.add('OEM background restrictions detected (${oem.name}).');
//       fixes.add(const FixAction(
//         title: 'Check OEM Background Settings',
//         description: 'Some phones require extra steps (Auto-start / Background activity).',
//         actionId: 'open_oem_background_settings',
//       ));
//     }

//     final status = issues.isEmpty ? GuardStatus.ok : GuardStatus.warn;

//     return DeviceReport(
//       manufacturer: manufacturer,
//       model: model,
//       sdkInt: sdkInt,
//       status: status,
//       issues: issues,
//       fixActions: fixes,
//     );
//   }
// }
