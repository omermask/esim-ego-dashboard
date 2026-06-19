import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/freeze_data.dart';

class FreezeProvider extends ChangeNotifier {
  final ApiService api;
  FreezeProvider(this.api);

  List<Freeze> _freezes = [];
  int _total = 0;
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  List<Freeze> get freezes => _freezes;
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
      final d = await api.getFreezes(page: _page);
      final list = (d['items'] as List?)?.map((e) => Freeze.fromJson(e)).toList() ?? [];
      if (refresh) { _freezes = list; } else { _freezes.addAll(list); }
      _total = d['total'] ?? 0;
      _hasMore = (_page * 20) < _total;
      _page++;
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<String?> create(String userId, int amount, {String reason = ''}) async {
    try { await api.createFreeze(userId, amount, reason: reason); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> release(String freezeId) async {
    try { await api.releaseFreeze(freezeId); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
