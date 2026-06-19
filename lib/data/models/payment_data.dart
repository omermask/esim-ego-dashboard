class AdminPayment {
  final String id;
  final String? userId;
  final String? userName;
  final String? userPhone;
  final String? orderId;
  final int amount;
  final String method;
  final String status;
  final String? providerTransactionId;
  final Map<String, dynamic>? providerData;
  final String? createdAt;

  AdminPayment({
    required this.id, this.userId, this.userName, this.userPhone, this.orderId,
    this.amount = 0, this.method = '', this.status = 'pending',
    this.providerTransactionId, this.providerData, this.createdAt,
  });

  factory AdminPayment.fromJson(Map<String, dynamic> json) => AdminPayment(
    id: json['id'] ?? '',
    userId: json['user_id'],
    userName: json['user_name'],
    userPhone: json['user_phone'],
    orderId: json['order_id'],
    amount: json['amount'] ?? 0,
    method: json['method'] ?? '',
    status: json['status'] ?? 'pending',
    providerTransactionId: json['provider_transaction_id'],
    providerData: json['provider_data'],
    createdAt: json['created_at'],
  );
}
