import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api;
  AuthProvider(this.api);

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _user;
  bool _init = false;
  bool _otpSent = false;
  bool _twofaRequired = false;
  String _phone = '';
  int _step = 0; // 0=phone, 1=otp, 2=2fa (if needed)

  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  bool get authed => api.isAuthenticated;
  bool get initialized => _init;
  bool get otpSent => _otpSent;
  bool get twofaRequired => _twofaRequired;
  String get phone => _phone;
  int get step => _step;

  Future<void> init() async {
    await api.init();
    _init = true;
    notifyListeners();
  }

  void reset() {
    _loading = false; _error = null; _otpSent = false; _twofaRequired = false; _phone = ''; _step = 0;
    notifyListeners();
  }

  Future<String?> sendOtp(String phone) async {
    _loading = true; _error = null; notifyListeners();
    try {
      await api.sendOtp(phone);
      _phone = phone;
      _otpSent = true;
      _step = 1;
      _loading = false; notifyListeners();
      return null;
    } on ApiException catch (e) {
      _error = e.userMessage; _loading = false; notifyListeners();
      return e.userMessage;
    } catch (e) {
      _error = 'Connection failed'; _loading = false; notifyListeners();
      return 'Connection failed';
    }
  }

  Future<String?> verifyOtp(String code) async {
    if (_phone.isEmpty) return 'No phone number';
    _loading = true; _error = null; notifyListeners();
    try {
      final d = await api.verifyOtp(_phone, code);
      _user = d['user'] as Map<String, dynamic>?;
      _twofaRequired = d['2fa_required'] == true;
      if (_twofaRequired) {
        _step = 2;
        _loading = false; notifyListeners();
        return '2FA_REQUIRED';
      }
      _step = 0;
      _loading = false; notifyListeners();
      return null;
    } on ApiException catch (e) {
      _error = e.userMessage; _loading = false; notifyListeners();
      return e.userMessage;
    } catch (e) {
      _error = 'Connection failed'; _loading = false; notifyListeners();
      return 'Connection failed';
    }
  }

  Future<String?> verify2FA(String code) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final d = await api.post('/admin/2fa/verify', body: {'code': code});
      final data = d.data as Map<String, dynamic>;
      await api.setTokens(data['access_token'] as String, data['refresh_token'] as String);
      _twofaRequired = false;
      _step = 0;
      _loading = false; notifyListeners();
      return null;
    } on ApiException catch (e) {
      _error = e.userMessage; _loading = false; notifyListeners();
      return e.userMessage;
    } catch (e) {
      _error = 'Connection failed'; _loading = false; notifyListeners();
      return 'Connection failed';
    }
  }

  Future<void> logout() async {
    try { await api.logout(); } catch (_) {}
    await api.clearTokens();
    _user = null;
    _otpSent = false; _twofaRequired = false; _phone = ''; _step = 0;
    notifyListeners();
  }
}
