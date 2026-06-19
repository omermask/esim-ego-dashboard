import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/dashboard_provider.dart';
import '../../data/providers/analytics_provider.dart';
import '../../data/providers/theme_provider.dart';
import '../../data/providers/locale_provider.dart';
import '../../data/providers/plans_provider.dart';
import '../../data/models/plan_data.dart';
import '../login/phone_entry_screen.dart';
import '../plans/create_plan_widget.dart';
import '../plans/inventory_widget.dart';
import '../plans/pricing_widget.dart';
import '../plans/provider_catalogue_screen.dart';
import '../plans/plan_detail_widget.dart';
import '../orders/order_list_widget.dart';
import '../users/user_list_widget.dart';
import '../support/ticket_list_widget.dart';
import '../more/payments_widget.dart';
import '../more/coupons_widget.dart';
import '../more/tax_rates_widget.dart';
import '../more/refunds_widget.dart';
import '../more/referrals_widget.dart';
import '../more/freezes_widget.dart';
import '../more/audit_log_widget.dart';
import '../more/reports_widget.dart';
import '../more/backups_widget.dart';
import '../more/twofa_widget.dart';
import '../more/exchange_rate_widget.dart';
import '../more/admin_activity_widget.dart';
import '../more/profile_widget.dart';
import '../more/wallet_dashboard_widget.dart';
import '../more/system_settings_widget.dart';
import '../settings/server_settings_widget.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/custom_loader.dart';
import '../../core/widgets/language_selection_dialog.dart';
import '../../data/models/dashboard_data.dart';
import '../../data/models/analytics_data.dart';

class _TabInfo {
  final String icon;
  final String label;
  final Widget widget;
  const _TabInfo({required this.icon, required this.label, required this.widget});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  List<_TabInfo> _buildTabList() {
    return [
      _TabInfo(
        icon: 'assets/images/home_icon.svg',
        label: trans(context, 'Home'),
        widget: const _HomeTab(),
      ),
      _TabInfo(
        icon: 'assets/icons/virtual_card.svg',
        label: trans(context, 'Plans'),
        widget: const _PlansTab(),
      ),
      _TabInfo(
        icon: 'assets/icons/activity_icon_183944.svg',
        label: trans(context, 'Orders'),
        widget: const _OrdersTab(),
      ),
      _TabInfo(
        icon: 'assets/icons/user_icon_242161.svg',
        label: trans(context, 'Users'),
        widget: const _UsersTab(),
      ),
      _TabInfo(
        icon: 'assets/icons/trush_square_icon_242180.svg',
        label: trans(context, 'More'),
        widget: const _MoreTab(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sc = context.screenColors;

    final tabs = _buildTabList();
    final maxIndex = tabs.length - 1;
    final safeIndex = _currentIndex > maxIndex ? 0 : _currentIndex;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: sc.bg,
        body: SafeArea(
          top: true,
          bottom: false,
          child: IndexedStack(
            index: safeIndex,
            children: tabs.map((t) => t.widget).toList(),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(isDark, safeIndex, tabs),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark, int safeIndex, List<_TabInfo> tabs) {
    final dc = context.dialogColors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: rs(context, 16),
          right: rs(context, 16),
          bottom: rs(context, 6),
        ),
        child: Container(
          height: rs(context, 64),
          decoration: BoxDecoration(
            color: dc.bg,
            borderRadius: BorderRadius.all(Radius.circular(rs(context, 40))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < tabs.length; i++)
                _buildNavItem(
                  isDark: isDark,
                  index: i,
                  icon: tabs[i].icon,
                  label: tabs[i].label,
                  isSelected: safeIndex == i,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required bool isDark,
    required int index,
    required String icon,
    required String label,
    required bool isSelected,
  }) {
    final dc = context.dialogColors;
    final color = isSelected ? dc.accent : dc.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: rs(context, 22),
              height: rs(context, 22),
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SizedBox(height: rs(context, 4)),
            Text(
              label,
              style: TextStyle(
                fontSize: rs(context, 10),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// _HomeTab - Comprehensive Analytics Dashboard
// ================================================================

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _PieItem {
  final String label;
  final double value;
  _PieItem(this.label, this.value);
}

class _HomeTabState extends State<_HomeTab> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dash = context.read<DashboardProvider>();
      if (dash.data.totalUsers == 0) {
        dash.refresh().then((_) { if (mounted) setState(() => _loaded = true); });
      } else {
        _loaded = true;
      }
      final ap = context.read<AnalyticsProvider>();
      ap.loadSalesChart();
      ap.loadPlansChart();
      ap.loadUserGrowth();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<DashboardProvider>().refresh(),
      context.read<AnalyticsProvider>().loadSalesChart(),
      context.read<AnalyticsProvider>().loadPlansChart(),
      context.read<AnalyticsProvider>().loadUserGrowth(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final ap = context.watch<AnalyticsProvider>();

    if (!_loaded || (dash.loading && dash.data.totalUsers == 0)) {
      return const Center(child: CustomLoader());
    }

    if (dash.error != null) {
      return _buildError(dash);
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(rs(context, 16), rs(context, 16), rs(context, 16), rs(context, 100)),
        child: _buildMainCard(dash, ap),
      ),
    );
  }

  Widget _buildError(DashboardProvider dash) {
    final dc = context.dialogColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: rs(context, 80)),
          Icon(Icons.warning_amber_rounded,
            size: rs(context, 48), color: dc.textSecondary,
          ),
          SizedBox(height: rs(context, 16)),
          Text(dash.error ?? 'Failed to load dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 14)),
          ),
          SizedBox(height: rs(context, 16)),
          GestureDetector(
            onTap: () => context.read<DashboardProvider>().refresh(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 24), vertical: rs(context, 12)),
              decoration: BoxDecoration(
                color: dc.accent,
                borderRadius: BorderRadius.circular(rs(context, 12)),
              ),
              child: Text(trans(context, 'Retry'),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(DashboardProvider dash, AnalyticsProvider ap) {
    final dc = context.dialogColors;
    final d = dash.data;
    final a = dash.analytics;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 14)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(dc, 'Overview', 'assets/images/home_icon.svg'),
          SizedBox(height: rs(context, 16)),
          _buildOverviewRow(d, a, dc),
          SizedBox(height: rs(context, 20)),

          _buildSectionTitle(dc, trans(context, 'Users'), 'assets/icons/profile_user.svg'),
          SizedBox(height: rs(context, 10)),
          _buildUsersGrid(a, dc),
          SizedBox(height: rs(context, 20)),

          _buildSectionTitle(dc, trans(context, 'Orders'), 'assets/icons/activity_icon_183944.svg'),
          SizedBox(height: rs(context, 10)),
          _buildOrdersGrid(a, d, dc),
          SizedBox(height: rs(context, 20)),

          _buildSectionTitle(dc, trans(context, 'Revenue'), 'assets/icons/moneys_icon_242132.svg'),
          SizedBox(height: rs(context, 10)),
          _buildFinancialGrid(a, dc),
          SizedBox(height: rs(context, 20)),

          if (ap.plansChart.isNotEmpty) ...[
            _buildSectionTitle(dc, trans(context, 'Top Plans'), 'assets/icons/virtual_card.svg'),
            SizedBox(height: rs(context, 10)),
            _buildPlansChart(ap, dc),
            SizedBox(height: rs(context, 20)),
          ],

          if (ap.salesChart.isNotEmpty) ...[
            _buildSectionTitle(dc, 'Sales (30 Days)', 'assets/icons/trend_up_icon_242025.svg'),
            SizedBox(height: rs(context, 10)),
            _buildSalesChart(ap, dc),
            SizedBox(height: rs(context, 20)),
          ],

          if (ap.userGrowth.isNotEmpty) ...[
            _buildSectionTitle(dc, 'User Growth', 'assets/icons/profile_add_icon_242075.svg'),
            SizedBox(height: rs(context, 10)),
            _buildUserGrowthChart(ap, dc),
            SizedBox(height: rs(context, 20)),
          ],

          SizedBox(height: rs(context, 60)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(StroappDialogColors dc, String title, String iconPath) {
    return Row(
      children: [
        _svgIcon(iconPath, rs(context, 18), dc.accent),
        SizedBox(width: rs(context, 8)),
        Text(title, style: TextStyle(
          fontSize: rs(context, 15),
          fontWeight: FontWeight.w700,
          color: dc.textPrimary,
        )),
      ],
    );
  }

  SizedBox _svgIcon(String path, double size, Color color) {
    return SizedBox(
      width: size, height: size,
      child: SvgPicture.asset(path, width: size, height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildOverviewRow(DashboardData d, AnalyticsData a, StroappDialogColors dc) {
    final items = [
      _OverviewItem('assets/icons/profile_user.svg', _fmtNum(d.totalUsers), 'Users', dc.accent),
      _OverviewItem('assets/icons/activity_icon_183944.svg', _fmtNum(d.totalOrders), 'Orders', dc.primaryBtn),
      _OverviewItem('assets/icons/moneys_icon_242132.svg', _fmtCurrency(d.totalRevenueIqd), 'Revenue', dc.accent),
      _OverviewItem('assets/icons/money_add_icon_242178.svg', _fmtCurrency(a.financial.netProfit), 'Net Profit', dc.primaryBtn),
    ];

    return Row(
      children: items.map((item) => Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: rs(context, 3)),
          padding: EdgeInsets.symmetric(vertical: rs(context, 10)),
          decoration: BoxDecoration(
            color: dc.iconBox.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(rs(context, 14)),
            border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
          ),
          child: Column(
            children: [
              Container(
                width: rs(context, 32), height: rs(context, 32),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(rs(context, 10)),
                ),
                child: Center(child: _svgIcon(item.icon, rs(context, 17), item.color)),
              ),
              SizedBox(height: rs(context, 6)),
              Text(item.value, style: TextStyle(
                fontSize: rs(context, 12), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
              Text(item.label, style: TextStyle(
                fontSize: rs(context, 9), color: dc.textSecondary,
              )),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildUsersGrid(AnalyticsData a, StroappDialogColors dc) {
    final u = a.users;
    return _metricGrid(dc, [
      _MetricItem(_fmtNum(u.total), 'Total', 'assets/icons/profile_user.svg', dc.accent),
      _MetricItem(_fmtNum(u.active), 'Active', 'assets/icons/user_tag_icon_242137.svg', dc.primaryBtn),
      _MetricItem(_fmtNum(u.newToday), 'New Today', 'assets/icons/profile_add_icon_242075.svg', dc.primaryBtn),
      _MetricItem(_fmtNum(u.newWeek), 'New (Week)', 'assets/icons/profile_add_icon_242075.svg', dc.accent),
      _MetricItem(_fmtNum(u.newMonth), 'New (Month)', 'assets/icons/user_tag_icon_242137.svg', dc.primaryBtn),
    ]);
  }

  Widget _buildOrdersGrid(AnalyticsData a, DashboardData d, StroappDialogColors dc) {
    final o = a.orders;
    return _metricGrid(dc, [
      _MetricItem(_fmtNum(o.total), 'Total Orders', 'assets/icons/activity_icon_183944.svg', dc.accent),
      _MetricItem(_fmtNum(o.paid), 'Paid', 'assets/icons/verify_icon_241982.svg', dc.primaryBtn),
      _MetricItem(_fmtNum(d.totalPayments), 'Payments', 'assets/icons/wallet_money_icon_242771.svg', dc.accent),
    ]);
  }

  Widget _buildFinancialGrid(AnalyticsData a, StroappDialogColors dc) {
    final f = a.financial;
    final s = a.sales;
    return _metricGrid(dc, [
      _MetricItem(_fmtCurrency(f.totalRevenue), 'Total Revenue', 'assets/icons/moneys_icon_242132.svg', dc.accent),
      _MetricItem(_fmtCurrency(f.totalCost), 'Total Cost', 'assets/icons/money_remove_icon_241831.svg', dc.primaryBtn),
      _MetricItem(_fmtCurrency(f.netProfit), 'Net Profit', 'assets/icons/money_add_icon_242178.svg', dc.primaryBtn),
      _MetricItem(_fmtCurrency(f.totalDiscount), 'Discount', 'assets/icons/wallet_remove_icon_241908.svg', dc.accent),
      _MetricItem(_fmtCurrency(f.totalRefunded), 'Refunded', 'assets/icons/wallet_remove_icon_241908.svg', dc.textSecondary),
      _MetricItem(_fmtNum(s.today), 'Sales Today', 'assets/icons/trend_up_icon_242025.svg', dc.primaryBtn),
      _MetricItem(_fmtNum(s.week), 'Sales (Week)', 'assets/icons/trend_up_icon_242025.svg', dc.accent),
      _MetricItem(_fmtNum(s.month), 'Sales (Month)', 'assets/icons/trend_up_icon_242025.svg', dc.primaryBtn),
    ]);
  }

  Widget _metricGrid(StroappDialogColors dc, List<_MetricItem> items) {
    final gap = rs(context, 8);
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < items.length ? gap : 0),
            child: Row(
              children: [
                Expanded(child: _buildMetricTile(dc, items[i])),
                SizedBox(width: gap),
                Expanded(child: i + 1 < items.length ? _buildMetricTile(dc, items[i + 1]) : const SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMetricTile(StroappDialogColors dc, _MetricItem m) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 8)),
      decoration: BoxDecoration(
        color: dc.iconBox.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: rs(context, 28), height: rs(context, 28),
            decoration: BoxDecoration(
              color: m.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(rs(context, 8)),
            ),
            child: Center(child: _svgIcon(m.icon, rs(context, 15), m.color)),
          ),
          SizedBox(width: rs(context, 8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(m.value, style: TextStyle(
                  fontSize: rs(context, 12), fontWeight: FontWeight.w700,
                  color: dc.textPrimary,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(m.label, style: TextStyle(
                  fontSize: rs(context, 9), color: dc.textSecondary,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansChart(AnalyticsProvider ap, StroappDialogColors dc) {
    final plans = ap.plansChart.take(8).toList();
    final maxVal = plans.isEmpty ? 1.0 : plans.map((e) => e.orderCount.toDouble()).reduce((a, b) => a > b ? a : b);
    return Container(
      height: rs(context, 200),
      padding: EdgeInsets.only(top: rs(context, 12), right: rs(context, 4), left: rs(context, 4), bottom: rs(context, 4)),
      decoration: _boxDeco(dc),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${plans[groupIndex].name}: ${plans[groupIndex].orderCount}',
                const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, reservedSize: rs(context, 24),
                getTitlesWidget: (value, meta) => Text(_fmtCompact(value),
                  style: TextStyle(fontSize: rs(context, 8), color: dc.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, reservedSize: rs(context, 18),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= plans.length) return const SizedBox.shrink();
                  return Text(plans[idx].name.length > 6 ? '${plans[idx].name.substring(0, 6)}..' : plans[idx].name,
                    style: TextStyle(fontSize: rs(context, 7), color: dc.textSecondary),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true, drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: dc.borderColor.withValues(alpha: 0.2), strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(plans.length, (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: plans[i].orderCount.toDouble(),
                color: dc.accent,
                width: rs(context, 10),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(rs(context, 3)),
                  topRight: Radius.circular(rs(context, 3)),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildSalesChart(AnalyticsProvider ap, StroappDialogColors dc) {
    final data = ap.salesChart;
    if (data.isEmpty) {
      return Container(
        height: rs(context, 180),
        decoration: _boxDeco(dc),
        child: Center(child: Text('No sales data',
          style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 12)),
        )),
      );
    }
    final sorted = List<SalesChartPoint>.from(data)
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    final top = sorted.take(8).toList();
    final otherSum = sorted.skip(8).fold<int>(0, (s, e) => s + e.revenue);
    final items = <_PieItem>[
      for (final p in top) _PieItem(p.date, p.revenue.toDouble()),
      if (otherSum > 0) _PieItem('Other', otherSum.toDouble()),
    ];
    final total = items.fold<double>(0, (s, e) => s + e.value);
    final palette = [
      dc.accent, dc.primaryBtn, const Color(0xFFFE9901),
      dc.textSecondary, const Color(0xFF4CAF50), const Color(0xFFE91E63),
      const Color(0xFF9C27B0), const Color(0xFF00BCD4), Colors.grey,
    ];
    return Container(
      decoration: _boxDeco(dc),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: rs(context, 180),
              child: total == 0
                ? Center(child: Text('No sales',
                    style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 12)),
                  ))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: rs(context, 28),
                      sections: List.generate(items.length, (i) {
                        final pct = (items[i].value / total * 100);
                        return PieChartSectionData(
                          value: items[i].value,
                          color: palette[i % palette.length],
                          radius: rs(context, i == 0 ? 50 : 42),
                          title: '${pct.toStringAsFixed(0)}%',
                          titleStyle: TextStyle(
                            fontSize: rs(context, 9),
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }),
                      pieTouchData: PieTouchData(
                        touchCallback: (event, pieTouchResponse) {},
                      ),
                    ),
                  ),
            ),
          ),
          SizedBox(width: rs(context, 8)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(items.length, (i) {
                  final it = items[i];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: rs(context, 2)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: rs(context, 8), height: rs(context, 8),
                          decoration: BoxDecoration(
                            color: palette[i % palette.length],
                            borderRadius: BorderRadius.circular(rs(context, 2)),
                          ),
                        ),
                        SizedBox(width: rs(context, 5)),
                        Expanded(
                          child: Text(it.label, style: TextStyle(
                            fontSize: rs(context, 9), color: dc.textPrimary,
                          ), overflow: TextOverflow.ellipsis),
                        ),
                        Text(_fmtCurrency(it.value.toInt()), style: TextStyle(
                          fontSize: rs(context, 8), color: dc.textSecondary,
                        )),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart(AnalyticsProvider ap, StroappDialogColors dc) {
    final data = ap.userGrowth;
    if (data.isEmpty) {
      return Container(
        height: rs(context, 180),
        decoration: _boxDeco(dc),
        child: Center(child: Text('No user growth data',
          style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 12)),
        )),
      );
    }
    final maxVal = data.map((e) => e.count.toDouble()).reduce((a, b) => a > b ? a : b);
    return Container(
      height: rs(context, 200),
      padding: EdgeInsets.only(top: rs(context, 12), right: rs(context, 4), left: rs(context, 4), bottom: rs(context, 4)),
      decoration: _boxDeco(dc),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${data[groupIndex].period}: ${data[groupIndex].count}',
                const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, reservedSize: rs(context, 24),
                getTitlesWidget: (value, meta) => Text(_fmtCompact(value),
                  style: TextStyle(fontSize: rs(context, 8), color: dc.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, reservedSize: rs(context, 18), interval: 5,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                  final label = data[idx].period.length > 8 ? data[idx].period.substring(0, 8) : data[idx].period;
                  return Text(label,
                    style: TextStyle(fontSize: rs(context, 7), color: dc.textSecondary),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true, drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: dc.borderColor.withValues(alpha: 0.2), strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].count.toDouble(),
                color: dc.accent,
                width: rs(context, 8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(rs(context, 3)),
                  topRight: Radius.circular(rs(context, 3)),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  BoxDecoration _boxDeco(StroappDialogColors dc) {
    return BoxDecoration(
      color: dc.iconBox.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(rs(context, 12)),
      border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
    );
  }

  String _fmtNum(dynamic value) {
    final n = (value is num) ? value : (double.tryParse(value.toString()) ?? 0);
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return NumberFormat('#,##0').format(n);
  }

  String _fmtCurrency(dynamic value) {
    final n = (value is num) ? value : (double.tryParse(value.toString()) ?? 0);
    if (n >= 1000000) return '\$${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '\$${(n / 1000).toStringAsFixed(1)}K';
    return '\$${NumberFormat('#,##0.00').format(n)}';
  }

  String _fmtCompact(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}

class _OverviewItem {
  final String icon;
  final String value;
  final String label;
  final Color color;
  const _OverviewItem(this.icon, this.value, this.label, this.color);
}

class _MetricItem {
  final String value;
  final String label;
  final String icon;
  final Color color;
  const _MetricItem(this.value, this.label, this.icon, this.color);
}

// ================================================================
// _PlansTab
// ================================================================

class _PlansTab extends StatefulWidget {
  const _PlansTab();

  @override
  State<_PlansTab> createState() => _PlansTabState();
}

class _PlansTabState extends State<_PlansTab> {
  int _subPage = 0; // 0 = grid, 1 = all plans, 2 = create plan, 3 = inventory, 4 = pricing, 5 = catalogue, 6 = plan detail
  AdminPlan? _selectedPlan;
  int _planDetailFrom = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlansProvider>().load();
    });
  }

  void _openAllPlans() => setState(() => _subPage = 1);
  void _openCreatePlan() => setState(() => _subPage = 2);
  void _openInventory() => setState(() => _subPage = 3);
  void _openPricing() => setState(() => _subPage = 4);
  void _openCatalogue() => setState(() => _subPage = 5);
  void _openPlanDetail(AdminPlan plan) => setState(() { _selectedPlan = plan; _planDetailFrom = _subPage; _subPage = 6; });
  void _backFromPlanDetail() => setState(() { _subPage = _planDetailFrom; _selectedPlan = null; });
  void _backToGrid() => setState(() { _subPage = 0; _selectedPlan = null; });

  @override
  Widget build(BuildContext context) {
    switch (_subPage) {
      case 1: return _buildAllPlansPage();
      case 2: return _buildCreatePlanPage();
      case 3: return _buildInventoryPage();
      case 4: return _buildPricingPage();
      case 5: return _buildCataloguePage();
      case 6: return _buildPlanDetailPage();
      default: return _buildGridPage();
    }
  }

  // ── Grid page (default) ──
  Widget _buildGridPage() {
    final dc = context.dialogColors;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), rs(context, 100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: rs(context, 24)),
          Text(
            trans(context, 'Plans'),
            style: TextStyle(
              fontSize: rs(context, 24),
              fontWeight: FontWeight.w700,
              color: dc.textPrimary,
            ),
          ),
          SizedBox(height: rs(context, 24)),
          _buildScreensGrid([
            _ScreenItem('assets/icons/virtual_card.svg', trans(context, 'All Plans'), dc.accent, _openAllPlans),
            _ScreenItem('assets/icons/wallet_add_icon_241828.svg', trans(context, 'Create Plan'), dc.primaryBtn, _openCreatePlan),
            _ScreenItem('assets/icons/wallet_icon_242153.svg', trans(context, 'Inventory'), dc.accent, _openInventory),
            _ScreenItem('assets/icons/coinicon_114542.svg', trans(context, 'Pricing'), dc.primaryBtn, _openPricing),
            _ScreenItem('assets/icons/search_zoom_in_icon_242189.svg', trans(context, 'Browse Catalogue'), dc.accent, _openCatalogue),
          ]),
        ],
      ),
    );
  }

  // ── All Plans sub-page (with bottom nav visible) ──
  Widget _buildAllPlansPage() {
    final dc = context.dialogColors;
    final p = context.watch<PlansProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), rs(context, 100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: rs(context, 24)),
          Row(
            children: [
              GestureDetector(
                onTap: _backToGrid,
                child: Container(
                  padding: EdgeInsets.all(rs(context, 8)),
                  decoration: BoxDecoration(
                    color: dc.iconBox.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(rs(context, 10)),
                  ),
                  child: Icon(Icons.arrow_back_ios_new, color: dc.textPrimary, size: rs(context, 16)),
                ),
              ),
              SizedBox(width: rs(context, 12)),
              Text(trans(context, 'All Plans'), style: TextStyle(
                fontSize: rs(context, 24),
                fontWeight: FontWeight.w700,
                color: dc.textPrimary,
              )),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: dc.textPrimary, size: rs(context, 20)),
                onSelected: (v) async {
                  final pp = context.read<PlansProvider>();
                  String? err;
                  switch (v) {
                    case 'activate':
                      err = await pp.activateAll();
                      if (err == null) CustomToaster.showSuccess(context, message: trans(context, 'All plans activated'));
                      break;
                    case 'deactivate':
                      err = await pp.deactivateAll();
                      if (err == null) CustomToaster.showSuccess(context, message: trans(context, 'All plans deactivated'));
                      break;
                    case 'delete':
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete All Plans'),
                          content: const Text('Delete all plans? This cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete All', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        err = await pp.deleteAll();
                        if (err == null) CustomToaster.showSuccess(context, message: trans(context, 'All plans deleted'));
                      }
                  }
                  if (err != null) {
                    CustomToaster.showError(context, message: err);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'activate', child: ListTile(
                    leading: Icon(Icons.check_circle_outline, color: Colors.green),
                    title: Text(trans(context, 'Activate All'), style: const TextStyle(fontSize: 14)),
                    dense: true, contentPadding: EdgeInsets.zero,
                  )),
                  PopupMenuItem(value: 'deactivate', child: ListTile(
                    leading: Icon(Icons.remove_circle_outline, color: Colors.orange),
                    title: Text(trans(context, 'Deactivate All'), style: const TextStyle(fontSize: 14)),
                    dense: true, contentPadding: EdgeInsets.zero,
                  )),
                  PopupMenuItem(value: 'delete', child: ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text(trans(context, 'Delete All'), style: const TextStyle(fontSize: 14)),
                    dense: true, contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ],
          ),
          SizedBox(height: rs(context, 24)),
          _buildPlansCard(p, dc),
        ],
      ),
    );
  }

  // ── Create Plan sub-page ──
  Widget _buildCreatePlanPage() {
    return CreatePlanWidget(onBack: _backToGrid);
  }

  // ── Inventory sub-page ──
  Widget _buildInventoryPage() {
    return InventoryWidget(onBack: _backToGrid);
  }

  // ── Pricing sub-page ──
  Widget _buildPricingPage() {
    return PricingWidget(onBack: _backToGrid);
  }

  // ── Catalogue sub-page ──
  Widget _buildCataloguePage() {
    return ProviderCatalogueScreen(embedded: true, onBack: _backToGrid);
  }

  // ── Plan Detail sub-page ──
  Widget _buildPlanDetailPage() {
    final plan = _selectedPlan;
    if (plan == null) return _buildGridPage();
    return PlanDetailWidget(plan: plan, onBack: _backFromPlanDetail);
  }

  Widget _buildPlansCard(PlansProvider p, StroappDialogColors dc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 14)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _svgIcon('assets/icons/virtual_card.svg', rs(context, 18), dc.accent),
              SizedBox(width: rs(context, 8)),
              Text(trans(context, 'All Plans'), style: TextStyle(
                fontSize: rs(context, 15),
                fontWeight: FontWeight.w700,
                color: dc.textPrimary,
              )),
            ],
          ),
          SizedBox(height: rs(context, 14)),
          _buildPlansBody(p, dc),
        ],
      ),
    );
  }

  Widget _buildPlansBody(PlansProvider p, StroappDialogColors dc) {
    if (p.loading && p.plans.isEmpty) return const CustomLoader();
    if (p.error != null && p.plans.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: rs(context, 20)),
            _svgIcon('assets/icons/info_square_icon_184028.svg', rs(context, 48), dc.textSecondary),
            SizedBox(height: rs(context, 12)),
            Text(p.error!,
              style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 14)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: rs(context, 16)),
            GestureDetector(
              onTap: () => context.read<PlansProvider>().load(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 24), vertical: rs(context, 12)),
                decoration: BoxDecoration(
                  color: dc.accent,
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                ),
                child: Text(trans(context, 'Retry'),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (p.plans.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: rs(context, 20)),
            _svgIcon('assets/icons/coinicon_114542.svg', rs(context, 48), dc.textSecondary),
            SizedBox(height: rs(context, 12)),
            Text(trans(context, 'No plans found'),
              style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 14)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<PlansProvider>().load(),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: p.plans.length,
        separatorBuilder: (_, __) => SizedBox(height: rs(context, 10)),
        itemBuilder: (ctx, i) => _buildPlanTile(p.plans[i], dc),
      ),
    );
  }

  Widget _buildPlanTile(AdminPlan plan, StroappDialogColors dc) {
    final dataGb = plan.dataAmountMb / 1024;
    return GestureDetector(
      onTap: () => _openPlanDetail(plan),
      child: Container(
      decoration: BoxDecoration(
        color: dc.iconBox.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(rs(context, 14)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(rs(context, 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: rs(context, 36), height: rs(context, 36),
                  decoration: BoxDecoration(
                    color: plan.isActive
                      ? dc.accent.withValues(alpha: 0.15)
                      : dc.textSecondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(rs(context, 10)),
                  ),
                  child: Center(child: SvgPicture.asset('assets/icons/virtual_card.svg',
                    width: rs(context, 18), height: rs(context, 18),
                    colorFilter: ColorFilter.mode(
                      plan.isActive ? dc.accent : dc.textSecondary, BlendMode.srcIn,
                    ),
                  )),
                ),
                SizedBox(width: rs(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name, style: TextStyle(
                        fontSize: rs(context, 14), fontWeight: FontWeight.w600, color: dc.textPrimary,
                      )),
                      if (plan.description.isNotEmpty)
                        Text(plan.description, style: TextStyle(
                          fontSize: rs(context, 10), color: dc.textSecondary,
                        ), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Switch(
                  value: plan.isActive,
                  activeTrackColor: dc.primaryBtn,
                  onChanged: (_) async {
                    await context.read<PlansProvider>().update(plan.id, {'is_active': !plan.isActive});
                  },
                ),
              ],
            ),
            SizedBox(height: rs(context, 10)),
            Row(
              children: [
                _infoChip(dc, '${_fmtInt(dataGb)} GB', 'assets/icons/hugeicons_database-restore.png'),
                SizedBox(width: rs(context, 6)),
                _infoChip(dc, '${plan.durationDays}d', 'assets/icons/timer_start_icon_242184.svg'),
                SizedBox(width: rs(context, 6)),
                _infoChip(dc, _fmtCurrency(plan.priceIqd), 'assets/icons/moneys_icon_242132.svg'),
                SizedBox(width: rs(context, 6)),
                _infoChip(dc, '\$${plan.priceUsd.toStringAsFixed(2)}', 'assets/icons/usd_coin_usdc.svg'),
              ],
            ),
            SizedBox(height: rs(context, 8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _confirmDelete(plan),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 6)),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(rs(context, 8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _svgIcon('assets/icons/trash_icon_241955.svg', rs(context, 14), Colors.red),
                        SizedBox(width: rs(context, 4)),
                        Text(trans(context, 'Delete'), style: TextStyle(
                          fontSize: rs(context, 10), color: Colors.red,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _infoChip(StroappDialogColors dc, String label, String iconPath) {
    final isPng = iconPath.endsWith('.png');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 4)),
      decoration: BoxDecoration(
        color: dc.borderColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(rs(context, 8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPng)
            Image.asset(iconPath, width: rs(context, 12), height: rs(context, 12),
              color: dc.textSecondary)
          else
            SvgPicture.asset(iconPath, width: rs(context, 12), height: rs(context, 12),
              colorFilter: ColorFilter.mode(dc.textSecondary, BlendMode.srcIn),
            ),
          SizedBox(width: rs(context, 4)),
          Text(label, style: TextStyle(
            fontSize: rs(context, 10), color: dc.textSecondary,
          )),
        ],
      ),
    );
  }

  void _confirmDelete(AdminPlan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(trans(context, 'Delete Plan')),
        content: Text('${trans(context, 'Delete')} "${plan.name}"? ${trans(context, 'This cannot be undone.')}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(trans(context, 'Cancel'))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final err = await context.read<PlansProvider>().delete(plan.id);
              if (err != null) {
                CustomToaster.showError(context, message: err);
              } else {
                CustomToaster.showSuccess(context, message: trans(context, 'Plan deleted'));
              }
            },
            child: Text(trans(context, 'Delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  SizedBox _svgIcon(String path, double size, Color color) {
    return SizedBox(
      width: size, height: size,
      child: SvgPicture.asset(path, width: size, height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }

  String _fmtInt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  String _fmtCurrency(int v) {
    final f = NumberFormat('#,##0', 'en_US');
    return '${f.format(v)} IQD';
  }

  Widget _buildScreensGrid(List<_ScreenItem> items) {
    final dc = context.dialogColors;
    return Container(
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      padding: EdgeInsets.all(rs(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trans(context, 'Plan Management'), style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: rs(context, 14),
            color: dc.textPrimary,
          )),
          SizedBox(height: rs(context, 8)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: rs(context, 4),
              mainAxisSpacing: rs(context, 4),
              childAspectRatio: 1.3,
            ),
            itemCount: items.length,
            itemBuilder: (ctx, i) => _buildScreenItem(items[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenItem(_ScreenItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(rs(context, 12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(item.icon, width: rs(context, 24), height: rs(context, 24),
              colorFilter: ColorFilter.mode(item.color, BlendMode.srcIn),
            ),
            SizedBox(height: rs(context, 6)),
            Text(item.label, style: TextStyle(
              fontSize: rs(context, 11), fontWeight: FontWeight.w500, color: item.color,
            ), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// _OrdersTab
// ================================================================

class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  int _subPage = 0;

  void _open(int p) => setState(() => _subPage = p);
  void _back() => setState(() => _subPage = 0);

  @override
  Widget build(BuildContext context) {
    if (_subPage == 1) {
      return OrderListWidget(onBack: _back);
    }
    if (_subPage == 2) {
      return ExchangeRateWidget(onBack: _back);
    }

    final dc = context.dialogColors;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), rs(context, 100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: rs(context, 24)),
          Text(
            trans(context, 'Orders'),
            style: TextStyle(
              fontSize: rs(context, 24),
              fontWeight: FontWeight.w700,
              color: dc.textPrimary,
            ),
          ),
          SizedBox(height: rs(context, 24)),
          _buildScreensGrid([
            _ScreenItem('assets/icons/activity_icon_183944.svg', 'All Orders', dc.accent, () => _open(1)),
            _ScreenItem('assets/icons/exchange-alt.svg', 'Exchange', dc.primaryBtn, () => _open(2)),
          ]),
        ],
      ),
    );
  }

  Widget _buildScreensGrid(List<_ScreenItem> items) {
    final dc = context.dialogColors;
    return Container(
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      padding: EdgeInsets.all(rs(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Management', style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: rs(context, 14),
            color: dc.textPrimary,
          )),
          SizedBox(height: rs(context, 8)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: items.length < 3 ? items.length : 3,
              crossAxisSpacing: rs(context, 4),
              mainAxisSpacing: rs(context, 4),
              childAspectRatio: 1.3,
            ),
            itemCount: items.length,
            itemBuilder: (ctx, i) => _buildScreenItem(items[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenItem(_ScreenItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(rs(context, 12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(item.icon, width: rs(context, 24), height: rs(context, 24),
              colorFilter: ColorFilter.mode(item.color, BlendMode.srcIn),
            ),
            SizedBox(height: rs(context, 6)),
            Text(item.label, style: TextStyle(
              fontSize: rs(context, 11), fontWeight: FontWeight.w500, color: item.color,
            ), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// _UsersTab
// ================================================================

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  int _subPage = 0;

  void _open(int p) => setState(() => _subPage = p);
  void _back() => setState(() => _subPage = 0);

  @override
  Widget build(BuildContext context) {
    if (_subPage == 1) {
      return UserListWidget(onBack: _back);
    }
    if (_subPage == 2) {
      return TicketListWidget(onBack: _back);
    }
    if (_subPage == 3) {
      return AdminActivityWidget(onBack: _back);
    }
    if (_subPage == 4) {
      return WalletDashboardWidget(onBack: _back);
    }

    final dc = context.dialogColors;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), rs(context, 100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: rs(context, 24)),
          Text(
            trans(context, 'Users'),
            style: TextStyle(
              fontSize: rs(context, 24),
              fontWeight: FontWeight.w700,
              color: dc.textPrimary,
            ),
          ),
          SizedBox(height: rs(context, 24)),
          _buildScreensGrid([
            _ScreenItem('assets/icons/user_icon_242161.svg', 'All Users', dc.accent, () => _open(1)),
            _ScreenItem('assets/icons/web_live_chat_icon.svg', 'Tickets', dc.accent, () => _open(2)),
            _ScreenItem('assets/icons/wallet_icon_242153.svg', 'Wallets', dc.primaryBtn, () => _open(4)),
            _ScreenItem('assets/icons/activity_icon_183944.svg', 'Activity', dc.primaryBtn, () => _open(3)),
          ]),
        ],
      ),
    );
  }

  Widget _buildScreensGrid(List<_ScreenItem> items) {
    final dc = context.dialogColors;
    return Container(
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      padding: EdgeInsets.all(rs(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Management', style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: rs(context, 14),
            color: dc.textPrimary,
          )),
          SizedBox(height: rs(context, 8)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: items.length < 3 ? items.length : 3,
              crossAxisSpacing: rs(context, 4),
              mainAxisSpacing: rs(context, 4),
              childAspectRatio: 1.3,
            ),
            itemCount: items.length,
            itemBuilder: (ctx, i) => _buildScreenItem(items[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenItem(_ScreenItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(rs(context, 12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(item.icon, width: rs(context, 24), height: rs(context, 24),
              colorFilter: ColorFilter.mode(item.color, BlendMode.srcIn),
            ),
            SizedBox(height: rs(context, 6)),
            Text(item.label, style: TextStyle(
              fontSize: rs(context, 11), fontWeight: FontWeight.w500, color: item.color,
            ), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// _MoreTab
// ================================================================

class _MoreTab extends StatefulWidget {
  const _MoreTab();

  @override
  State<_MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<_MoreTab> {
  int _moreSubPage = 0;

  void _showLanguageDialog() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => LanguageSelectionDialog(
        initialCode: context.read<LocaleProvider>().languageCode,
      ),
    );
    if (code != null && mounted) {
      context.read<LocaleProvider>().setLanguage(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_moreSubPage) {
      case 1: return ServerSettingsWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 2: return PaymentsWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 3: return CouponsWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 4: return TaxRatesWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 5: return RefundsWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 6: return ReferralsWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 7: return FreezesWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 8: return AuditLogWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 9: return ReportsWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 10: return BackupsWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 11: return TwoFAWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 12: return ExchangeRateWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 13: return SystemSettingsWidget(onBack: () => setState(() => _moreSubPage = 0));
      case 14: return ProfileWidget(onBack: () => setState(() => _moreSubPage = 0));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dc = context.dialogColors;
    final auth = context.watch<AuthProvider>();
    final locale = context.watch<LocaleProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), rs(context, 100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: rs(context, 24)),
          Text(
            trans(context, 'More'),
            style: TextStyle(
              fontSize: rs(context, 24),
              fontWeight: FontWeight.w700,
              color: dc.textPrimary,
            ),
          ),
          SizedBox(height: rs(context, 24)),
          _buildMenuItem(
            iconPath: 'assets/icons/profile_user.svg',
            title: trans(context, 'Profile'),
            subtitle: auth.user?['name'] ?? 'Admin',
            onTap: () => setState(() => _moreSubPage = 14),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/language_121815.svg',
            title: trans(context, 'Language'),
            subtitle: locale.languageCode.toUpperCase(),
            onTap: _showLanguageDialog,
          ),
          _buildMenuItem(
            iconPath: isDark ? 'assets/icons/sun-sunny.svg' : 'assets/icons/moon_dark_mode.svg',
            title: trans(context, 'Dark Mode'),
            subtitle: isDark ? 'On' : 'Off',
            trailing: Switch(
              value: isDark,
              activeTrackColor: dc.primaryBtn,
              onChanged: (_) => context.read<ThemeProvider>().toggle(),
            ),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/setting_icon_241871.svg',
            title: trans(context, 'Settings'),
            onTap: () => setState(() => _moreSubPage = 1),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/wallet_money_icon_242771.svg',
            title: trans(context, 'Payments'),
            onTap: () => setState(() => _moreSubPage = 2),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/tick_circle_icon_241974.svg',
            title: trans(context, 'Coupons'),
            onTap: () => setState(() => _moreSubPage = 3),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/trend_up_icon_242025.svg',
            title: trans(context, 'Tax Rates'),
            onTap: () => setState(() => _moreSubPage = 4),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/money_remove_icon_241831.svg',
            title: trans(context, 'Refunds'),
            onTap: () => setState(() => _moreSubPage = 5),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/transfer.svg',
            title: trans(context, 'Referrals'),
            onTap: () => setState(() => _moreSubPage = 6),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/shield_security_icon_242117.svg',
            title: trans(context, 'Freezes'),
            onTap: () => setState(() => _moreSubPage = 7),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/activity_icon_183944.svg',
            title: trans(context, 'Audit Log'),
            onTap: () => setState(() => _moreSubPage = 8),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/presention_chart_icon_241664.svg',
            title: trans(context, 'Reports'),
            onTap: () => setState(() => _moreSubPage = 9),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/save_add_icon_241850.svg',
            title: trans(context, 'Backups'),
            onTap: () => setState(() => _moreSubPage = 10),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/shield_security_icon_242117.svg',
            title: trans(context, '2FA'),
            onTap: () => setState(() => _moreSubPage = 11),
          ),
          _buildMenuItem(
            iconPath: 'assets/icons/exchange-alt.svg',
            title: trans(context, 'Exchange Rates'),
            onTap: () => setState(() => _moreSubPage = 12),
          ),
          const Divider(),
          _buildMenuItem(
            iconPath: 'assets/icons/logout_icon_184025.svg',
            title: trans(context, 'Logout'),
            iconColor: const Color(0xFFC62828),
            titleColor: const Color(0xFFC62828),
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PhoneEntryScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    final dc = context.dialogColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: rs(context, 12)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: dc.iconBox,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SvgPicture.asset(iconPath, width: 22, height: 22,
                colorFilter: ColorFilter.mode(iconColor ?? dc.accent, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: rs(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: rs(context, 15),
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? dc.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: rs(context, 2)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: rs(context, 12),
                        color: dc.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ?? SvgPicture.asset('assets/icons/rightArrow.svg', width: 20, height: 20,
              colorFilter: ColorFilter.mode(dc.textSecondary, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenItem {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ScreenItem(this.icon, this.label, this.color, this.onTap);
}
