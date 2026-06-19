import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/custom_loader.dart';

class InventoryWidget extends StatefulWidget {
  final VoidCallback onBack;
  const InventoryWidget({super.key, required this.onBack});

  @override
  State<InventoryWidget> createState() => _InventoryWidgetState();
}

class _InventoryWidgetState extends State<InventoryWidget> {
  final _api = ApiService();
  Map<String, dynamic>? _stats;
  List<dynamic> _iccidList = [];
  List<dynamic> _batches = [];
  bool _loading = true;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.getInventoryStats(),
        _api.getInventory(limit: 50),
        _api.getInventoryBatches(limit: 20),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = results[0];
        _iccidList = (results[1]['items'] as List?) ?? [];
        _batches = (results[2]['batches'] as List?) ?? [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; });
    }
  }

  Future<void> _purchase() async {
    final planIdCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final planId = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(trans(context, 'Purchase Inventory')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: planIdCtrl, decoration: InputDecoration(labelText: trans(context, 'Plan ID'), hintText: 'plan-uuid-here')),
            SizedBox(height: rs(context, 8)),
            TextField(controller: qtyCtrl, decoration: InputDecoration(labelText: trans(context, 'Quantity')), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(trans(context, 'Cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, 'ok'), child: Text(trans(context, 'Purchase'))),
        ],
      ),
    );
    if (planId == null || planIdCtrl.text.isEmpty || qtyCtrl.text.isEmpty) return;
    setState(() => _purchasing = true);
    try {
      await _api.purchaseInventory(planIdCtrl.text.trim(), int.parse(qtyCtrl.text.trim()));
      if (!mounted) return;
      CustomToaster.showSuccess(context, message: trans(context, 'Inventory purchased'));
      _loadData();
    } on ApiException catch (e) {
      if (mounted) CustomToaster.showError(context, message: e.userMessage);
    } catch (e) {
      if (mounted) CustomToaster.showError(context, message: e.toString());
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _importCsv() async {
    CustomToaster.showInfo(context, message: trans(context, 'CSV import via file picker - feature coming soon'));
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), rs(context, 100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: rs(context, 24)),
          Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
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
              Text(trans(context, 'Inventory'), style: TextStyle(
                fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
              const Spacer(),
              Row(
                children: [
                  GestureDetector(
                    onTap: _importCsv,
                    child: Container(
                      padding: EdgeInsets.all(rs(context, 8)),
                      decoration: BoxDecoration(
                        color: dc.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(rs(context, 10)),
                      ),
                      child: _svgIcon('assets/icons/import_icon.svg', rs(context, 18), dc.accent),
                    ),
                  ),
                  SizedBox(width: rs(context, 8)),
                  GestureDetector(
                    onTap: _purchasing ? null : _purchase,
                    child: Container(
                      padding: EdgeInsets.all(rs(context, 8)),
                      decoration: BoxDecoration(
                        color: dc.primaryBtn.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(rs(context, 10)),
                      ),
                      child: _purchasing
                        ? SizedBox(width: rs(context, 18), height: rs(context, 18),
                            child: const CircularProgressIndicator(strokeWidth: 2))
                        : _svgIcon('assets/icons/wallet_add_icon_241828.svg', rs(context, 18), dc.primaryBtn),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: rs(context, 24)),
          _buildStatsCard(dc),
          SizedBox(height: rs(context, 16)),
          _buildIccidCard(dc),
          SizedBox(height: rs(context, 16)),
          _buildBatchesCard(dc),
        ],
      ),
    );
  }

  Widget _buildStatsCard(StroappDialogColors dc) {
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
              _svgIcon('assets/icons/wallet_icon_242153.svg', rs(context, 18), dc.accent),
              SizedBox(width: rs(context, 8)),
              Text(trans(context, 'Statistics'), style: TextStyle(
                fontSize: rs(context, 15), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
            ],
          ),
          SizedBox(height: rs(context, 14)),
          if (_loading)
            const CustomLoader()
          else
            Row(
              children: [
                _statTile(dc, '${_stats?['total'] ?? 0}', trans(context, 'Total'), dc.accent),
                SizedBox(width: rs(context, 8)),
                _statTile(dc, '${_stats?['active'] ?? 0}', trans(context, 'Active'), dc.primaryBtn),
                SizedBox(width: rs(context, 8)),
                _statTile(dc, '${_stats?['used'] ?? 0}', trans(context, 'Used'), dc.textSecondary),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statTile(StroappDialogColors dc, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rs(context, 10)),
        decoration: BoxDecoration(
          color: dc.iconBox.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(rs(context, 14)),
          border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(
              fontSize: rs(context, 16), fontWeight: FontWeight.w700, color: color,
            )),
            Text(label, style: TextStyle(
              fontSize: rs(context, 9), color: dc.textSecondary,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildIccidCard(StroappDialogColors dc) {
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
              _svgIcon('assets/icons/virtual_card.svg', rs(context, 18), dc.primaryBtn),
              SizedBox(width: rs(context, 8)),
              Text(trans(context, 'ICCIDs'), style: TextStyle(
                fontSize: rs(context, 15), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
            ],
          ),
          SizedBox(height: rs(context, 14)),
          if (_loading)
            const CustomLoader()
          else if (_iccidList.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: rs(context, 20)),
              child: Center(child: Text(trans(context, 'No ICCIDs found'),
                style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 14)),
              )),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _iccidList.length,
              separatorBuilder: (_, __) => SizedBox(height: rs(context, 6)),
              itemBuilder: (ctx, i) => _buildIccidTile(_iccidList[i] as Map<String, dynamic>, dc),
            ),
        ],
      ),
    );
  }

  Widget _buildIccidTile(Map<String, dynamic> item, StroappDialogColors dc) {
    final iccid = item['iccid']?.toString() ?? item['id']?.toString() ?? '---';
    final status = item['status']?.toString() ?? 'unknown';
    final isActive = status == 'active' || status == 'activated';
    return Container(
      padding: EdgeInsets.all(rs(context, 10)),
      decoration: BoxDecoration(
        color: dc.iconBox.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: rs(context, 8), height: rs(context, 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : dc.textSecondary,
            ),
          ),
          SizedBox(width: rs(context, 10)),
          Expanded(
            child: Text(iccid, style: TextStyle(
              fontSize: rs(context, 12), fontWeight: FontWeight.w500, color: dc.textPrimary,
            )),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withValues(alpha: 0.15) : dc.textSecondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(rs(context, 6)),
            ),
            child: Text(status, style: TextStyle(
              fontSize: rs(context, 9), color: isActive ? Colors.green : dc.textSecondary,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchesCard(StroappDialogColors dc) {
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
              _svgIcon('assets/icons/import_icon.svg', rs(context, 18), dc.accent),
              SizedBox(width: rs(context, 8)),
              Text(trans(context, 'Import Batches'), style: TextStyle(
                fontSize: rs(context, 15), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
            ],
          ),
          SizedBox(height: rs(context, 14)),
          if (_loading)
            const CustomLoader()
          else if (_batches.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: rs(context, 20)),
              child: Center(child: Text(trans(context, 'No batches found'),
                style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 14)),
              )),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _batches.length,
              separatorBuilder: (_, __) => SizedBox(height: rs(context, 6)),
              itemBuilder: (ctx, i) => _buildBatchTile(_batches[i] as Map<String, dynamic>, dc),
            ),
        ],
      ),
    );
  }

  Widget _buildBatchTile(Map<String, dynamic> batch, StroappDialogColors dc) {
    final id = batch['id']?.toString() ?? '---';
    final count = batch['count']?.toString() ?? batch['total']?.toString() ?? '0';
    final date = batch['created_at']?.toString() ?? '';
    return Container(
      padding: EdgeInsets.all(rs(context, 10)),
      decoration: BoxDecoration(
        color: dc.iconBox.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: [
          _svgIcon('assets/icons/import_icon.svg', rs(context, 16), dc.accent),
          SizedBox(width: rs(context, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Batch #$id', style: TextStyle(
                  fontSize: rs(context, 12), fontWeight: FontWeight.w600, color: dc.textPrimary,
                )),
                if (date.isNotEmpty) Text(date, style: TextStyle(
                  fontSize: rs(context, 9), color: dc.textSecondary,
                )),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
            decoration: BoxDecoration(
              color: dc.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(rs(context, 6)),
            ),
            child: Text('$count items', style: TextStyle(
              fontSize: rs(context, 9), color: dc.accent,
            )),
          ),
        ],
      ),
    );
  }

  Widget _svgIcon(String path, double size, Color color) {
    return SizedBox(
      width: size, height: size,
      child: SvgPicture.asset(path, width: size, height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
