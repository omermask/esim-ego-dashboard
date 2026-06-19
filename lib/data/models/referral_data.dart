class ReferralSettings {
  final bool isActive;
  final int rewardAmount;
  final String qualifyCondition;
  final int qualifyMinAmount;
  final bool autoCredit;
  ReferralSettings({
    this.isActive = false, this.rewardAmount = 0,
    this.qualifyCondition = 'any_order', this.qualifyMinAmount = 0, this.autoCredit = false,
  });
  factory ReferralSettings.fromJson(Map<String, dynamic> json) => ReferralSettings(
    isActive: json['is_active'] ?? false, rewardAmount: json['reward_amount'] ?? 0,
    qualifyCondition: json['qualify_condition'] ?? 'any_order',
    qualifyMinAmount: json['qualify_min_amount'] ?? 0, autoCredit: json['auto_credit'] ?? false,
  );
}

class ReferralReward {
  final String id;
  final ReferralUser? referrer;
  final ReferralUser? referred;
  final int amount;
  final String status;
  final String? qualifyCondition;
  final int? qualifyThreshold;
  final bool autoCredit;
  final String? notes;
  final String? creditedAt;
  final String? createdAt;
  ReferralReward({
    required this.id, this.referrer, this.referred, this.amount = 0,
    this.status = '', this.qualifyCondition, this.qualifyThreshold, this.autoCredit = false,
    this.notes, this.creditedAt, this.createdAt,
  });
  factory ReferralReward.fromJson(Map<String, dynamic> json) => ReferralReward(
    id: json['id'] ?? '',
    referrer: json['referrer'] != null ? ReferralUser.fromJson(json['referrer']) : null,
    referred: json['referred'] != null ? ReferralUser.fromJson(json['referred']) : null,
    amount: json['amount'] ?? 0, status: json['status'] ?? '',
    qualifyCondition: json['qualify_condition'], qualifyThreshold: json['qualify_threshold'],
    autoCredit: json['auto_credit'] ?? false, notes: json['notes'],
    creditedAt: json['credited_at'], createdAt: json['created_at'],
  );
}

class ReferralUser {
  final String id;
  final String name;
  final String phone;
  ReferralUser({required this.id, this.name = '', this.phone = ''});
  factory ReferralUser.fromJson(Map<String, dynamic> json) => ReferralUser(
    id: json['id'] ?? '', name: json['name'] ?? '', phone: json['phone'] ?? '',
  );
}

class ReferralStats {
  final int totalReferrals;
  final int totalCredited;
  final int totalQualified;
  final int totalPending;
  final int totalCancelled;
  final int totalAmountCredited;
  final int totalAmountQualified;
  final int usersWithReferrals;
  ReferralStats({
    this.totalReferrals = 0, this.totalCredited = 0, this.totalQualified = 0,
    this.totalPending = 0, this.totalCancelled = 0, this.totalAmountCredited = 0,
    this.totalAmountQualified = 0, this.usersWithReferrals = 0,
  });
  factory ReferralStats.fromJson(Map<String, dynamic> json) => ReferralStats(
    totalReferrals: json['total_referrals'] ?? 0,
    totalCredited: json['total_credited'] ?? 0,
    totalQualified: json['total_qualified'] ?? 0,
    totalPending: json['total_pending'] ?? 0,
    totalCancelled: json['total_cancelled'] ?? 0,
    totalAmountCredited: json['total_amount_credited'] ?? 0,
    totalAmountQualified: json['total_amount_qualified'] ?? 0,
    usersWithReferrals: json['users_with_referrals'] ?? 0,
  );
}
