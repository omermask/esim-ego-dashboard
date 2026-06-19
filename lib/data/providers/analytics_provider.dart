import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/analytics_data.dart';

class AnalyticsProvider extends ChangeNotifier {
  final ApiService api;
  AnalyticsProvider(this.api);

  List<SalesChartPoint> _salesChart = [];
  List<PlansChartItem> _plansChart = [];
  List<UserGrowthPoint> _userGrowth = [];
  List<ActivityLog> _activity = [];
  int _activityTotal = 0;
  int _activityPage = 1;
  bool _loading = false;
  bool _hasMoreActivity = true;
  String? _error;

  List<SalesChartPoint> get salesChart => _salesChart;
  List<PlansChartItem> get plansChart => _plansChart;
  List<UserGrowthPoint> get userGrowth => _userGrowth;
  List<ActivityLog> get activity => _activity;
  bool get loading => _loading;
  bool get hasMoreActivity => _hasMoreActivity;
  String? get error => _error;

  Future<void> loadSalesChart({int days = 30}) async {
    try {
      final d = await api.getSalesChart(days: days);
      final list = (d['items'] as List?) ?? (d['data'] as List?);
      _salesChart = (list)?.map((e) => SalesChartPoint.fromJson(e)).toList() ?? [];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadPlansChart() async {
    try {
      final d = await api.getPlansChart();
      final list = (d['items'] as List?) ?? (d['data'] as List?);
      _plansChart = (list)?.map((e) => PlansChartItem.fromJson(e)).toList() ?? [];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadUserGrowth({String period = 'daily'}) async {
    try {
      final d = await api.getUserGrowthChart(period: period);
      final list = (d['items'] as List?) ?? (d['data'] as List?);
      _userGrowth = (list)?.map((e) => UserGrowthPoint.fromJson(e)).toList() ?? [];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadActivity({bool refresh = false, String? action}) async {
    if (_loading) return;
    if (!refresh && !_hasMoreActivity) return;
    _loading = true;
    if (refresh) { _activityPage = 1; _error = null; }
    notifyListeners();
    try {
      final d = await api.getAdminActivity(page: _activityPage, action: action);
      final list = (d['items'] as List?)?.map((e) => ActivityLog.fromJson(e)).toList() ?? [];
      if (refresh) { _activity = list; } else { _activity.addAll(list); }
      _activityTotal = d['total'] ?? 0;
      _hasMoreActivity = (_activityPage * 20) < _activityTotal;
      _activityPage++;
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<http.Response?> exportReport(String type, {String format = 'csv', String? status, String? method}) async {
    try { return await api.exportReport(type, format: format, status: status, method: method); }
    catch (_) { return null; }
  }
}
