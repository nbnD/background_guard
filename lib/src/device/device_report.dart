enum GuardStatus { ok, warn, critical }

class FixAction {
  final String title;
  final String description;
  final String actionId; // used to decide which settings screen to open

  const FixAction({
    required this.title,
    required this.description,
    required this.actionId,
  });
}

class DeviceReport {
  final String manufacturer;
  final String model;
  final int sdkInt;
  final GuardStatus status;
  final List<String> issues;
  final List<FixAction> fixActions;

  const DeviceReport({
    required this.manufacturer,
    required this.model,
    required this.sdkInt,
    required this.status,
    required this.issues,
    required this.fixActions,
  });
}
