class Freeze {
  final String id;
  final String walletId;
  final String? userId;
  final String? userName;
  final int amount;
  final String reason;
  final String status;
  final String? releasedAt;
  final String? createdAt;
  Freeze({
    required this.id, this.walletId = '', this.userId, this.userName,
    this.amount = 0, this.reason = '', this.status = 'active',
    this.releasedAt, this.createdAt,
  });
  factory Freeze.fromJson(Map<String, dynamic> json) => Freeze(
    id: json['id'] ?? '', walletId: json['wallet_id'] ?? '',
    userId: json['user_id']?.toString(), userName: json['user_name'],
    amount: json['amount'] ?? 0, reason: json['reason'] ?? '',
    status: json['status'] ?? 'active', releasedAt: json['released_at'],
    createdAt: json['created_at'],
  );
}
