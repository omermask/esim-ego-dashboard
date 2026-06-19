import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/referral_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/widgets/custom_loader.dart';

class ReferralsWidget extends StatefulWidget {
  final VoidCallback onBack;
  const ReferralsWidget({super.key, required this.onBack});

  @override
  State<ReferralsWidget> createState() => _ReferralsWidgetState();
}

class _ReferralsWidgetState extends State<ReferralsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReferralProvider>().load();
    });
  }

  Future<void> _refresh() async {
    await context.read<ReferralProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<ReferralProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(
              child: provider.loading
                  ? const Center(child: CustomLoader())
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 100)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsCard(dc, provider),
                            SizedBox(height: rs(context, 16)),
                            Text(trans(context, 'Rewards'), style: TextStyle(
                              fontSize: rs(context, 16), fontWeight: FontWeight.w700, color: dc.textPrimary,
                            )),
                            SizedBox(height: rs(context, 8)),
                            ...provider.rewards.map((r) => _buildRewardItem(dc, r, provider)),
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
          Text(trans(context, 'Referrals'),
            style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(StroappDialogColors dc, ReferralProvider provider) {
    final s = provider.stats;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(dc, '${s.totalReferrals}', 'Total'),
              _statItem(dc, '${s.totalQualified}', 'Qualified'),
              _statItem(dc, '${s.totalCredited}', 'Credited'),
            ],
          ),
          SizedBox(height: rs(context, 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(dc, '${s.totalAmountQualified}', 'Amount Qualified'),
              _statItem(dc, '${s.totalAmountCredited}', 'Amount Credited'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(StroappDialogColors dc, String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: rs(context, 16), fontWeight: FontWeight.w700, color: dc.textPrimary)),
        SizedBox(height: rs(context, 2)),
        Text(label, style: TextStyle(fontSize: rs(context, 11), color: dc.textSecondary)),
      ],
    );
  }

  Widget _buildRewardItem(StroappDialogColors dc, r, ReferralProvider provider) {
    final statusColor = r.status == 'credited' ? const Color(0xFF4CAF50)
        : r.status == 'qualified' ? const Color(0xFFFFA000)
        : const Color(0xFF757575);

    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 10)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(rs(context, 14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(r.referrer?.name ?? 'User',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(rs(context, 6)),
                  ),
                  child: Text(r.status[0].toUpperCase() + r.status.substring(1),
                    style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: rs(context, 4)),
            Text('${r.amount} IQD', style: TextStyle(fontSize: rs(context, 14), fontWeight: FontWeight.w700, color: dc.textPrimary)),
          ],
        ),
      ),
    );
  }
}
