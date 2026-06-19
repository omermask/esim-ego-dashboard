import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/inventory_data.dart';

class InventoryProvider extends ChangeNotifier {
  final ApiService api;
  InventoryProvider(this.api);

  List<ImportBatch> _batches = [];
  List<EsimInventory> _items = [];
  List<ExpiringEsim> _expiring = [];
  InventoryStats _stats = InventoryStats();
  int _totalBatches = 0;
  int _totalItems = 0;
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  List<ImportBatch> get batches => _batches;
  List<EsimInventory> get items => _items;
  List<ExpiringEsim> get expiring => _expiring;
  InventoryStats get stats => _stats;
  int get totalItems => _totalItems;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadBatches({bool refresh = false}) async {
    if (_loading) return;
    if (!refresh && !_hasMore) return;
    _loading = true;
    if (refresh) { _page = 1; _error = null; }
    notifyListeners();
    try {
      final d = await api.getInventoryBatches(page: _page);
      final list = (d['items'] as List?)?.map((e) => ImportBatch.fromJson(e)).toList() ?? [];
      if (refresh) { _batches = list; } else { _batches.addAll(list); }
      _totalBatches = d['total'] ?? 0;
      _hasMore = (_page * 20) < _totalBatches;
      _page++;
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<void> loadItems({bool refresh = false, String? planId, String? status}) async {
    if (_loading) return;
    if (!refresh && !_hasMore) return;
    _loading = true;
    if (refresh) { _page = 1; _error = null; }
    notifyListeners();
    try {
      final d = await api.getInventory(page: _page, planId: planId, status: status);
      final list = (d['items'] as List?)?.map((e) => EsimInventory.fromJson(e)).toList() ?? [];
      if (refresh) { _items = list; } else { _items.addAll(list); }
      _totalItems = d['total'] ?? 0;
      _hasMore = (_page * 20) < _totalItems;
      _page++;
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<void> loadStats({String? planId}) async {
    try { _stats = InventoryStats.fromJson(await api.getInventoryStats(planId: planId)); notifyListeners(); }
    catch (_) {}
  }

  Future<String?> import(String planId, String filePath) async {
    try { await api.importInventory(planId, filePath); await loadBatches(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Import failed'; }
  }

  Future<void> loadExpiring({int days = 7}) async {
    try {
      final d = await api.getExpiringInventory(days: days);
      _expiring = (d['items'] as List?)?.map((e) => ExpiringEsim.fromJson(e)).toList() ?? [];
      notifyListeners();
    } catch (_) {}
  }

  Future<String?> retry(String inventoryId) async {
    try { await api.retryActivation(inventoryId); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> purchase(String planId, int quantity) async {
    try { await api.purchaseInventory(planId, quantity); await loadStats(planId: planId); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
