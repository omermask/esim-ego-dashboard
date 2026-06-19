import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/refund_provider.dart';
import '../../data/models/refund_data.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/custom_loader.dart';

class RefundsWidget extends StatefulWidget {
  final VoidCallback onBack;
  const RefundsWidget({super.key, required this.onBack});

  @override
  State<RefundsWidget> createState() => _RefundsWidgetState();
}

class _RefundsWidgetState extends State<RefundsWidget> {
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RefundProvider>().load(refresh: true).then((_) {
        if (mounted) setState(() => _initialLoaded = true);
      });
    });
  }

  Future<void> _refresh() async {
    await context.read<RefundProvider>().load(refresh: true);
  }

  void _showCreateDialog() {
    final orderCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(trans(context, 'Create Refund')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: orderCtrl, decoration: const InputDecoration(labelText: 'Order ID')),
              SizedBox(height: rs(context, 12)),
              TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount')),
              SizedBox(height: rs(context, 12)),
              TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Reason')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(trans(context, 'Cancel'))),
          ElevatedButton(
            onPressed: () async {
              final amt = int.tryParse(amtCtrl.text.trim());
              final err = await context.read<RefundProvider>().create(
                orderCtrl.text.trim(), amount: amt, reason: reasonCtrl.text.trim(),
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (err == null) {
                  context.showSuccess(trans(context, 'Refund created'));
                } else {
                  context.showError(err);
                }
              }
            },
            child: Text(trans(context, 'Create')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<RefundProvider>();
    final refunds = provider.refunds;
    final loading = provider.loading;
    final hasMore = provider.hasMore;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(child: _buildContent(dc, refunds, loading, hasMore, provider)),
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
          Expanded(
            child: Text(trans(context, 'Refunds'),
              style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
            ),
          ),
          InkWell(
            onTap: _showCreateDialog,
            borderRadius: BorderRadius.circular(rs(context, 10)),
            child: Container(
              padding: EdgeInsets.all(rs(context, 10)),
              decoration: BoxDecoration(color: dc.accent, borderRadius: BorderRadius.circular(rs(context, 10))),
              child: SvgPicture.asset('assets/icons/save_add_icon_241850.svg',
                width: rs(context, 20), colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(StroappDialogColors dc, List<Refund> refunds, bool loading, bool hasMore, RefundProvider provider) {
    if (!_initialLoaded && loading) return const Center(child: CustomLoader());
    if (refunds.isEmpty && !loading) {
      return Center(child: EmptyState(message: trans(context, 'No refunds found'), onRetry: _refresh));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (s) {
        if (s is ScrollEndNotification && !loading && hasMore) {
          provider.load();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 100)),
          itemCount: refunds.length + (hasMore ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i >= refunds.length) {
              return const Padding(
                padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildRefundItem(dc, refunds[i]);
          },
        ),
      ),
    );
  }

  Widget _buildRefundItem(StroappDialogColors dc, Refund r) {
    final statusColor = r.status == 'completed' ? const Color(0xFF4CAF50)
        : r.status == 'pending' ? const Color(0xFFFFA000)
        : r.status == 'cancelled' ? const Color(0xFFC62828)
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
                  child: Text('Order #${r.orderId.length > 8 ? r.orderId.substring(0, 8) : r.orderId}',
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
            SizedBox(height: rs(context, 8)),
            if (r.userName != null)
              Text(r.userName!, style: TextStyle(fontSize: rs(context, 13), color: dc.textPrimary)),
            SizedBox(height: rs(context, 4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${r.amount} IQD', style: TextStyle(fontSize: rs(context, 14), fontWeight: FontWeight.w700, color: dc.textPrimary)),
                if (r.createdAt != null)
                  Text(_formatDate(r.createdAt!), style: TextStyle(fontSize: rs(context, 10), color: dc.textSecondary)),
              ],
            ),
            if (r.reason.isNotEmpty) ...[
              SizedBox(height: rs(context, 4)),
              Text(r.reason, style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return d;
    }
  }
}
