import Flutter
import UIKit
import BackgroundTasks

public class BackgroundGuardPlugin: NSObject, FlutterPlugin {
  private static let logKey = "bg_guard_ios_logs"
  private static let taskId = "com.flutterjunction.background_guard.probe.refresh"
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "background_guard", binaryMessenger: registrar.messenger())
    let instance = BackgroundGuardPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    // Start passive logging ASAP
    instance.startLifecycleLogging()

    // Register BGTask (best-effort)
    instance.registerBGTask()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)

    case "ios_startProbe":
      startLifecycleLogging()
      registerBGTask()
      appendLog("ios_startProbe called")
      result(true)

    case "ios_exportLogs":
      result(exportLogs())

    case "ios_scheduleRefresh":
      let ok = scheduleAppRefresh()
      result(ok)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
  private func appendLog(_ message: String) {
    let ts = ISO8601DateFormatter().string(from: Date())
    let line = "\(ts) | \(message)"

    var logs = UserDefaults.standard.stringArray(forKey: Self.logKey) ?? []
    logs.append(line)

    // Keep last 500 lines to avoid growth
    if logs.count > 500 {
      logs = Array(logs.suffix(500))
    }

    UserDefaults.standard.set(logs, forKey: Self.logKey)
  }

  private func exportLogs() -> String {
    let logs = UserDefaults.standard.stringArray(forKey: Self.logKey) ?? []
    return logs.joined(separator: "\n")
  }

  // MARK: - App lifecycle logging

  private var didStartLifecycle = false

  private func startLifecycleLogging() {
    guard !didStartLifecycle else { return }
    didStartLifecycle = true

    appendLog("Lifecycle logging started")

    NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: .main) { _ in
      self.appendLog("app_didFinishLaunching")
    }
    NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
      self.appendLog("app_didEnterBackground")
    }
    NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
      self.appendLog("app_willEnterForeground")
    }
    NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
      self.appendLog("app_didBecomeActive")
    }
    NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
      self.appendLog("app_willResignActive")
    }
    NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
      self.appendLog("app_willTerminate")
    }
  }

  // MARK: - BGTaskScheduler (best-effort)

  private var didRegisterTask = false

  private func registerBGTask() {
    guard !didRegisterTask else { return }
    didRegisterTask = true

    // Must be registered early in app lifecycle
    let ok = BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskId, using: nil) { task in
      self.appendLog("bg_task_fired: \(Self.taskId)")
      self.handleAppRefresh(task: task as! BGAppRefreshTask)
    }

    appendLog(ok ? "bg_task_registered: \(Self.taskId)" : "bg_task_register_failed: \(Self.taskId)")
  }

  private func scheduleAppRefresh() -> Bool {
    let request = BGAppRefreshTaskRequest(identifier: Self.taskId)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 60) // earliest 1 min (OS decides)

    do {
      try BGTaskScheduler.shared.submit(request)
      appendLog("bg_task_scheduled: \(Self.taskId)")
      return true
    } catch {
     let ns = error as NSError
      appendLog("bg_task_schedule_failed: domain=\(ns.domain) code=\(ns.code) msg=\(ns.localizedDescription)")
      return false
    }
  }

  private func handleAppRefresh(task: BGAppRefreshTask) {
    // Always call setTaskCompleted
    task.expirationHandler = {
      self.appendLog("bg_task_expired: \(Self.taskId)")
    }

    // Barebones: just log and complete
    appendLog("bg_task_work_start: \(Self.taskId)")
    task.setTaskCompleted(success: true)
    appendLog("bg_task_work_done: \(Self.taskId)")
  }
}
