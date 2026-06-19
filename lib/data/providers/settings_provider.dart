import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/system_settings_data.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService api;
  SettingsProvider(this.api);

  List<SystemSetting> _settings = [];
  bool _loading = false;
  String? _error;

  Map<String, String> _serverConfig = {};
  bool _serverConfigLoading = false;
  String? _serverConfigError;

  List<SystemSetting> get settings => _settings;
  bool get loading => _loading;
  String? get error => _error;

  Map<String, String> get serverConfig => _serverConfig;
  bool get serverConfigLoading => _serverConfigLoading;
  String? get serverConfigError => _serverConfigError;

  String get officialCurrency => _serverConfig['official_currency'] ?? 'IQD';
  String get timezone => _serverConfig['timezone'] ?? 'Asia/Baghdad';
  String get autoFetchInterval => _serverConfig['auto_fetch_interval'] ?? 'manual';

  Future<void> load() async {
    _loading = true; _error = null; notifyListeners();
    try {
      final d = await api.getSystemSettings();
      final list = (d['items'] as List?) ?? (d['settings'] as List?);
      _settings = (list)?.map((e) => SystemSetting.fromJson(e)).toList() ?? [];
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<String?> update(String key, String value, {String description = ''}) async {
    try { await api.updateSystemSetting(key, value, description: description); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> delete(String key) async {
    try { await api.deleteSystemSetting(key); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  // ── Server Config ──
  Future<void> loadServerConfig() async {
    _serverConfigLoading = true; _serverConfigError = null; notifyListeners();
    try {
      final d = await api.getServerConfig();
      _serverConfig = Map<String, String>.from(d.map((k, v) => MapEntry(k, v.toString())));
    } on ApiException catch (e) { _serverConfigError = e.userMessage; }
    catch (_) { _serverConfigError = 'Failed'; }
    _serverConfigLoading = false; notifyListeners();
  }

  Future<String?> updateServerConfig(Map<String, String> config) async {
    try {
      await api.updateServerConfig(config);
      _serverConfig.addAll(config);
      notifyListeners();
      return null;
    } on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
