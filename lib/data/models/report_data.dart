class FinancialReport {
  final String period;
  final String start;
  final String end;
  final FinancialSummary summary;
  FinancialReport({this.period = '', this.start = '', this.end = '', this.summary = const FinancialSummary()});
  factory FinancialReport.fromJson(Map<String, dynamic> json) => FinancialReport(
    period: json['period'] ?? '',
    start: json['start'] ?? '',
    end: json['end'] ?? '',
    summary: FinancialSummary.fromJson(json['summary'] ?? {}),
  );
}

class FinancialSummary {
  final int totalOrders;
  final int grossRevenueIqd;
  final int totalCostIqd;
  final int totalDiscountIqd;
  final int totalTaxIqd;
  final int totalRefundedIqd;
  final int netRevenueIqd;
  final int totalDepositsIqd;
  final int newUsers;
  const FinancialSummary({
    this.totalOrders = 0, this.grossRevenueIqd = 0, this.totalCostIqd = 0,
    this.totalDiscountIqd = 0, this.totalTaxIqd = 0, this.totalRefundedIqd = 0,
    this.netRevenueIqd = 0, this.totalDepositsIqd = 0, this.newUsers = 0,
  });
  factory FinancialSummary.fromJson(Map<String, dynamic> json) => FinancialSummary(
    totalOrders: json['total_orders'] ?? 0,
    grossRevenueIqd: json['gross_revenue_iqd'] ?? 0,
    totalCostIqd: json['total_cost_iqd'] ?? 0,
    totalDiscountIqd: json['total_discount_iqd'] ?? 0,
    totalTaxIqd: json['total_tax_iqd'] ?? 0,
    totalRefundedIqd: json['total_refunded_iqd'] ?? 0,
    netRevenueIqd: json['net_revenue_iqd'] ?? 0,
    totalDepositsIqd: json['total_deposits_iqd'] ?? 0,
    newUsers: json['new_users'] ?? 0,
  );
}

class WalletDashboard {
  final int totalBalanceIqd;
  final int totalFrozenIqd;
  final int availableBalanceIqd;
  final int totalOrders;
  final int grossSalesIqd;
  final int totalCostIqd;
  final int totalRefundedIqd;
  final int netProfitIqd;
  WalletDashboard({
    this.totalBalanceIqd = 0, this.totalFrozenIqd = 0, this.availableBalanceIqd = 0,
    this.totalOrders = 0, this.grossSalesIqd = 0, this.totalCostIqd = 0,
    this.totalRefundedIqd = 0, this.netProfitIqd = 0,
  });
  factory WalletDashboard.fromJson(Map<String, dynamic> json) => WalletDashboard(
    totalBalanceIqd: json['total_balance_iqd'] ?? 0,
    totalFrozenIqd: json['total_frozen_iqd'] ?? 0,
    availableBalanceIqd: json['available_balance_iqd'] ?? 0,
    totalOrders: json['total_orders'] ?? 0,
    grossSalesIqd: json['gross_sales_iqd'] ?? 0,
    totalCostIqd: json['total_cost_iqd'] ?? 0,
    totalRefundedIqd: json['total_refunded_iqd'] ?? 0,
    netProfitIqd: json['net_profit_iqd'] ?? 0,
  );
}
