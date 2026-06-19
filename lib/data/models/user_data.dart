class AdminUser {
  final String id;
  final String phone;
  final String name;
  final String role;
  final bool isActive;
  final bool isVerified;
  final String language;
  final String? timezone;
  final int failedOtpAttempts;
  final String? createdAt;
  final String? lastLoginAt;

  AdminUser({
    required this.id, required this.phone, required this.name, this.role = 'user',
    this.isActive = true, this.isVerified = false, this.language = 'en',
    this.timezone, this.failedOtpAttempts = 0, this.createdAt, this.lastLoginAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'] ?? '',
    phone: json['phone'] ?? '',
    name: json['name'] ?? '',
    role: json['role'] ?? 'user',
    isActive: json['is_active'] ?? true,
    isVerified: json['is_verified'] ?? false,
    language: json['language'] ?? 'en',
    timezone: json['timezone'],
    failedOtpAttempts: json['failed_otp_attempts'] ?? 0,
    createdAt: json['created_at'],
    lastLoginAt: json['last_login_at'],
  );

  String get roleLabel {
    switch (role) {
      case 'superadmin': return 'Super Admin';
      case 'admin': return 'Admin';
      default: return role;
    }
  }
}
