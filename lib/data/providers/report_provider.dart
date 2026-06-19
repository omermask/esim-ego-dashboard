import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/report_data.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService api;
  ReportProvider(this.api);

  FinancialReport _financial = FinancialReport();
  WalletDashboard _wallet = WalletDashboard();
  bool _loading = false;
  String? _error;

  FinancialReport get financial => _financial;
  WalletDashboard get wallet => _wallet;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadFinancial({String period = 'daily'}) async {
    _loading = true; _error = null; notifyListeners();
    try { _financial = FinancialReport.fromJson(await api.getFinancialReport(period: period)); }
    on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<void> loadWallet() async {
    try { _wallet = WalletDashboard.fromJson(await api.getWalletDashboardReport()); notifyListeners(); }
    catch (_) {}
  }
}
