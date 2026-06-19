import 'dart:io';

class DeviceInfoHelper {
  static String _deviceModel = Platform.localHostname;
  static String _osVersion = Platform.operatingSystemVersion;

  static String get deviceModel => _deviceModel;
  static String get osVersion => _osVersion;

  static Future<void> init() async {
    try {
      _deviceModel = Platform.localHostname;
      _osVersion = Platform.operatingSystemVersion;
    } catch (_) {}
  }
}
