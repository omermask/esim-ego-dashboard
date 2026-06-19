class SalesChartPoint {
  final String date;
  final int revenue;
  final int orderCount;
  SalesChartPoint({this.date = '', this.revenue = 0, this.orderCount = 0});
  factory SalesChartPoint.fromJson(Map<String, dynamic> json) => SalesChartPoint(
    date: json['date'] ?? '', revenue: json['revenue'] ?? 0, orderCount: json['order_count'] ?? 0,
  );
}

class PlansChartItem {
  final String name;
  final int orderCount;
  final int revenue;
  PlansChartItem({this.name = '', this.orderCount = 0, this.revenue = 0});
  factory PlansChartItem.fromJson(Map<String, dynamic> json) => PlansChartItem(
    name: json['name'] ?? '', orderCount: json['order_count'] ?? 0, revenue: json['revenue'] ?? 0,
  );
}

class UserGrowthPoint {
  final String period;
  final int count;
  UserGrowthPoint({this.period = '', this.count = 0});
  factory UserGrowthPoint.fromJson(Map<String, dynamic> json) => UserGrowthPoint(
    period: json['period'] ?? '', count: json['count'] ?? 0,
  );
}

class ActivityLog {
  final String id;
  final String? userId;
  final String? userName;
  final String action;
  final String? resourceType;
  final String? resourceId;
  final dynamic details;
  final String? ipAddress;
  final String? createdAt;
  ActivityLog({
    required this.id, this.userId, this.userName, this.action = '',
    this.resourceType, this.resourceId, this.details, this.ipAddress, this.createdAt,
  });
  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
    id: json['id'] ?? '', userId: json['user_id']?.toString(), userName: json['user_name'],
    action: json['action'] ?? '', resourceType: json['resource_type'],
    resourceId: json['resource_id']?.toString(), details: json['details'],
    ipAddress: json['ip_address'], createdAt: json['created_at'],
  );
}
