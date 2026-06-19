import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/coupon_data.dart';

class CouponProvider extends ChangeNotifier {
  final ApiService api;
  CouponProvider(this.api);

  List<Coupon> _coupons = [];
  bool _loading = false;
  String? _error;

  List<Coupon> get coupons => _coupons;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true; _error = null; notifyListeners();
    try {
      final d = await api.getCoupons();
      final list = (d['items'] as List?) ?? (d['coupons'] as List?);
      _coupons = (list)?.map((e) => Coupon.fromJson(e)).toList() ?? [];
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try { await api.createCoupon(data); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> update(String id, Map<String, dynamic> data) async {
    try { await api.updateCoupon(id, data); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
