class BackupRecord {
  final String id;
  final String filename;
  final int fileSize;
  final String? filepath;
  final String? fileSizeHuman;
  final String status;
  final String backupType;
  final String? createdBy;
  final String? notes;
  final String? completedAt;
  final String? createdAt;
  BackupRecord({
    required this.id, this.filename = '', this.fileSize = 0, this.filepath,
    this.fileSizeHuman, this.status = '', this.backupType = '',
    this.createdBy, this.notes, this.completedAt, this.createdAt,
  });
  factory BackupRecord.fromJson(Map<String, dynamic> json) => BackupRecord(
    id: json['id'] ?? '', filename: json['filename'] ?? '',
    fileSize: json['file_size'] ?? 0, filepath: json['filepath'],
    fileSizeHuman: json['file_size_human'],
    status: json['status'] ?? '', backupType: json['backup_type'] ?? '',
    createdBy: json['created_by'], notes: json['notes'],
    completedAt: json['completed_at'], createdAt: json['created_at'],
  );
}

class BackupSettings {
  final bool enabled;
  final int intervalHours;
  final int retentionDays;
  final String path;
  final bool encrypt;
  final BackupFilesystem? filesystem;
  BackupSettings({
    this.enabled = false, this.intervalHours = 0, this.retentionDays = 0,
    this.path = '', this.encrypt = false, this.filesystem,
  });
  factory BackupSettings.fromJson(Map<String, dynamic> json) => BackupSettings(
    enabled: json['enabled'] ?? false, intervalHours: json['interval_hours'] ?? 0,
    retentionDays: json['retention_days'] ?? 0, path: json['path'] ?? '',
    encrypt: json['encrypt'] ?? false,
    filesystem: json['filesystem'] != null ? BackupFilesystem.fromJson(json['filesystem']) : null,
  );
}

class BackupFilesystem {
  final String path;
  final int totalBytes;
  final int usedBytes;
  final int freeBytes;
  final String? freeHuman;
  final double usagePercent;
  BackupFilesystem({
    this.path = '', this.totalBytes = 0, this.usedBytes = 0, this.freeBytes = 0,
    this.freeHuman, this.usagePercent = 0,
  });
  factory BackupFilesystem.fromJson(Map<String, dynamic> json) => BackupFilesystem(
    path: json['path'] ?? '', totalBytes: json['total_bytes'] ?? 0,
    usedBytes: json['used_bytes'] ?? 0, freeBytes: json['free_bytes'] ?? 0,
    freeHuman: json['free_human'], usagePercent: (json['usage_percent'] ?? 0).toDouble(),
  );
}

class BackupStatus {
  final int totalBackups;
  final String totalBackupSizeFormatted;
  final bool autoBackupEnabled;
  final DateTime? lastBackupAt;

  BackupStatus({
    this.totalBackups = 0,
    this.totalBackupSizeFormatted = '0 B',
    this.autoBackupEnabled = false,
    this.lastBackupAt,
  });
}
