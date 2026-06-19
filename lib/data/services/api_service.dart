import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/error_handler.dart';
import '../../core/errors/failures.dart';

class ApiException implements Exception {
  static String locale = 'ar';

  final String code;
  final int status;
  final dynamic message;
  final String? details;
  final Map<String, List<String>>? fieldErrors;
  ApiException({
    required this.code,
    this.status = 400,
    this.message,
    this.details,
    this.fieldErrors,
  });
  String get userMessage {
    if (message is Map) {
      final map = message as Map;
      return map[locale] ?? map['en'] ?? map['ar'] ?? code;
    }
    return message?.toString() ?? code;
  }
  Failure toFailure() {
    return mapServerCodeToFailure(
      code: code,
      message: userMessage,
      statusCode: status,
      details: details,
      fieldErrors: fieldErrors,
    );
  }
  @override
  String toString() => 'ApiException($status): $userMessage [$code]';
}

class ApiResponse {
  final bool success;
  final int status;
  final String code;
  final dynamic message;
  final dynamic data;
  ApiResponse({required this.success, required this.status, required this.code, this.message, this.data});
  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
    success: json['success'] ?? false, status: json['status'] ?? 200,
    code: json['code'] ?? '', message: json['message'], data: json['data'],
  );
}

class ApiService {
  final http.Client _client = http.Client();
  String? _accessToken;
  String? _refreshToken;
  String? _deviceId;
  bool _refreshing = false;

  String _generateDeviceId() {
    final r = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final parts = <String>[];
    for (var i = 0; i < 4; i++) {
      parts.add(List.generate(8, (_) => chars[r.nextInt(chars.length)]).join());
    }
    return parts.join('-');
  }

  String get deviceId => _deviceId ?? '';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    _deviceId = prefs.getString('device_id');
    if (_deviceId == null || _deviceId!.isEmpty) {
      _deviceId = _generateDeviceId();
      await prefs.setString('device_id', _deviceId!);
    }
  }

  bool get isAuthenticated => _accessToken != null;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  static Map<String, List<String>>? _parseFieldErrors(dynamic details) {
    if (details is! List) return null;
    final result = <String, List<String>>{};
    for (final item in details) {
      if (item is Map && item['field'] != null) {
        final field = item['field'].toString();
        final msg = item['message']?.toString() ?? '';
        result.putIfAbsent(field, () => []).add(msg);
      }
    }
    return result.isEmpty ? null : result;
  }

  Future<ApiResponse> request(String method, String path, {Map<String, dynamic>? body, Map<String, String>? params, Duration? timeoutOverride}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path').replace(queryParameters: params);
    final timeout_ = timeoutOverride ?? AppConstants.requestTimeout;
    try {
      final response = await switch (method) {
        'GET' => _client.get(uri, headers: _headers).timeout(timeout_),
        'POST' => _client.post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null).timeout(timeout_),
        'PUT' => _client.put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null).timeout(timeout_),
        'DELETE' => body != null
          ? _client.send(http.Request('DELETE', uri)..headers.addAll(_headers)..body = jsonEncode(body))
              .timeout(timeout_)
              .then((v) async => http.Response(await v.stream.bytesToString(), v.statusCode, headers: v.headers))
          : _client.delete(uri, headers: _headers).timeout(timeout_),
        'PATCH' => _client.patch(uri, headers: _headers, body: body != null ? jsonEncode(body) : null).timeout(timeout_),
        _ => throw ApiException(code: 'INVALID_METHOD'),
      };
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) return ApiResponse.fromJson(json);
      if (json['code'] == 'auth_device_session_expired') {
        await clearTokens();
        throw ApiException(code: 'auth_device_session_expired', status: 401, message: json['message']);
      }
      if (json['status'] == 401 && _refreshToken != null && !_refreshing) {
        return _retryWithRefresh(method, uri, body, params);
      }
      final dataMap = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null;
      throw ApiException(
        code: json['code'] ?? 'UNKNOWN',
        status: json['status'] ?? response.statusCode,
        message: json['message'],
        details: dataMap?['details']?.toString(),
        fieldErrors: _parseFieldErrors(dataMap?['details']),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is SocketException || e is HttpException || e.toString().contains('TimeoutException')) {
        final networkFailure = mapNetworkErrorToFailure(e);
        throw ApiException(
          code: 'NETWORK_ERROR',
          status: 0,
          message: networkFailure.message,
        );
      }
      throw ApiException(code: 'NETWORK_ERROR', message: 'Connection failed: $e');
    }
  }

  Future<ApiResponse> _retryWithRefresh(String method, Uri uri, Map<String, dynamic>? body, Map<String, String>? params) async {
    _refreshing = true;
    try {
      final refreshBody = jsonEncode({'refresh_token': _refreshToken});
      final res = await _client.post(
        Uri.parse('${AppConstants.baseUrl}/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: refreshBody,
      ).timeout(AppConstants.requestTimeout);
      final d = jsonDecode(res.body) as Map<String, dynamic>;
      if (d['success'] != true) {
        throw ApiException(
          code: d['code'] ?? 'auth_invalid_refresh',
          status: d['status'] ?? 401,
          message: d['message'],
        );
      }
      await setTokens(d['data']['access_token'] as String, d['data']['refresh_token'] as String);
    } catch (_) {
      _refreshing = false;
      rethrow;
    }
    _refreshing = false;
    return request(method, uri.toString().replaceFirst(AppConstants.baseUrl, ''), body: body, params: params);
  }

  Future<ApiResponse> get(String path, {Map<String, String>? params, Duration? timeoutOverride}) => request('GET', path, params: params, timeoutOverride: timeoutOverride);
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) => request('POST', path, body: body);
  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) => request('PUT', path, body: body);
  Future<ApiResponse> delete(String path, {Map<String, dynamic>? body}) => request('DELETE', path, body: body);
  Future<ApiResponse> patch(String path, {Map<String, dynamic>? body}) => request('PATCH', path, body: body);

  Future<void> setTokens(String access, String refresh) async {
    _accessToken = access;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // ── Auth (OTP-based) ──
  Future<Map<String, dynamic>> register(String phone, String name, {String language = 'en', String timezone = 'UTC', String? referralCode}) async {
    final body = <String, dynamic>{'phone': phone, 'name': name, 'language': language, 'timezone': timezone};
    if (referralCode != null) body['referral_code'] = referralCode;
    final res = await post('/auth/register', body: body);
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> sendOtp(String phone) async {
    await post('/auth/send-otp', body: {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final body = <String, dynamic>{'phone': phone, 'code': code};
    if (_deviceId != null) body['device_id'] = _deviceId;
    final res = await post('/auth/verify-otp', body: body);
    final d = res.data as Map<String, dynamic>;
    await setTokens(d['access_token'] as String, d['refresh_token'] as String);
    return d;
  }

  Future<Map<String, dynamic>> refreshToken(String token) async {
    final res = await post('/auth/refresh', body: {'refresh_token': token});
    final d = res.data as Map<String, dynamic>;
    await setTokens(d['access_token'] as String, d['refresh_token'] as String);
    return d;
  }

  Future<void> logout() {
    final body = <String, dynamic>{};
    if (_deviceId != null) body['device_id'] = _deviceId;
    return post('/auth/logout', body: body);
  }

  // ── Dashboard ──
  Future<Map<String, dynamic>> getDashboard() async {
    final res = await get('/admin/dashboard');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    final res = await get('/admin/analytics/dashboard');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  // ── Users ──
  Future<Map<String, dynamic>> getUsers({int page = 1, int limit = 20, String query = ''}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (query.isNotEmpty) params['q'] = query;
    final res = await get('/admin/users/search', params: params);
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> toggleUserActive(String id) => post('/admin/users/$id/toggle-active');
  Future<void> updateUser(String id, Map<String, dynamic> data) => put('/admin/users/$id', body: data);

  // ── Orders ──
  Future<Map<String, dynamic>> getOrders({int page = 1, int limit = 20, String? status, String? userId, String? planId}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (status != null && status != 'all') params['status'] = status;
    if (userId != null) params['user_id'] = userId;
    if (planId != null) params['plan_id'] = planId;
    final res = await get('/admin/orders', params: params);
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getOrder(String id) async {
    final res = await get('/admin/orders/$id');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> approveOrder(String id) => post('/admin/orders/$id/approve');
  Future<void> cancelOrder(String id, {String reason = ''}) => post('/admin/orders/$id/cancel', body: {'reason': reason});
  Future<void> refundOrder(String id, {int? amount, String reason = ''}) {
    final body = <String, dynamic>{'reason': reason};
    if (amount != null) body['amount'] = amount;
    return post('/admin/orders/$id/refund', body: body);
  }

  // ── Plans ──
  Future<Map<String, dynamic>> getPlans() async {
    final res = await get('/admin/plans');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> createPlan(Map<String, dynamic> data) => post('/admin/plans', body: data);
  Future<void> updatePlan(String id, Map<String, dynamic> data) => put('/admin/plans/$id', body: data);
  Future<void> deletePlan(String id) => delete('/admin/plans/$id');
  Future<Map<String, dynamic>> deleteAllPlans() async {
    final res = await delete('/admin/plans/delete-all');
    return (res.data as Map<String, dynamic>?) ?? {};
  }
  Future<void> syncPlans() => post('/admin/plans/sync-catalogue');

  Future<Map<String, dynamic>> getCatalogue({int page = 1, int perPage = 50, bool allPages = true, bool force = false, String? network}) async {
    final params = <String, String>{'page': '$page', 'perPage': '$perPage'};
    if (allPages) params['allPages'] = 'true';
    if (force) params['force'] = 'true';
    if (network != null && network.isNotEmpty) params['network'] = network;
    final res = await get('/admin/plans/catalogue', params: params, timeoutOverride: const Duration(seconds: 200));
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getCatalogueNetworks() async {
    final res = await get('/admin/plans/catalogue/networks');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> buildNetworkIndex() async {
    final res = await post('/admin/plans/catalogue/build-network-index');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getCatalogueBundle(String name) async {
    final res = await get('/admin/plans/catalogue/bundle/$name');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> importCatalogueBundles(List<String> bundles) async {
    final res = await post('/admin/plans/catalogue/import', body: {'bundles': bundles});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  // ── Payments ──
  Future<Map<String, dynamic>> getPayments({int page = 1, int limit = 20, String? status, String? method, String? userId}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (status != null) params['status'] = status;
    if (method != null) params['method'] = method;
    if (userId != null) params['user_id'] = userId;
    final res = await get('/admin/payments', params: params);
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> confirmPayment(String id) => post('/admin/payments/$id/confirm');
  Future<void> refundPayment(String id, {String reason = ''}) => post('/admin/payments/$id/refund', body: {'reason': reason});

  // ── Support Tickets ──
  Future<Map<String, dynamic>> getTickets({int page = 1, int limit = 20, String? status, String? priority}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (status != null) params['status'] = status;
    if (priority != null) params['priority'] = priority;
    final res = await get('/admin/support/tickets', params: params);
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getTicket(String id) async {
    final res = await get('/admin/support/tickets/$id');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> replyTicket(String id, String message) => post('/admin/support/tickets/$id/reply', body: {'message': message});
  Future<void> updateTicketStatus(String id, String status) => patch('/admin/support/tickets/$id/status', body: {'status': status});
  Future<void> assignTicket(String id, String assignedToId) => post('/admin/support/tickets/$id/assign', body: {'assigned_to_id': assignedToId});

  // ── Referral ──
  Future<Map<String, dynamic>> getReferralSettings() async {
    final res = await get('/admin/referral/settings');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> updateReferralSetting(String key, String value) => put('/admin/referral/settings/$key', body: {'value': value});

  Future<Map<String, dynamic>> getReferralRewards({int page = 1, int limit = 20, String? status}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (status != null) params['status'] = status;
    final res = await get('/admin/referral/rewards', params: params);
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getReferralStats() async {
    final res = await get('/admin/referral/stats');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> creditReferralReward(String id) => post('/admin/referral/rewards/$id/credit');
  Future<void> cancelReferralReward(String id, String reason) => post('/admin/referral/rewards/$id/cancel', body: {'reason': reason});

  // ── Backup ──
  Future<Map<String, dynamic>> createBackup() async {
    final res = await post('/admin/backup/create');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> listBackups({int page = 1, int limit = 20}) async {
    final res = await get('/admin/backup/list', params: {'page': '$page', 'limit': '$limit'});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getBackup(String id) async {
    final res = await get('/admin/backup/$id');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> deleteBackup(String id) => delete('/admin/backup/$id');

  Future<Map<String, dynamic>> getBackupSettings() async {
    final res = await get('/admin/backup/settings');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> runBackupCleanup() async {
    final res = await post('/admin/backup/cleanup');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  // ── Audit -─
  Future<Map<String, dynamic>> getAuditLogs({int page = 1, int limit = 20, String? userId, String? action, String? resourceType}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (userId != null) params['user_id'] = userId;
    if (action != null) params['action'] = action;
    if (resourceType != null) params['resource_type'] = resourceType;
    final res = await get('/admin/audit-logs', params: params);
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  // ── Wallet ──
  Future<Map<String, dynamic>> getUserWallet(String id) async {
    final res = await get('/admin/users/$id/wallet');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getWalletTransactions(String id, {int page = 1, int limit = 20}) async {
    final res = await get('/admin/users/$id/wallet/transactions', params: {'page': '$page', 'limit': '$limit'});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> adjustWallet(String id, Map<String, dynamic> data) => post('/admin/users/$id/wallet/adjust', body: data);

  // ── User Details ──
  Future<Map<String, dynamic>> getUserDetail(String id) async {
    final res = await get('/admin/users/$id');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> banUser(String id) => post('/admin/users/$id/ban');
  Future<void> unbanUser(String id) => post('/admin/users/$id/unban');

  // ── System Settings ──
  Future<Map<String, dynamic>> getSystemSettings() async {
    final res = await get('/admin/settings');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getSystemSetting(String key) async {
    final res = await get('/admin/settings/$key');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> updateSystemSetting(String key, String value, {String description = ''}) =>
      put('/admin/settings/$key', body: {'value': value, 'description': description});

  Future<void> deleteSystemSetting(String key) => delete('/admin/settings/$key');

  // ── Orders - reprocess ──
  Future<void> reprocessOrder(String id) => post('/admin/orders/$id/reprocess');

  // ── Plans - batch ──
  Future<void> batchUpdatePlans(List<Map<String, dynamic>> updates) =>
      put('/admin/plans/batch', body: {'updates': updates});

  Future<void> batchDeletePlans(List<String> ids) =>
      delete('/admin/plans/batch', body: {'ids': ids});

  Future<Map<String, dynamic>> getPlanStock({String? planId}) async {
    final params = <String, String>{};
    if (planId != null) params['plan_id'] = planId;
    final res = await get('/admin/plans-stock', params: params.isNotEmpty ? params : null);
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  // ── Finance: Exchange Rates ──
  Future<Map<String, dynamic>> getExchangeRates() async {
    final res = await get('/admin/exchange-rates');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> setExchangeRate(String base, String target, String rate) =>
      post('/admin/exchange-rates', body: {'base_currency': base, 'target_currency': target, 'rate': rate});

  Future<Map<String, dynamic>> fetchExchangeRates() async {
    final res = await post('/admin/exchange-rates/fetch');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  // ── Server Config (official_currency, timezone, auto_fetch_interval) ──
  Future<Map<String, dynamic>> getServerConfig() async {
    final res = await get('/admin/server-config');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> updateServerConfig(Map<String, String> config) =>
      put('/admin/server-config', body: config);

  // ── Finance: Tax Rates ──
  Future<Map<String, dynamic>> getTaxRates() async {
    final res = await get('/admin/tax-rates');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> createTaxRate(String name, String percentage, {String description = ''}) =>
      post('/admin/tax-rates', body: {'name': name, 'percentage': percentage, 'description': description});

  Future<void> updateTaxRate(String id, Map<String, dynamic> data) => put('/admin/tax-rates/$id', body: data);

  // ── Finance: Coupons ──
  Future<Map<String, dynamic>> getCoupons() async {
    final res = await get('/admin/coupons');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> createCoupon(Map<String, dynamic> data) => post('/admin/coupons', body: data);

  Future<void> updateCoupon(String id, Map<String, dynamic> data) => put('/admin/coupons/$id', body: data);

  // ── Finance: Refunds ──
  Future<Map<String, dynamic>> getRefunds({int page = 1, int limit = 20}) async {
    final res = await get('/admin/refunds', params: {'page': '$page', 'limit': '$limit'});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> createRefund(String orderId, {int? amount, String reason = ''}) {
    final body = <String, dynamic>{'order_id': orderId, 'reason': reason};
    if (amount != null) body['amount'] = amount;
    return post('/admin/refunds', body: body);
  }

  // ── Finance: Freezes ──
  Future<Map<String, dynamic>> getFreezes({int page = 1, int limit = 20}) async {
    final res = await get('/admin/freezes', params: {'page': '$page', 'limit': '$limit'});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> createFreeze(String userId, int amount, {String reason = ''}) =>
      post('/admin/freezes', body: {'user_id': userId, 'amount': amount, 'reason': reason});

  Future<void> releaseFreeze(String freezeId) => post('/admin/freezes/$freezeId/release');

  // ── Finance: Reports ──
  Future<Map<String, dynamic>> getFinancialReport({String period = 'daily'}) async {
    final res = await get('/admin/reports/financial', params: {'period': period});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getWalletDashboardReport() async {
    final res = await get('/admin/reports/wallet');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  // ── Backup ──
  Future<http.Response> downloadBackup(String id) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/admin/backup/$id/download');
    return await _client.get(uri, headers: _headers).timeout(AppConstants.requestTimeout);
  }

  Future<void> updateBackupSetting(String key, String value) =>
      put('/admin/backup/settings/$key', body: {'value': value});

  // ── Inventory ──
  Future<Map<String, dynamic>> getInventoryBatches({int page = 1, int limit = 20}) async {
    final res = await get('/admin/inventory/batches', params: {'page': '$page', 'limit': '$limit'});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getInventory({int page = 1, int limit = 20, String? planId, String? status}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (planId != null) params['plan_id'] = planId;
    if (status != null) params['status'] = status;
    final res = await get('/admin/inventory/iccid', params: params);
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getInventoryStats({String? planId}) async {
    final params = <String, String>{};
    if (planId != null) params['plan_id'] = planId;
    final res = await get('/admin/inventory/stats', params: params.isNotEmpty ? params : null);
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> retryActivation(String inventoryId) => post('/admin/inventory/retry/$inventoryId');

  Future<Map<String, dynamic>> getExpiringInventory({int days = 7}) async {
    final res = await get('/admin/inventory/expiring', params: {'days': '$days'});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> purchaseInventory(String planId, int quantity) async {
    final res = await post('/admin/inventory/purchase', body: {'plan_id': planId, 'quantity': quantity});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  // ── Analytics Charts ──
  Future<Map<String, dynamic>> getSalesChart({int days = 30}) async {
    final res = await get('/admin/analytics/charts/sales', params: {'days': '$days'});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getPlansChart() async {
    final res = await get('/admin/analytics/charts/plans');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getUserGrowthChart({String period = 'daily'}) async {
    final res = await get('/admin/analytics/charts/users', params: {'period': period});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getAdminActivity({int page = 1, int limit = 20, String? action}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (action != null) params['action'] = action;
    final res = await get('/admin/analytics/activity', params: params);
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  // ── Inventory Import (multipart) ──
  Future<Map<String, dynamic>> importInventory(String planId, String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}/admin/inventory/import'),
    );
    // Add auth header only — Content-Type is set automatically by MultipartRequest
    if (_accessToken != null) request.headers['Authorization'] = 'Bearer $_accessToken';
    request.fields['plan_id'] = planId;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final streamed = await request.send().timeout(const Duration(seconds: 120));
    final body = await streamed.stream.bytesToString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    if (json['success'] == true) return (json['data'] as Map<String, dynamic>?) ?? {};
    throw ApiException(code: json['code'] ?? 'IMPORT_FAILED', status: json['status'] ?? 400, message: json['message']);
  }

  // ── 2FA ──
  Future<Map<String, dynamic>> setup2fa() async {
    final res = await post('/admin/2fa/setup');
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> enable2fa(String code) => post('/admin/2fa/enable', body: {'code': code});
  Future<void> disable2fa(String code) => post('/admin/2fa/disable', body: {'code': code});

  Future<Map<String, dynamic>> verify2fa(String code) async {
    final res = await post('/admin/2fa/verify', body: {'code': code});
    return (res.data as Map<String, dynamic>?) ?? {};
  }

  // ── Export Report ──
  Future<http.Response> exportReport(String type, {String format = 'csv', String? status, String? method}) async {
    final params = <String, String>{'format': format};
    if (status != null) params['status'] = status;
    if (method != null) params['method'] = method;
    final uri = Uri.parse('${AppConstants.baseUrl}/admin/analytics/reports/$type/export').replace(queryParameters: params);
    return await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 60));
  }
}
