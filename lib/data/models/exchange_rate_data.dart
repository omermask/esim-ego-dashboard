class ExchangeRate {
  final String id;
  final String baseCurrency;
  final String targetCurrency;
  final String rate;
  final String source;
  ExchangeRate({required this.id, this.baseCurrency = 'USD', this.targetCurrency = 'IQD', this.rate = '0', this.source = ''});
  factory ExchangeRate.fromJson(Map<String, dynamic> json) => ExchangeRate(
    id: json['id'] ?? '',
    baseCurrency: json['base_currency'] ?? 'USD',
    targetCurrency: json['target_currency'] ?? 'IQD',
    rate: (json['rate'] ?? '0').toString(),
    source: json['source'] ?? '',
  );
}
