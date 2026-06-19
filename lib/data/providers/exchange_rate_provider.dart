import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/exchange_rate_data.dart';

class ExchangeRateProvider extends ChangeNotifier {
  final ApiService api;
  ExchangeRateProvider(this.api);

  List<ExchangeRate> _rates = [];
  bool _loading = false;
  String? _error;

  List<ExchangeRate> get rates => _rates;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true; _error = null; notifyListeners();
    try {
      final d = await api.getExchangeRates();
      final list = (d['items'] as List?) ?? (d['rates'] as List?);
      _rates = (list)?.map((e) => ExchangeRate.fromJson(e)).toList() ?? [];
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<String?> set(String base, String target, String rate) async {
    try { await api.setExchangeRate(base, target, rate); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<Map<String, dynamic>> fetchNow() async {
    try {
      final d = await api.fetchExchangeRates();
      await load();
      return d;
    } on ApiException catch (e) { return {'success': false, 'error': e.userMessage}; }
    catch (_) { return {'success': false, 'error': 'Failed'}; }
  }
}
