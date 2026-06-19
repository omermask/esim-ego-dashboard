import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/plans_provider.dart';
import '../../data/models/plan_data.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/widgets/custom_loader.dart';
import 'package:intl/intl.dart';

class AllPlansScreen extends StatefulWidget {
  const AllPlansScreen({super.key});

  @override
  State<AllPlansScreen> createState() => _AllPlansScreenState();
}

class _AllPlansScreenState extends State<AllPlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlansProvider>().load();
    });
  }

  Future<void> _refresh() => context.read<PlansProvider>().load();

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final p = context.watch<PlansProvider>();

    return Scaffold(
      backgroundColor: dc.bg,
      appBar: AppBar(
        backgroundColor: dc.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: dc.textPrimary, size: rs(context, 18)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('All Plans', style: TextStyle(
          fontSize: rs(context, 18), fontWeight: FontWeight.w700, color: dc.textPrimary,
        )),
        actions: [
          PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: dc.textPrimary, size: rs(context, 20)),
              onSelected: (v) async {
                final p = context.read<PlansProvider>();
                final messenger = ScaffoldMessenger.of(context);
                String? err;
                switch (v) {
                  case 'activate':
                    err = await p.activateAll();
                    break;
                  case 'deactivate':
                    err = await p.deactivateAll();
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
                    if (confirm == true) err = await p.deleteAll();
                }
                if (err != null) {
                  messenger.showSnackBar(SnackBar(content: Text(err)));
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'activate', child: ListTile(
                  leading: Icon(Icons.check_circle_outline, color: Colors.green),
                  title: Text('Activate All', style: TextStyle(fontSize: 14)),
                  dense: true, contentPadding: EdgeInsets.zero,
                )),
                const PopupMenuItem(value: 'deactivate', child: ListTile(
                  leading: Icon(Icons.remove_circle_outline, color: Colors.orange),
                  title: Text('Deactivate All', style: TextStyle(fontSize: 14)),
                  dense: true, contentPadding: EdgeInsets.zero,
                )),
                const PopupMenuItem(value: 'delete', child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete All', style: TextStyle(fontSize: 14)),
                  dense: true, contentPadding: EdgeInsets.zero,
                )),
              ],
            ),
          ],
      ),
      body: _buildBody(p, dc),
    );
  }

  Widget _buildBody(PlansProvider p, StroappDialogColors dc) {
    if (p.loading && p.plans.isEmpty) return const CustomLoader();
    if (p.error != null && p.plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: rs(context, 48), color: dc.textSecondary),
            SizedBox(height: rs(context, 12)),
            Text(p.error!,
              style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 14)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: rs(context, 16)),
            GestureDetector(
              onTap: _refresh,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: rs(context, 48), color: dc.textSecondary),
            SizedBox(height: rs(context, 12)),
            Text('No plans found',
              style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 14)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(rs(context, 16), rs(context, 8), rs(context, 16), rs(context, 100)),
        itemCount: p.plans.length,
        itemBuilder: (ctx, i) => _buildPlanTile(p.plans[i], dc),
      ),
    );
  }

  Widget _buildPlanTile(AdminPlan plan, StroappDialogColors dc) {
    final dataGb = plan.dataAmountMb / 1024;
    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 10)),
      decoration: BoxDecoration(
        color: dc.iconBox.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(rs(context, 14)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(rs(context, 14)),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(rs(context, 14)),
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
                  _infoChip(dc, '${_fmtInt(dataGb)} GB', Icons.data_usage),
                  SizedBox(width: rs(context, 8)),
                  _infoChip(dc, '${plan.durationDays}d', Icons.timer_outlined),
                  SizedBox(width: rs(context, 8)),
                  _infoChip(dc, _fmtCurrency(plan.priceIqd), Icons.monetization_on_outlined),
                  SizedBox(width: rs(context, 8)),
                  _infoChip(dc, '\$${plan.priceUsd.toStringAsFixed(2)}', Icons.attach_money),
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
                          Icon(Icons.delete_outline, size: rs(context, 14), color: Colors.red),
                          SizedBox(width: rs(context, 4)),
                          Text('Delete', style: TextStyle(
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

  Widget _infoChip(StroappDialogColors dc, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 4)),
      decoration: BoxDecoration(
        color: dc.borderColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(rs(context, 8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: rs(context, 12), color: dc.textSecondary),
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
        title: Text('Delete Plan'),
        content: Text('Delete "${plan.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PlansProvider>().delete(plan.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _fmtInt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  String _fmtCurrency(int v) {
    final f = NumberFormat('#,##0', 'en_US');
    return '${f.format(v)} IQD';
  }
}
