import 'dart:io';

class UserAgentBuilder {
  static String? _cachedUserAgent;

  static Future<String> buildUserAgent() async {
    if (_cachedUserAgent != null) {
      return _cachedUserAgent!;
    }

    try {
      String platformInfo;

      if (Platform.isAndroid) {
        final androidVersion = Platform.operatingSystemVersion;
        platformInfo = 'Android $androidVersion';
        _cachedUserAgent = 'EGoAdmin/1.0 ($platformInfo; Mobile)';
      } else if (Platform.isIOS) {
        final iosVersion = Platform.operatingSystemVersion;
        platformInfo = 'iOS $iosVersion';
        _cachedUserAgent = 'EGoAdmin/1.0 ($platformInfo; Mobile)';
      } else if (Platform.isWindows) {
        final windowsVersion = Platform.operatingSystemVersion;
        platformInfo = 'Windows $windowsVersion';
        _cachedUserAgent = 'EGoAdmin/1.0 ($platformInfo; Desktop)';
      } else if (Platform.isMacOS) {
        final macVersion = Platform.operatingSystemVersion;
        platformInfo = 'macOS $macVersion';
        _cachedUserAgent = 'EGoAdmin/1.0 ($platformInfo; Desktop)';
      } else if (Platform.isLinux) {
        final linuxVersion = Platform.operatingSystemVersion;
        platformInfo = 'Linux $linuxVersion';
        _cachedUserAgent = 'EGoAdmin/1.0 ($platformInfo; Desktop)';
      } else {
        final os = Platform.operatingSystem;
        final osVersion = Platform.operatingSystemVersion;
        platformInfo = '$os $osVersion';
        _cachedUserAgent = 'EGoAdmin/1.0 ($platformInfo)';
      }

      return _cachedUserAgent!;
    } catch (e) {
      final os = Platform.operatingSystem;
      _cachedUserAgent = 'EGoAdmin/1.0 ($os)';
      return _cachedUserAgent!;
    }
  }

  static String getUserAgentSync() {
    if (_cachedUserAgent != null) {
      return _cachedUserAgent!;
    }

    if (Platform.isAndroid) {
      return 'EGoAdmin/1.0 (Android; Mobile)';
    } else if (Platform.isIOS) {
      return 'EGoAdmin/1.0 (iOS; Mobile)';
    } else if (Platform.isWindows) {
      return 'EGoAdmin/1.0 (Windows; Desktop)';
    } else if (Platform.isMacOS) {
      return 'EGoAdmin/1.0 (macOS; Desktop)';
    } else if (Platform.isLinux) {
      return 'EGoAdmin/1.0 (Linux; Desktop)';
    }

    return 'EGoAdmin/1.0';
  }
}
