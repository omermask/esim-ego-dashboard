import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/report_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/widgets/custom_loader.dart';

class ReportsWidget extends StatefulWidget {
  final VoidCallback onBack;
  const ReportsWidget({super.key, required this.onBack});

  @override
  State<ReportsWidget> createState() => _ReportsWidgetState();
}

class _ReportsWidgetState extends State<ReportsWidget> {
  String _period = 'daily';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rp = context.read<ReportProvider>();
      rp.loadFinancial(period: _period);
      rp.loadWallet();
    });
  }

  void _setPeriod(String p) {
    setState(() => _period = p);
    context.read<ReportProvider>().loadFinancial(period: p);
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<ReportProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(
              child: provider.loading
                  ? const Center(child: CustomLoader())
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 100)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPeriodSelector(dc),
                          SizedBox(height: rs(context, 16)),
                          _buildFinancialCard(dc, provider.financial),
                          SizedBox(height: rs(context, 16)),
                          Text(trans(context, 'Wallet Dashboard'), style: TextStyle(
                            fontSize: rs(context, 16), fontWeight: FontWeight.w700, color: dc.textPrimary,
                          )),
                          SizedBox(height: rs(context, 8)),
                          _buildWalletCard(dc, provider.wallet),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(StroappDialogColors dc) {
    return Padding(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), 0),
      child: Row(
        children: [
          InkWell(
            onTap: widget.onBack,
            child: SvgPicture.asset('assets/icons/rightArrow.svg',
              width: rs(context, 22),
              colorFilter: ColorFilter.mode(dc.textPrimary, BlendMode.srcIn),
            ),
          ),
          SizedBox(width: rs(context, 12)),
          Text(trans(context, 'Reports'),
            style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(StroappDialogColors dc) {
    final periods = ['daily', 'weekly', 'monthly'];
    return Row(
      children: periods.map((p) {
        final sel = _period == p;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: rs(context, 3)),
            child: InkWell(
              onTap: () => _setPeriod(p),
              borderRadius: BorderRadius.circular(rs(context, 12)),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: rs(context, 10)),
                decoration: BoxDecoration(
                  color: sel ? dc.accent : dc.iconBox,
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                ),
                child: Center(
                  child: Text(p[0].toUpperCase() + p.substring(1),
                    style: TextStyle(fontSize: rs(context, 13), fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : dc.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFinancialCard(StroappDialogColors dc, financial) {
    final s = financial.summary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trans(context, 'Financial Summary'), style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary,
          )),
          SizedBox(height: rs(context, 12)),
          _row(dc, 'Orders', '${s.totalOrders}'),
          _row(dc, 'Net Revenue', '${s.netRevenueIqd} IQD'),
          _row(dc, 'Gross Revenue', '${s.grossRevenueIqd} IQD'),
          _row(dc, 'Total Cost', '${s.totalCostIqd} IQD'),
          _row(dc, 'Discount', '${s.totalDiscountIqd} IQD'),
          _row(dc, 'Tax', '${s.totalTaxIqd} IQD'),
          _row(dc, 'Refunded', '${s.totalRefundedIqd} IQD'),
          _row(dc, 'Deposits', '${s.totalDepositsIqd} IQD'),
          _row(dc, 'New Users', '${s.newUsers}'),
        ],
      ),
    );
  }

  Widget _buildWalletCard(StroappDialogColors dc, w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(dc, 'Total Balance', '${w.totalBalanceIqd} IQD'),
          _row(dc, 'Available', '${w.availableBalanceIqd} IQD'),
          _row(dc, 'Frozen', '${w.totalFrozenIqd} IQD'),
          _row(dc, 'Orders', '${w.totalOrders}'),
          _row(dc, 'Gross Sales', '${w.grossSalesIqd} IQD'),
          _row(dc, 'Total Cost', '${w.totalCostIqd} IQD'),
          _row(dc, 'Refunded', '${w.totalRefundedIqd} IQD'),
          _row(dc, 'Net Profit', '${w.netProfitIqd} IQD'),
        ],
      ),
    );
  }

  Widget _row(StroappDialogColors dc, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(context, 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: rs(context, 13), color: dc.textSecondary)),
          Text(value, style: TextStyle(fontSize: rs(context, 13), fontWeight: FontWeight.w600, color: dc.textPrimary)),
        ],
      ),
    );
  }
}
