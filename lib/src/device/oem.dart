enum Oem { samsung, xiaomi, oppo, vivo, huawei, oneplus, google, unknown }

Oem detectOem(String? manufacturer) {
  final m = (manufacturer ?? '').toLowerCase().trim();
  if (m.contains('samsung')) return Oem.samsung;
  if (m.contains('xiaomi') || m.contains('redmi') || m.contains('poco')) return Oem.xiaomi;
  if (m.contains('oppo')) return Oem.oppo;
  if (m.contains('vivo')) return Oem.vivo;
  if (m.contains('huawei') || m.contains('honor')) return Oem.huawei;
  if (m.contains('oneplus')) return Oem.oneplus;
  if (m.contains('google')) return Oem.google;
  return Oem.unknown;
}
