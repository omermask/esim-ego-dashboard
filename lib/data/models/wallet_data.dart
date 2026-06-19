class WalletData {
  final String id;
  final String? userId;
  final int balance;
  final int frozenBalance;
  final int availableBalance;
  final String? createdAt;
  WalletData({required this.id, this.userId, this.balance = 0, this.frozenBalance = 0, this.availableBalance = 0, this.createdAt});
  factory WalletData.fromJson(Map<String, dynamic> json) => WalletData(
    id: json['id'] ?? '',
    userId: json['user_id'],
    balance: json['balance'] ?? 0,
    frozenBalance: json['frozen_balance'] ?? 0,
    availableBalance: json['available_balance'] ?? 0,
    createdAt: json['created_at'],
  );
}

class WalletTransaction {
  final String id;
  final int amount;
  final String type;
  final int balanceBefore;
  final int balanceAfter;
  final String? description;
  final String? referenceType;
  final String? referenceId;
  final String? createdAt;
  WalletTransaction({
    required this.id, this.amount = 0, this.type = '',
    this.balanceBefore = 0, this.balanceAfter = 0,
    this.description, this.referenceType, this.referenceId, this.createdAt,
  });
  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
    id: json['id'] ?? '',
    amount: json['amount'] ?? 0,
    type: json['type'] ?? '',
    balanceBefore: json['balance_before'] ?? 0,
    balanceAfter: json['balance_after'] ?? 0,
    description: json['description'],
    referenceType: json['reference_type'],
    referenceId: json['reference_id']?.toString(),
    createdAt: json['created_at'],
  );
}
