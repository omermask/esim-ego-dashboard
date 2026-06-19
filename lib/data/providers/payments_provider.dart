import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/payment_data.dart';

class PaymentsProvider extends ChangeNotifier {
  final ApiService api;
  PaymentsProvider(this.api);

  List<AdminPayment> _payments = [];
  int _total = 0;
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  List<AdminPayment> get payments => _payments;
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
      final d = await api.getPayments(page: _page);
      final list = (d['items'] as List?)?.map((e) => AdminPayment.fromJson(e)).toList() ?? [];
      if (refresh) { _payments = list; } else { _payments.addAll(list); }
      _total = d['total'] ?? 0;
      _hasMore = (_page * 20) < _total;
      _page++;
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed to load payments'; }
    _loading = false;
    notifyListeners();
  }

  Future<String?> confirm(String id) async {
    try { await api.confirmPayment(id); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
