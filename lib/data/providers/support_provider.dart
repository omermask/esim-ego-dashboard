import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/ticket_data.dart';

class SupportProvider extends ChangeNotifier {
  final ApiService api;
  SupportProvider(this.api);

  List<AdminTicket> _tickets = [];
  int _total = 0;
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  List<AdminTicket> get tickets => _tickets;
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
      final d = await api.getTickets(page: _page);
      final list = (d['items'] as List?)?.map((e) => AdminTicket.fromJson(e)).toList() ?? [];
      if (refresh) { _tickets = list; } else { _tickets.addAll(list); }
      _total = d['total'] ?? 0;
      _hasMore = (_page * 20) < _total;
      _page++;
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed'; }
    _loading = false; notifyListeners();
  }

  Future<String?> reply(String id, String msg) async {
    try { await api.replyTicket(id, msg); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> updateStatus(String id, String status) async {
    try { await api.updateTicketStatus(id, status); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> assign(String id, String assignedToId) async {
    try { await api.assignTicket(id, assignedToId); await load(refresh: true); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
