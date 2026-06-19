import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/tax_rate_data.dart';

class TaxRateProvider extends ChangeNotifier {
  final ApiService api;
  TaxRateProvider(this.api);

  List<TaxRate> _rates = [];
  bool _loading = false;
  String? _error;

  List<TaxRate> get rates => _rates;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true; _error = null; notifyListeners();
    try {
      final d = await api.getTaxRates();
      final list = (d['items'] as List?) ?? (d['tax_rates'] as List?);
      _rates = (list)?.map((e) => TaxRate.fromJson(e)).toList() ?? [];
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<String?> create(String name, String percentage, {String description = ''}) async {
    try { await api.createTaxRate(name, percentage, description: description); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> update(String id, Map<String, dynamic> data) async {
    try { await api.updateTaxRate(id, data); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
