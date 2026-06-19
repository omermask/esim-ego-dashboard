import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/backup_data.dart';

class BackupProvider extends ChangeNotifier {
  final ApiService api;
  BackupProvider(this.api);

  List<BackupRecord> _backups = [];
  BackupSettings _settings = BackupSettings();
  int _total = 0;
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  List<BackupRecord> get backups => _backups;
  BackupSettings get settings => _settings;
  int get total => _total;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> load({bool refresh = false}) async {
    if (_loading) return;
    if (!refresh && !_hasMore) return;
    _loading = true;
    if (refresh) { _page = 1; _error = null; }
    notifyListeners();
    try {
      final d = await api.listBackups(page: _page);
      final list = (d['items'] as List?)?.map((e) => BackupRecord.fromJson(e)).toList() ?? [];
      if (refresh) { _backups = list; } else { _backups.addAll(list); }
      _total = d['total'] ?? 0;
      _hasMore = (_page * 20) < _total;
      _page++;
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<void> loadSettings() async {
    try { _settings = BackupSettings.fromJson(await api.getBackupSettings()); notifyListeners(); }
    catch (_) {}
  }

  Future<Map<String, dynamic>?> create() async {
    try { final d = await api.createBackup(); await load(refresh: true); return d; }
    on ApiException catch (e) { _error = e.userMessage; return null; }
    catch (_) { _error = 'Failed'; return null; }
  }

  Future<String?> delete(String id) async {
    try { await api.deleteBackup(id); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> updateSetting(String key, String value) async {
    try { await api.updateBackupSetting(key, value); await loadSettings(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<int?> runCleanup() async {
    try {
      final d = await api.runBackupCleanup();
      await load(refresh: true);
      return d['deleted'] as int?;
    } catch (_) { return null; }
  }

  Future<http.Response?> download(String id) async {
    try { return await api.downloadBackup(id); }
    catch (_) { return null; }
  }
}
