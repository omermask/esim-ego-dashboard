import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class TwoFAProvider extends ChangeNotifier {
  final ApiService api;
  TwoFAProvider(this.api);

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _setupData;

  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get setupData => _setupData;

  Future<String?> setup() async {
    _loading = true; _error = null; notifyListeners();
    try { _setupData = await api.setup2fa(); return null; }
    on ApiException catch (e) { _error = e.userMessage; return e.userMessage; }
    catch (_) { _error = 'Failed'; return 'Failed'; }
    finally { _loading = false; notifyListeners(); }
  }

  Future<String?> enable(String code) async {
    _loading = true; _error = null; notifyListeners();
    try { await api.enable2fa(code); return null; }
    on ApiException catch (e) { _error = e.userMessage; return e.userMessage; }
    catch (_) { _error = 'Failed'; return 'Failed'; }
    finally { _loading = false; notifyListeners(); }
  }

  Future<String?> disable(String code) async {
    _loading = true; _error = null; notifyListeners();
    try { await api.disable2fa(code); return null; }
    on ApiException catch (e) { _error = e.userMessage; return e.userMessage; }
    catch (_) { _error = 'Failed'; return 'Failed'; }
    finally { _loading = false; notifyListeners(); }
  }
}
