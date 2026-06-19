import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/plan_data.dart';

class CatalogueBundle {
  final String name;
  final String? description;
  final int dataAmount;
  final int duration;
  final double price;
  final List<String> countries;
  final List<String> regions;
  final List<String> groups;
  final Map<String, dynamic> raw;

  CatalogueBundle({
    required this.name,
    this.description,
    this.dataAmount = 0,
    this.duration = 0,
    this.price = 0,
    this.countries = const [],
    this.regions = const [],
    this.groups = const [],
    this.raw = const {},
  });

  factory CatalogueBundle.fromJson(Map<String, dynamic> json) {
    List<String> countriesList = [];
    final regionsSet = <String>{};
    if (json['countries'] is List) {
      for (final c in json['countries'] as List) {
        if (c is Map) {
          final name = c['name']?.toString();
          if (name != null && name.isNotEmpty) countriesList.add(name);
          final region = c['region']?.toString();
          if (region != null && region.isNotEmpty) regionsSet.add(region);
        } else {
          final s = c.toString();
          if (s.isNotEmpty) countriesList.add(s);
        }
      }
    }

    final groupsList = <String>[];
    final groupsRaw = json['groups'] ?? json['group'];
    if (groupsRaw is List) {
      for (final g in groupsRaw) {
        if (g is String && g.isNotEmpty) groupsList.add(g);
      }
    }

    int data = _parseInt(json['dataAmount'] ?? json['data_amount_mb'] ?? 0);
    int dur = _parseInt(json['duration'] ?? json['durationDays'] ?? json['duration_days'] ?? 0);
    double pr = _parseDouble(json['price'] ?? json['priceUsd'] ?? json['price_usd'] ?? 0);

    if (json['allowances'] is Map) {
      final a = json['allowances'] as Map;
      if (data == 0) {
        data = _parseInt(a['data'] ?? a['Data'] ?? a['DATA'] ?? a['amount'] ?? 0);
      }
      if (dur == 0) {
        dur = _parseInt(a['validity'] ?? a['Validity'] ?? a['duration'] ?? a['Duration'] ?? 0);
      }
    }

    return CatalogueBundle(
      name: json['name'] ?? json['id'] ?? '',
      description: json['description'] ?? json['Description'],
      dataAmount: data,
      duration: dur,
      price: pr,
      countries: countriesList,
      regions: regionsSet.toList(),
      groups: groupsList,
      raw: json,
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class PlansProvider extends ChangeNotifier {
  final ApiService api;
  PlansProvider(this.api);

  List<AdminPlan> _plans = [];
  List<CatalogueBundle> _catalogue = [];
  List<Map<String, dynamic>> _networkList = [];
  bool _loading = false;
  bool _catalogueLoading = false;
  bool _buildingIndex = false;
  String? _error;
  String? _catalogueError;
  Map<String, dynamic>? _catalogueBundleDetail;

  List<AdminPlan> get plans => _plans;
  List<CatalogueBundle> get catalogue => _catalogue;
  List<Map<String, dynamic>> get networkList => _networkList;
  bool get loading => _loading;
  bool get catalogueLoading => _catalogueLoading;
  bool get buildingIndex => _buildingIndex;
  String? get error => _error;
  String? get catalogueError => _catalogueError;
  Map<String, dynamic>? get catalogueBundleDetail => _catalogueBundleDetail;

  Future<void> load() async {
    _loading = true; _error = null; notifyListeners();
    try {
      final d = await api.getPlans();
      _plans = (d['items'] as List?)?.map((e) => AdminPlan.fromJson(e)).toList() ?? [];
      if (_plans.isEmpty && d['plans'] != null) {
        _plans = (d['plans'] as List).map((e) => AdminPlan.fromJson(e)).toList();
      }
      if (_plans.isEmpty && d['data'] != null) {
        _plans = (d['data'] as List).map((e) => AdminPlan.fromJson(e)).toList();
      }
    } on ApiException catch (e) { _error = e.userMessage; }
    catch (_) { _error = 'Failed to load plans'; }
    _loading = false; notifyListeners();
  }

  Future<void> loadCatalogue({bool force = false}) async {
    _catalogueLoading = true;
    _catalogueError = null;
    notifyListeners();
    try {
      final d = await api.getCatalogue(allPages: true, force: force);
      final bundles = (d['bundles'] as List?) ?? (d['items'] as List?);
      if (bundles != null) {
        if (bundles.isNotEmpty) {
          final first = bundles[0] as Map<String, dynamic>;
          debugPrint('[Catalogue] Total bundles: ${bundles.length}');
          debugPrint('[Catalogue] Keys (${first.length}): ${first.keys.join(", ")}');
        }
        _catalogue = bundles.map((e) => CatalogueBundle.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        _catalogue = [];
      }
      final warning = d['warning'] as String?;
      if (warning != null) debugPrint('[Catalogue] Warning: $warning');
    } on ApiException catch (e) {
      _catalogueError = e.userMessage;
      _catalogue = [];
    } catch (e) {
      _catalogueError = e.toString();
      _catalogue = [];
    }
    _catalogueLoading = false; notifyListeners();
  }

  Future<Map<String, dynamic>> importFromCatalogue(List<String> bundleNames) async {
    try {
      final result = await api.importCatalogueBundles(bundleNames);
      await load();
      return result;
    } on ApiException catch (e) {
      return {'error': e.userMessage};
    } catch (_) {
      return {'error': 'Failed to import bundles'};
    }
  }

  Future<void> loadNetworks() async {
    try {
      final d = await api.getCatalogueNetworks();
      _networkList = (d['networks'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      notifyListeners();
    } catch (_) {
      // silently fail
    }
  }

  Future<Map<String, dynamic>> buildNetworkIndex() async {
    if (_buildingIndex) return {'error': 'already_building'};
    _buildingIndex = true;
    notifyListeners();
    try {
      final result = await api.buildNetworkIndex();
      await loadNetworks();
      return result;
    } catch (e) {
      return {'error': e.toString()};
    } finally {
      _buildingIndex = false;
      notifyListeners();
    }
  }

  Future<void> loadCatalogueWithNetwork(String network) async {
    _catalogueLoading = true;
    _catalogueError = null;
    notifyListeners();
    try {
      final d = await api.getCatalogue(allPages: true, network: network);
      final bundles = (d['bundles'] as List?) ?? (d['items'] as List?);
      if (bundles != null) {
        _catalogue = bundles.map((e) => CatalogueBundle.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        _catalogue = [];
      }
    } on ApiException catch (e) {
      _catalogueError = e.userMessage;
      _catalogue = [];
    } catch (e) {
      _catalogueError = e.toString();
      _catalogue = [];
    }
    _catalogueLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchBundleDetail(String name) async {
    try {
      final d = await api.getCatalogueBundle(name);
      _catalogueBundleDetail = d;
      notifyListeners();
      return d;
    } catch (_) {
      return null;
    }
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try { await api.createPlan(data); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> update(String id, Map<String, dynamic> data) async {
    try { await api.updatePlan(id, data); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> delete(String id) async {
    try { await api.deletePlan(id); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> deleteAll() async {
    try {
      await api.deleteAllPlans();
      await load();
      return null;
    } on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> activateAll() async {
    try {
      final updates = _plans.map((p) => {'id': p.id, 'is_active': true}).toList();
      if (updates.isEmpty) return null;
      await api.batchUpdatePlans(updates);
      await load();
      return null;
    } on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> deactivateAll() async {
    try {
      final updates = _plans.map((p) => {'id': p.id, 'is_active': false}).toList();
      if (updates.isEmpty) return null;
      await api.batchUpdatePlans(updates);
      await load();
      return null;
    } on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }

  Future<String?> sync() async {
    try { await api.syncPlans(); await load(); return null; }
    on ApiException catch (e) { return e.userMessage; }
    catch (_) { return 'Failed'; }
  }
}
