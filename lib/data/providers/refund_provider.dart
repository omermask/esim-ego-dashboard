import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/refund_data.dart';

class RefundProvider extends ChangeNotifier {
  final ApiService api;
  RefundProvider(this.api);

  List<Refund> _refunds = [];
  int _total = 0;
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  List<Refund> get refunds => _refunds;
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
      final d = await api.getRefunds(page: _page);
      final list = (d['items'] as List?)?.map((e) => Refund.fromJson(e)).toList() ?? [];
      if (refresh) { _refunds = list; } else { _refunds.addAll(list); }
      _total = d['total'] ?? 0;
      _hasMore = (_page * 20) < _total;
      _page++;
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<String?> create(String orderId, {int? amount, String reason = ''}) async {
    try { await api.createRefund(orderId, amount: amount, reason: reason); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
