BackgroundGuard

BackgroundGuard is a Flutter plugin that helps you detect, diagnose, and recover from background task failures on Android, especially on OEM devices like Samsung, Xiaomi, Oppo, where background execution is aggressively restricted.

It helps you stop guessing why background tasks fail and instead guide users to fix system restrictions and verify the fix actually worked.

🚨 The Problem

On many Android devices, background tasks fail due to:

Battery optimization

Power saving modes

OEM background restrictions

This results in:

Broken sync or notifications

User complaints

Developers guessing instead of knowing

Most background libraries only schedule tasks — they don’t explain failures or help users fix them.

✅ What BackgroundGuard Does

BackgroundGuard adds diagnostics + recovery + verification on top of background execution.

It helps answer:

“Why is my background task not running on this device, and how can the user fix it?”

⚡ Quick Start
await BackgroundGuard.init();

Run a background heartbeat
await BackgroundGuard.runHeartbeatNow();

Read background health
final health = await BackgroundGuard.debugReadHealth();

Diagnose device restrictions
final report = await BackgroundGuard.checkDevice();

Open a fix action
await BackgroundGuard.openFix(report.fixActions.first);

🔁 Verify the Fix

After the user changes system settings, run:

await BackgroundGuard.runHeartbeatNow();


If lastSuccess updates, background execution is working again.

📱 Samsung Devices (Important)

On modern Samsung devices, settings may open to Power Saving or App Info.
This is expected due to OS restrictions.

Users typically need to:

Add the app to Never sleeping apps

Set battery usage to Unrestricted

🚫 What This Plugin Does NOT Do

Does not bypass Android restrictions

Does not guarantee 100% background execution

Does not highlight your app inside system Settings

Instead, it follows:
Detect → Guide → Verify

🛠 Platform Support

✅ Android

❌ iOS (planned)

📄 License

MIT