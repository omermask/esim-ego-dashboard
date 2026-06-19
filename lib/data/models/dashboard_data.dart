class DashboardData {
  final int totalUsers;
  final int totalOrders;
  final int totalPayments;
  final int totalRevenueIqd;

  DashboardData({this.totalUsers = 0, this.totalOrders = 0, this.totalPayments = 0, this.totalRevenueIqd = 0});

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    totalUsers: json['total_users'] ?? 0, totalOrders: json['total_orders'] ?? 0,
    totalPayments: json['total_payments'] ?? 0, totalRevenueIqd: json['total_revenue_iqd'] ?? 0,
  );
}

class AnalyticsData {
  final AnalyticsUsers users;
  final AnalyticsOrders orders;
  final AnalyticsSales sales;
  final AnalyticsFinancial financial;
  final List<TopPlan> topPlans;
  final List<RecentOrder> recentOrders;

  AnalyticsData({
    this.users = const AnalyticsUsers(), this.orders = const AnalyticsOrders(),
    this.sales = const AnalyticsSales(), this.financial = const AnalyticsFinancial(),
    this.topPlans = const [], this.recentOrders = const [],
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) => AnalyticsData(
    users: AnalyticsUsers.fromJson(json['users'] ?? {}),
    orders: AnalyticsOrders.fromJson(json['orders'] ?? {}),
    sales: AnalyticsSales.fromJson(json['sales'] ?? {}),
    financial: AnalyticsFinancial.fromJson(json['financial'] ?? {}),
    topPlans: (json['top_plans'] as List?)?.map((e) => TopPlan.fromJson(e)).toList() ?? [],
    recentOrders: (json['recent_orders'] as List?)?.map((e) => RecentOrder.fromJson(e)).toList() ?? [],
  );
}

class AnalyticsUsers {
  final int total;
  final int active;
  final int newToday;
  final int newWeek;
  final int newMonth;
  const AnalyticsUsers({this.total = 0, this.active = 0, this.newToday = 0, this.newWeek = 0, this.newMonth = 0});
  factory AnalyticsUsers.fromJson(Map<String, dynamic> json) => AnalyticsUsers(
    total: json['total'] ?? 0, active: json['active'] ?? 0,
    newToday: json['new_today'] ?? 0, newWeek: json['new_week'] ?? 0, newMonth: json['new_month'] ?? 0,
  );
}

class AnalyticsOrders {
  final int total;
  final int paid;
  const AnalyticsOrders({this.total = 0, this.paid = 0});
  factory AnalyticsOrders.fromJson(Map<String, dynamic> json) => AnalyticsOrders(
    total: json['total'] ?? 0, paid: json['paid'] ?? 0,
  );
}

class AnalyticsSales {
  final int today;
  final int week;
  final int month;
  const AnalyticsSales({this.today = 0, this.week = 0, this.month = 0});
  factory AnalyticsSales.fromJson(Map<String, dynamic> json) => AnalyticsSales(
    today: json['today'] ?? 0, week: json['week'] ?? 0, month: json['month'] ?? 0,
  );
}

class AnalyticsFinancial {
  final int totalRevenue;
  final int totalCost;
  final int totalDiscount;
  final int totalRefunded;
  final int netProfit;
  const AnalyticsFinancial({this.totalRevenue = 0, this.totalCost = 0, this.totalDiscount = 0, this.totalRefunded = 0, this.netProfit = 0});
  factory AnalyticsFinancial.fromJson(Map<String, dynamic> json) => AnalyticsFinancial(
    totalRevenue: json['total_revenue'] ?? 0, totalCost: json['total_cost'] ?? 0,
    totalDiscount: json['total_discount'] ?? 0, totalRefunded: json['total_refunded'] ?? 0,
    netProfit: json['net_profit'] ?? 0,
  );
}

class TopPlan {
  final String name;
  final int orderCount;
  final int revenue;
  TopPlan({this.name = '', this.orderCount = 0, this.revenue = 0});
  factory TopPlan.fromJson(Map<String, dynamic> json) => TopPlan(
    name: json['name'] ?? '', orderCount: json['order_count'] ?? 0, revenue: json['revenue'] ?? 0,
  );
}

class RecentOrder {
  final String id;
  final String? userName;
  final String? userPhone;
  final String? planName;
  final int totalPriceIqd;
  final String status;
  final String? createdAt;
  RecentOrder({required this.id, this.userName, this.userPhone, this.planName, this.totalPriceIqd = 0, this.status = '', this.createdAt});
  factory RecentOrder.fromJson(Map<String, dynamic> json) => RecentOrder(
    id: json['id'] ?? '', userName: json['user_name'], userPhone: json['user_phone'],
    planName: json['plan_name'], totalPriceIqd: json['total_price_iqd'] ?? 0,
    status: json['status'] ?? '', createdAt: json['created_at'],
  );
}
