class ImportBatch {
  final String id;
  final String filename;
  final String planId;
  final String planName;
  final int totalCount;
  final int successCount;
  final int errorCount;
  final String status;
  final String createdBy;
  final String? createdAt;
  final String? completedAt;
  ImportBatch({
    required this.id, this.filename = '', this.planId = '', this.planName = '',
    this.totalCount = 0, this.successCount = 0, this.errorCount = 0,
    this.status = 'pending', this.createdBy = '', this.createdAt, this.completedAt,
  });
  factory ImportBatch.fromJson(Map<String, dynamic> json) => ImportBatch(
    id: json['id'] ?? '', filename: json['filename'] ?? '',
    planId: json['plan_id'] ?? '', planName: json['plan_name'] ?? '',
    totalCount: json['total_count'] ?? 0, successCount: json['success_count'] ?? 0,
    errorCount: json['error_count'] ?? 0, status: json['status'] ?? 'pending',
    createdBy: json['created_by'] ?? '', createdAt: json['created_at'],
    completedAt: json['completed_at'],
  );
}

class EsimInventory {
  final String id;
  final String iccid;
  final String planId;
  final String planName;
  final String status;
  final String? batchId;
  final String? orderItemId;
  final String? soldAt;
  final String? activatedAt;
  final String? expiresAt;
  final int activationRetries;
  final String? lastError;
  final int dataUsageMb;
  final String? suspendedAt;
  final String? revokedAt;
  final String? createdAt;
  EsimInventory({
    required this.id, this.iccid = '', this.planId = '', this.planName = '',
    this.status = 'available', this.batchId, this.orderItemId,
    this.soldAt, this.activatedAt, this.expiresAt,
    this.activationRetries = 0, this.lastError, this.dataUsageMb = 0,
    this.suspendedAt, this.revokedAt, this.createdAt,
  });
  factory EsimInventory.fromJson(Map<String, dynamic> json) => EsimInventory(
    id: json['id'] ?? '', iccid: json['iccid'] ?? '',
    planId: json['plan_id'] ?? '', planName: json['plan_name'] ?? '',
    status: json['status'] ?? 'available', batchId: json['batch_id'],
    orderItemId: json['order_item_id'], soldAt: json['sold_at'],
    activatedAt: json['activated_at'], expiresAt: json['expires_at'],
    activationRetries: json['activation_retries'] ?? 0,
    lastError: json['last_error'], dataUsageMb: json['data_usage_mb'] ?? 0,
    suspendedAt: json['suspended_at'], revokedAt: json['revoked_at'],
    createdAt: json['created_at'],
  );
}

class ExpiringEsim {
  final String id;
  final String iccid;
  final String planName;
  final String? expiresAt;
  ExpiringEsim({required this.id, this.iccid = '', this.planName = '', this.expiresAt});
  factory ExpiringEsim.fromJson(Map<String, dynamic> json) => ExpiringEsim(
    id: json['id'] ?? '', iccid: json['iccid'] ?? '',
    planName: json['plan_name'] ?? '', expiresAt: json['expires_at'],
  );
}

class InventoryStats {
  final int total;
  final int available;
  final int sold;
  final int processing;
  final int activated;
  final int expired;
  final int suspended;
  final int revoked;
  InventoryStats({
    this.total = 0, this.available = 0, this.sold = 0, this.processing = 0,
    this.activated = 0, this.expired = 0, this.suspended = 0, this.revoked = 0,
  });
  factory InventoryStats.fromJson(Map<String, dynamic> json) => InventoryStats(
    total: json['total'] ?? 0, available: json['available'] ?? 0,
    sold: json['sold'] ?? 0, processing: json['processing'] ?? 0,
    activated: json['activated'] ?? 0, expired: json['expired'] ?? 0,
    suspended: json['suspended'] ?? 0, revoked: json['revoked'] ?? 0,
  );
}
