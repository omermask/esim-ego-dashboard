class SystemSetting {
  final String id;
  final String key;
  final String value;
  final String description;
  final String? updatedAt;
  SystemSetting({this.id = '', required this.key, required this.value, this.description = '', this.updatedAt});
  factory SystemSetting.fromJson(Map<String, dynamic> json) => SystemSetting(
    id: json['id'] ?? '', key: json['key'] ?? '', value: json['value'] ?? '',
    description: json['description'] ?? '', updatedAt: json['updated_at'],
  );
}
