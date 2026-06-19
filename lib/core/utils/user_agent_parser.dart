class UserAgentParser {
  static String parseUserAgent(String? userAgent) {
    if (userAgent == null || userAgent.isEmpty) {
      return 'Unknown';
    }

    final ua = userAgent.toLowerCase();

    // StroApp format: "StroApp/1.0 (Android 13; hostname)" or "StroApp/1.0 (iOS 17; hostname)"
    if (ua.contains('stroapp') || ua.contains('flutter')) {
      return _parseStroAppUA(userAgent, ua);
    }

    if (ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod')) {
      return _parseIOSDevice(ua);
    }

    if (ua.contains('android') || _isAndroidDevicePattern(ua)) {
      return _parseAndroidDevice(ua);
    }

    if (ua.contains('windows')) {
      return _parseWindows(ua);
    }

    if (ua.contains('mac os x') || ua.contains('macintosh')) {
      return _parseMacOS(ua);
    }

    if (ua.contains('dart')) {
      return 'Flutter App';
    }

    if (ua.contains('linux')) {
      if (!ua.contains('android') && !ua.contains('mobile')) {
        if (ua.contains('x11') || 
            ua.contains('wayland') || 
            ua.contains('ubuntu') || 
            ua.contains('debian') ||
            ua.contains('firefox') ||
            ua.contains('chrome') && !ua.contains('mobile')) {
          return 'Linux Desktop';
        }
        return 'Linux';
      }
    }

    return _extractBasicInfo(userAgent);
  }

  static String _parseStroAppUA(String raw, String ua) {
    // Try to extract device model from parentheses: (OS version; device_model)
    String device = '';
    final parenMatch = RegExp(r'\([^;]+;\s*([^)]+)\)').firstMatch(ua);
    if (parenMatch != null) {
      device = parenMatch.group(1)!.trim();
    }

    if (device.isNotEmpty) return device;

    // Fallback: extract OS info
    if (ua.contains('android')) {
      final versionMatch = RegExp(r'android[_\s]?(\d+)').firstMatch(ua);
      return versionMatch != null ? 'Android ${versionMatch.group(1)}' : 'Android';
    }
    if (ua.contains('ios')) {
      final versionMatch = RegExp(r'ios[_\s]?(\d+)').firstMatch(ua);
      return versionMatch != null ? 'iOS ${versionMatch.group(1)}' : 'iOS';
    }

    return _extractBasicInfo(raw);
  }

  static String _parseIOSDevice(String ua) {
    String device = '';
    String version = '';

    if (ua.contains('iphone')) {
      device = 'iPhone';
    } else if (ua.contains('ipad')) {
      device = 'iPad';
    } else if (ua.contains('ipod')) {
      device = 'iPod';
    }

    final iosVersionMatch = RegExp(r'os (\d+)[._](\d+)').firstMatch(ua);
    if (iosVersionMatch != null) {
      version = '${iosVersionMatch.group(1)}.${iosVersionMatch.group(2)}';
    } else {
      final iosVersionMatch2 = RegExp(r'os (\d+)').firstMatch(ua);
      if (iosVersionMatch2 != null) {
        version = iosVersionMatch2.group(1)!;
      }
    }

    if (device.isNotEmpty && version.isNotEmpty) {
      return '$device iOS $version';
    } else if (device.isNotEmpty) {
      return device;
    }

    return 'iOS Device';
  }

  static String _parseAndroidDevice(String ua) {
    String device = '';
    String androidVersion = '';

    final androidVersionMatch = RegExp(r'android[_\s]?(\d+)[._]?(\d+)?').firstMatch(ua);
    if (androidVersionMatch != null) {
      androidVersion = androidVersionMatch.group(1)!;
      if (androidVersionMatch.group(2) != null && androidVersionMatch.group(2)!.isNotEmpty) {
        androidVersion += '.${androidVersionMatch.group(2)}';
      }
    } else {
      final altVersionMatch = RegExp(r'android[/_](\d+)').firstMatch(ua);
      if (altVersionMatch != null) {
        androidVersion = altVersionMatch.group(1)!;
      }
    }

    if (ua.contains('sm-')) {
      final samsungMatch = RegExp(r'sm-([a-z0-9]+)').firstMatch(ua);
      if (samsungMatch != null) {
        device = 'Samsung Galaxy ${samsungMatch.group(1)!.toUpperCase()}';
      }
    }

    if (ua.contains('pixel')) {
      final pixelMatch = RegExp(r'pixel (\d+)').firstMatch(ua);
      if (pixelMatch != null) {
        device = 'Google Pixel ${pixelMatch.group(1)}';
      } else {
        device = 'Google Pixel';
      }
    }

    if (ua.contains('mi ') || ua.contains('redmi')) {
      final xiaomiMatch = RegExp(r'(mi|redmi) ([a-z0-9]+)').firstMatch(ua);
      if (xiaomiMatch != null) {
        device = 'Xiaomi ${xiaomiMatch.group(1)!.toUpperCase()} ${xiaomiMatch.group(2)!.toUpperCase()}';
      }
    }

    if (ua.contains('oneplus')) {
      final oneplusMatch = RegExp(r'oneplus[_\s]?([a-z0-9]+)').firstMatch(ua);
      if (oneplusMatch != null) {
        device = 'OnePlus ${oneplusMatch.group(1)!.toUpperCase()}';
      } else {
        device = 'OnePlus';
      }
    }

    if (ua.contains('huawei') || ua.contains('honor')) {
      final huaweiMatch = RegExp(r'(huawei|honor)[_\s]?([a-z0-9]+)').firstMatch(ua);
      if (huaweiMatch != null) {
        device = '${huaweiMatch.group(1)!.substring(0, 1).toUpperCase()}${huaweiMatch.group(1)!.substring(1)} ${huaweiMatch.group(2)!.toUpperCase()}';
      }
    }

    if (device.isNotEmpty && androidVersion.isNotEmpty) {
      return '$device Android $androidVersion';
    } else if (device.isNotEmpty) {
      return device;
    } else if (androidVersion.isNotEmpty) {
      return 'Android $androidVersion';
    }

    return 'Android Device';
  }

  static String _parseWindows(String ua) {
    if (ua.contains('windows nt 10.0') && ua.contains('win64')) {
      return 'Windows 11';
    }
    if (ua.contains('windows nt 10.0')) {
      return 'Windows 10';
    }
    if (ua.contains('windows nt 6.3')) {
      return 'Windows 8.1';
    }
    if (ua.contains('windows nt 6.2')) {
      return 'Windows 8';
    }
    if (ua.contains('windows nt 6.1')) {
      return 'Windows 7';
    }
    if (ua.contains('windows nt')) {
      return 'Windows';
    }
    return 'Windows';
  }

  static String _parseMacOS(String ua) {
    final macVersionMatch = RegExp(r'mac os x (\d+)[._](\d+)').firstMatch(ua);
    if (macVersionMatch != null) {
      final major = int.parse(macVersionMatch.group(1)!);
      final minor = int.parse(macVersionMatch.group(2)!);
      
      if (major == 10) {
        switch (minor) {
          case 15: return 'macOS Catalina';
          case 14: return 'macOS Mojave';
          case 13: return 'macOS High Sierra';
          case 12: return 'macOS Sierra';
          case 11: return 'macOS El Capitan';
          default: return 'macOS 10.$minor';
        }
      } else if (major == 11) {
        return 'macOS Big Sur';
      } else if (major == 12) {
        return 'macOS Monterey';
      } else if (major == 13) {
        return 'macOS Ventura';
      } else if (major == 14) {
        return 'macOS Sonoma';
      } else if (major == 15) {
        return 'macOS Sequoia';
      }
      return 'macOS $major.$minor';
    }
    return 'macOS';
  }

  static bool _isAndroidDevicePattern(String ua) {
    return ua.contains('sm-') ||
           ua.contains('pixel') ||
           ua.contains('oneplus') ||
           ua.contains('huawei') ||
           ua.contains('honor') ||
           ua.contains('mi ') ||
           ua.contains('redmi') ||
           ua.contains('oppo') ||
           ua.contains('vivo') ||
           ua.contains('realme') ||
           (ua.contains('linux') && ua.contains('mobile'));
  }

  static String _extractBasicInfo(String userAgent) {
    if (userAgent.toLowerCase().contains('chrome')) {
      return 'Chrome Browser';
    } else if (userAgent.toLowerCase().contains('firefox')) {
      return 'Firefox Browser';
    } else if (userAgent.toLowerCase().contains('safari')) {
      return 'Safari Browser';
    } else if (userAgent.toLowerCase().contains('edge')) {
      return 'Edge Browser';
    }
    if (userAgent.length > 50) {
      return '${userAgent.substring(0, 50)}...';
    }
    return userAgent;
  }
}
