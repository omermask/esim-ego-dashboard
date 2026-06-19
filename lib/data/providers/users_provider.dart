import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user_data.dart';
import '../models/wallet_data.dart';

class UsersProvider extends ChangeNotifier {
  final ApiService api;
  UsersProvider(this.api);

  List<AdminUser> _users = [];
  int _total = 0;
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  String _query = '';

  WalletData? _wallet;
  List<WalletTransaction> _walletTxs = [];
  bool _walletLoading = false;

  List<AdminUser> get users => _users;
  int get total => _total;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get query => _query;

  WalletData? get wallet => _wallet;
  List<WalletTransaction> get walletTxs => _walletTxs;
  bool get walletLoading => _walletLoading;

  void setQuery(String q) { _query = q; _users = []; _page = 1; _hasMore = true; load(refresh: true); }

  Future<void> load({bool refresh = false}) async {
    if (_loading) return;
    if (!refresh && !_hasMore) return;
    _loading = true;
    if (refresh) { _page = 1; _error = null; }
    notifyListeners();
    try {
      final d = await api.getUsers(page: _page, query: _query);
      final list = (d['items'] as List?)?.map((e) => AdminUser.fromJson(e)).toList() ?? [];
      if (refresh) { _users = list; } else { _users.addAll(list); }
      _total = d['total'] ?? 0;
      _hasMore = (_page * 20) < _total;
      _page++;
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed to load users'; }
    _loading = false;
    notifyListeners();
  }

  Future<String?> toggleActive(String id) async {
    try {
      await api.toggleUserActive(id);
      await load(refresh: true);
      return null;
    } on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> updateRole(String id, String role) async {
    try {
      await api.updateUser(id, {'role': role});
      await load(refresh: true);
      return null;
    } on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> ban(String id) async {
    try { await api.banUser(id); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> unban(String id) async {
    try { await api.unbanUser(id); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<void> loadWallet(String id) async {
    _walletLoading = true; notifyListeners();
    try {
      final d = await api.getUserWallet(id);
      _wallet = WalletData.fromJson(d);
      final txd = await api.getWalletTransactions(id);
      final list = (txd['items'] as List?)?.map((e) => WalletTransaction.fromJson(e)).toList() ?? [];
      _walletTxs = list;
    } catch (_) {}
    _walletLoading = false; notifyListeners();
  }

  Future<String?> adjustWallet(String id, int amount, {String reason = ''}) async {
    try {
      await api.adjustWallet(id, {'amount': amount, 'reason': reason});
      await loadWallet(id);
      return null;
    } on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
