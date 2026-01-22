# BackgroundGuard

A Flutter plugin for **background task observability, diagnostics, and recovery** — built for real production issues on **Android** and honest observability on **iOS**.

BackgroundGuard helps answer one critical question:

> **Did my background task actually run — or was it silently blocked by the OS?**

---

## 🚨 The Problem

### Android

On modern Android devices (Samsung, Xiaomi, Oppo, Vivo, etc.), background tasks often **silently fail** due to:

- OEM battery optimizations
- aggressive power-saving policies
- background execution limits
- vendor-specific task killers

Tasks appear scheduled, no errors are thrown, but execution never happens.

---

### iOS

iOS strictly controls background execution:

- no guaranteed execution
- no access to system background settings
- no way to force background behavior

BackgroundGuard does **not** overpromise on iOS.

---

## ✅ What BackgroundGuard Does

### Android (Production-ready)

BackgroundGuard provides a **detect → diagnose → guide → verify** workflow:

- Detects whether background work actually executed
- Tracks last attempt, last success, and last error
- Diagnoses OEM and battery restriction risks
- Guides users to relevant system settings
- Verifies fixes using real execution data

---

### iOS (Observability-only)

On iOS, BackgroundGuard provides a **barebones probe** focused on observability:

- Logs app lifecycle events
- Registers and attempts `BGTaskScheduler` tasks (best-effort)
- Records when background callbacks fire
- Exports logs for diagnostics and sharing

> ⚠️ iOS background execution is OS-controlled and not guaranteed.

---

## ❌ What BackgroundGuard Does NOT Do

- Does not guarantee background execution
- Does not bypass OS restrictions
- Does not use private or undocumented APIs
- Does not risk App Store rejection
- Does not hide platform limitations

---

## 📦 Installation

```bash
flutter pub add background_guard
```

# Usage 
## Android

### 1. Initialize BackgroundGuard:

```bash
 await BackgroundGuard.init();
```
Run or schedule background heartbeat:

```dart
 await BackgroundGuard.runHeartbeatNow();
```

```dart
await BackgroundGuard.scheduleHeartbeat(
  periodicTimeInMinutes: 15,
);
```

### 2. Read background health:

```bash
final health = await BackgroundGuard.debugReadHealth();
```

### 3. Diagnose device restrictions:

```dart
final report = await BackgroundGuard.checkDevice();
```

### 4. Open a suggested fix action:
```dart
await BackgroundGuard.openFix(
  report.fixActions.first,
);
```
## iOS (Probe)

### 1. Start the iOS observability probe:
```dart
await IosProbe.start();
```

### 2. Attempt to schedule a background refresh (best-effort):

```dart
await IosProbe.scheduleRefresh();
```

### 3. Export collected logs:

```dart
final logs = await IosProbe.exportLogs();
```


Scheduling may fail on simulator and is OS-controlled on real devices.



## Testing Notes

   - Android behavior varies heavily by OEM

   - iOS background tasks may not fire immediately (or at all)

   - Simulator behavior ≠ real device behavior (especially on iOS)

   - Real-device logs are the most valuable datapoint.



  

📄 License

MIT