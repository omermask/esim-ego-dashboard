class Refund {
  final String id;
  final String orderId;
  final String? userId;
  final String? userName;
  final int amount;
  final String reason;
  final String status;
  final String? adminNote;
  final String? adminId;
  final String? createdAt;
  Refund({
    required this.id, this.orderId = '', this.userId, this.userName,
    this.amount = 0, this.reason = '', this.status = 'pending',
    this.adminNote, this.adminId, this.createdAt,
  });
  factory Refund.fromJson(Map<String, dynamic> json) => Refund(
    id: json['id'] ?? '', orderId: json['order_id'] ?? '',
    userId: json['user_id']?.toString(), userName: json['user_name'],
    amount: json['amount'] ?? 0, reason: json['reason'] ?? '',
    status: json['status'] ?? 'pending',     adminNote: json['admin_note'],
    adminId: json['admin_id']?.toString(), createdAt: json['created_at'],
  );
}
