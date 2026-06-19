import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/referral_data.dart';

class ReferralProvider extends ChangeNotifier {
  final ApiService api;
  ReferralProvider(this.api);

  ReferralSettings _settings = ReferralSettings();
  List<ReferralReward> _rewards = [];
  ReferralStats _stats = ReferralStats();
  int _rewardsTotal = 0;
  bool _loading = false;
  String? _error;

  ReferralSettings get settings => _settings;
  List<ReferralReward> get rewards => _rewards;
  ReferralStats get stats => _stats;
  int get rewardsTotal => _rewardsTotal;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true; _error = null; notifyListeners();
    try {
      final results = await Future.wait([
        api.getReferralSettings(),
        api.getReferralRewards(),
        api.getReferralStats(),
      ]);
      _settings = ReferralSettings.fromJson(results[0]);
      _rewards = (results[1]['items'] as List?)?.map((e) => ReferralReward.fromJson(e)).toList() ?? [];
      _rewardsTotal = results[1]['total'] ?? 0;
      _stats = ReferralStats.fromJson(results[2]);
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed to load referrals'; }
    _loading = false; notifyListeners();
  }

  Future<String?> updateSetting(String key, String value) async {
    try { await api.updateReferralSetting(key, value); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> creditReward(String id) async {
    try { await api.creditReferralReward(id); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> cancelReward(String id, String reason) async {
    try { await api.cancelReferralReward(id, reason); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
