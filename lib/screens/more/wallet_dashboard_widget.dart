import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/report_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/widgets/custom_loader.dart';

class WalletDashboardWidget extends StatefulWidget {
  final VoidCallback onBack;
  const WalletDashboardWidget({super.key, required this.onBack});

  @override
  State<WalletDashboardWidget> createState() => _WalletDashboardWidgetState();
}

class _WalletDashboardWidgetState extends State<WalletDashboardWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final rp = context.watch<ReportProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(
              child: rp.loading
                  ? const Center(child: CustomLoader())
                  : RefreshIndicator(
                      onRefresh: () => rp.loadWallet(),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 100)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBalanceCard(dc, rp.wallet),
                            SizedBox(height: rs(context, 16)),
                            _buildDetailsCard(dc, rp.wallet),
                          ],
                        ),
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
          Text(trans(context, 'Wallet Dashboard'),
            style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(StroappDialogColors dc, dynamic w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [dc.accent, dc.accent.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(rs(context, 20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trans(context, 'Total Balance'), style: TextStyle(color: Colors.white70, fontSize: rs(context, 13))),
          SizedBox(height: rs(context, 8)),
          Text('${w.totalBalanceIqd} IQD', style: TextStyle(
            color: Colors.white, fontSize: rs(context, 28), fontWeight: FontWeight.w700,
          )),
          SizedBox(height: rs(context, 16)),
          Row(
            children: [
              _balanceItem('Available', '${w.availableBalanceIqd} IQD', Colors.white),
              SizedBox(width: rs(context, 24)),
              _balanceItem('Frozen', '${w.totalFrozenIqd} IQD', Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: rs(context, 11))),
        SizedBox(height: rs(context, 4)),
        Text(value, style: TextStyle(color: color, fontSize: rs(context, 15), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDetailsCard(StroappDialogColors dc, dynamic w) {
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
          Text(trans(context, 'Details'), style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary,
          )),
          SizedBox(height: rs(context, 12)),
          _row(dc, 'Total Orders', '${w.totalOrders}'),
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
