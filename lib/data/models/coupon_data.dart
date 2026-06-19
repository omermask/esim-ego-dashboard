class Coupon {
  final String id;
  final String code;
  final String discountType;
  final String discountValue;
  final int maxUses;
  final int usedCount;
  final int minOrderAmount;
  final int maxDiscountAmount;
  final List<String> applicablePlanIds;
  final bool isActive;
  final String? expiresAt;
  Coupon({
    required this.id, this.code = '', this.discountType = 'percentage',
    this.discountValue = '0', this.maxUses = 0, this.usedCount = 0,
    this.minOrderAmount = 0, this.maxDiscountAmount = 0,
    this.applicablePlanIds = const [], this.isActive = true, this.expiresAt,
  });
  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    id: json['id'] ?? '', code: json['code'] ?? '',
    discountType: json['discount_type'] ?? 'percentage',
    discountValue: (json['discount_value'] ?? '0').toString(),
    maxUses: json['max_uses'] ?? 0, usedCount: json['used_count'] ?? 0,
    minOrderAmount: json['min_order_amount'] ?? 0,
    maxDiscountAmount: json['max_discount_amount'] ?? 0,
    applicablePlanIds: json['applicable_plan_ids'] is List
        ? (json['applicable_plan_ids'] as List).map((e) => e.toString()).toList()
        : json['applicable_plan_ids'] is String
            ? (json['applicable_plan_ids'] as String).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
            : [],
    isActive: json['is_active'] ?? true, expiresAt: json['expires_at'],
  );
}
