class AdminOrder {
  final String id;
  final String? userId;
  final String? userName;
  final String? userPhone;
  final String? planId;
  final String? planName;
  final int quantity;
  final int totalPriceIqd;
  final String currency;
  final String status;
  final int taxAmount;
  final String? taxRate;
  final int discountAmount;
  final String? couponCode;
  final int costPriceIqd;
  final int refundedAmount;
  final List<OrderItem> items;
  final String? createdAt;

  AdminOrder({
    required this.id, this.userId, this.userName, this.userPhone, this.planId, this.planName,
    this.quantity = 1, this.totalPriceIqd = 0, this.currency = 'IQD', this.status = 'pending',
    this.taxAmount = 0, this.taxRate, this.discountAmount = 0, this.couponCode,
    this.costPriceIqd = 0, this.refundedAmount = 0, this.items = const [], this.createdAt,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) => AdminOrder(
    id: json['id'] ?? '',
    userId: json['user_id'],
    userName: json['user_name'],
    userPhone: json['user_phone'],
    planId: json['plan_id'],
    planName: json['plan_name'],
    quantity: json['quantity'] ?? 1,
    totalPriceIqd: json['total_price_iqd'] ?? 0,
    currency: json['currency'] ?? 'IQD',
    status: json['status'] ?? 'pending',
    taxAmount: json['tax_amount'] ?? 0,
    taxRate: json['tax_rate'],
    discountAmount: json['discount_amount'] ?? 0,
    couponCode: json['coupon_code'],
    costPriceIqd: json['cost_price_iqd'] ?? 0,
    refundedAmount: json['refunded_amount'] ?? 0,
    items: (json['items'] as List?)?.map((e) => OrderItem.fromJson(e)).toList() ?? [],
    createdAt: json['created_at'],
  );

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pending';
      case 'paid': return 'Paid';
      case 'cancelled': return 'Cancelled';
      case 'refunded': return 'Refunded';
      case 'failed': return 'Failed';
      default: return status;
    }
  }
}

class OrderItem {
  final String id;
  final String? esimIccid;
  final String status;
  final String? activationCode;
  final String? qrCode;
  final String? orderId;
  final String? activatedAt;
  final String? expiresAt;
  bool get hasQrCode => qrCode != null && qrCode!.isNotEmpty;
  OrderItem({
    required this.id, this.esimIccid, this.status = 'pending',
    this.activationCode, this.qrCode, this.orderId,
    this.activatedAt, this.expiresAt,
  });
  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] ?? '',
    esimIccid: json['esim_iccid'],
    status: json['status'] ?? 'pending',
    activationCode: json['activation_code'],
    qrCode: json['qr_code'],
    orderId: json['order_id']?.toString(),
    activatedAt: json['activated_at'],
    expiresAt: json['expires_at'],
  );
}
