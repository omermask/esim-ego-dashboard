class TaxRate {
  final String id;
  final String name;
  final String percentage;
  final bool isActive;
  final String description;
  TaxRate({required this.id, this.name = '', this.percentage = '0', this.isActive = true, this.description = ''});
  factory TaxRate.fromJson(Map<String, dynamic> json) => TaxRate(
    id: json['id'] ?? '', name: json['name'] ?? '',
    percentage: (json['percentage'] ?? '0').toString(),
    isActive: json['is_active'] ?? true, description: json['description'] ?? '',
  );
}
