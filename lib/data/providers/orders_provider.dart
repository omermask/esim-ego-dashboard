import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/order_data.dart';

class OrdersProvider extends ChangeNotifier {
  final ApiService api;
  OrdersProvider(this.api);

  List<AdminOrder> _orders = [];
  int _total = 0;
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  String? _statusFilter;

  List<AdminOrder> get orders => _orders;
  int get total => _total;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  void setFilter(String? s) { _statusFilter = s; _orders = []; _page = 1; _hasMore = true; load(refresh: true); }

  Future<void> load({bool refresh = false}) async {
    if (_loading) return;
    if (!refresh && !_hasMore) return;
    _loading = true;
    if (refresh) { _page = 1; _error = null; }
    notifyListeners();
    try {
      final d = await api.getOrders(page: _page, status: _statusFilter);
      final list = (d['items'] as List?)?.map((e) => AdminOrder.fromJson(e)).toList() ?? [];
      if (refresh) { _orders = list; } else { _orders.addAll(list); }
      _total = d['total'] ?? 0;
      _hasMore = (_page * 20) < _total;
      _page++;
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed to load orders'; }
    _loading = false;
    notifyListeners();
  }

  Future<String?> approve(String id) async {
    try { await api.approveOrder(id); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> cancel(String id) async {
    try { await api.cancelOrder(id); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> refund(String id) async {
    try { await api.refundOrder(id); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> reprocess(String id) async {
    try { await api.reprocessOrder(id); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
