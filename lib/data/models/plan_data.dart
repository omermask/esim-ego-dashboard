class AdminPlan {
  final String id;
  final String name;
  final String description;
  final int dataAmountMb;
  final int durationDays;
  final double priceUsd;
  final int priceIqd;
  final double markupPercentage;
  final String countries;
  final String providerBundleId;
  final bool isActive;
  final int sortOrder;
  final String? createdAt;
  final String? updatedAt;

  AdminPlan({
    required this.id, required this.name, this.description = '', this.dataAmountMb = 0,
    this.durationDays = 0, this.priceUsd = 0, this.priceIqd = 0,
    this.markupPercentage = 20, this.countries = 'all', this.providerBundleId = '',
    this.isActive = true, this.sortOrder = 0, this.createdAt, this.updatedAt,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory AdminPlan.fromJson(Map<String, dynamic> json) => AdminPlan(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    dataAmountMb: (json['data_amount_mb'] ?? 0).toInt(),
    durationDays: (json['duration_days'] ?? 0).toInt(),
    priceUsd: _toDouble(json['price_usd']),
    priceIqd: (json['price_iqd'] ?? 0).toInt(),
    markupPercentage: _toDouble(json['markup_percentage']),
    countries: json['countries'] ?? 'all',
    providerBundleId: json['provider_bundle_id'] ?? '',
    isActive: json['is_active'] ?? true,
    sortOrder: (json['sort_order'] ?? 0).toInt(),
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}
