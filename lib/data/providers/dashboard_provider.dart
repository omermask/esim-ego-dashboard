import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/dashboard_data.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService api;
  DashboardProvider(this.api);

  DashboardData _data = DashboardData();
  AnalyticsData _analytics = AnalyticsData();
  bool _loading = false;
  String? _error;

  DashboardData get data => _data;
  AnalyticsData get analytics => _analytics;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _data = DashboardData.fromJson(await api.getDashboard());
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed to load dashboard'; }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadAnalytics() async {
    try {
      _analytics = AnalyticsData.fromJson(await api.getAnalytics());
    } catch (_) {}
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([load(), loadAnalytics()]);
  }
}
