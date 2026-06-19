import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuditLogEntry {
  final String id;
  final String? userId;
  final String? userName;
  final String action;
  final String? resourceType;
  final String? resourceId;
  final String? details;
  final String? ipAddress;
  final String? createdAt;

  AuditLogEntry({
    required this.id, this.userId, this.userName, required this.action,
    this.resourceType, this.resourceId, this.details, this.ipAddress, this.createdAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) => AuditLogEntry(
    id: json['id'] ?? '', userId: json['user_id']?.toString(), userName: json['user_name'],
    action: json['action'] ?? '', resourceType: json['resource_type'],
    resourceId: json['resource_id']?.toString(), details: json['details'],
    ipAddress: json['ip_address'], createdAt: json['created_at'],
  );
}

class AuditLogProvider extends ChangeNotifier {
  final ApiService api;
  AuditLogProvider(this.api);

  List<AuditLogEntry> _logs = [];
  int _total = 0;
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  List<AuditLogEntry> get logs => _logs;
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
      final d = await api.getAuditLogs(page: _page);
      final list = (d['items'] as List?)?.map((e) => AuditLogEntry.fromJson(e)).toList() ?? [];
      if (refresh) { _logs = list; } else { _logs.addAll(list); }
      _total = d['total'] ?? 0;
      _hasMore = (_page * 20) < _total;
      _page++;
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed to load logs'; }
    _loading = false; notifyListeners();
  }
}
