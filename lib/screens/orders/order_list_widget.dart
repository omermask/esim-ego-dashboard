import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/orders_provider.dart';
import '../../data/models/order_data.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/custom_loader.dart';

class OrderListWidget extends StatefulWidget {
  final VoidCallback onBack;
  const OrderListWidget({super.key, required this.onBack});

  @override
  State<OrderListWidget> createState() => _OrderListWidgetState();
}

class _OrderListWidgetState extends State<OrderListWidget> {
  String _filter = 'all';
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().load(refresh: true).then((_) {
        if (mounted) setState(() => _initialLoaded = true);
      });
    });
  }

  Future<void> _refresh() async {
    await context.read<OrdersProvider>().load(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<OrdersProvider>();
    final orders = provider.orders;
    final loading = provider.loading;
    final hasMore = provider.hasMore;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            _buildFilterChips(dc),
            Expanded(
              child: _buildList(dc, orders, loading, hasMore, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dc) {
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
          Text(trans(context, 'All Orders'),
            style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(dc) {
    final filters = ['all', 'pending', 'paid', 'cancelled', 'refunded', 'failed'];
    return Container(
      height: rs(context, 50),
      margin: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: rs(context, 8)),
        itemBuilder: (ctx, i) {
          final f = filters[i];
          final sel = _filter == f;
          return InkWell(
            onTap: () {
              setState(() => _filter = f);
              context.read<OrdersProvider>().setFilter(f == 'all' ? null : f);
            },
            borderRadius: BorderRadius.circular(rs(context, 20)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 8)),
              decoration: BoxDecoration(
                color: sel ? dc.accent : dc.iconBox,
                borderRadius: BorderRadius.circular(rs(context, 20)),
              ),
              child: Text(
                trans(context, f[0].toUpperCase() + f.substring(1)),
                style: TextStyle(
                  fontSize: rs(context, 13),
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : dc.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(dc, List<AdminOrder> orders, bool loading, bool hasMore, OrdersProvider provider) {
    if (!_initialLoaded && loading) return const Center(child: CustomLoader());
    if (orders.isEmpty && !loading) {
      return Center(
        child: EmptyState(
          message: trans(context, 'No orders found'),
          onRetry: _refresh,
        ),
      );
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
          itemCount: orders.length + (hasMore ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i >= orders.length) {
              return const Padding(
                padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildOrderItem(dc, orders[i]);
          },
        ),
      ),
    );
  }

  Widget _buildOrderItem(dc, AdminOrder o) {
    final statusColor = _statusColor(o.status);
    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 10)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: InkWell(
        onTap: () => _openDetail(o),
        borderRadius: BorderRadius.circular(rs(context, 16)),
        child: Padding(
          padding: EdgeInsets.all(rs(context, 14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('#${o.id.substring(0, 8)}...',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 4)),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(rs(context, 8)),
                    ),
                    child: Text(o.statusLabel,
                      style: TextStyle(fontSize: rs(context, 11), fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: rs(context, 8)),
              if (o.userName != null) ...[
                Text(o.userName!, style: TextStyle(fontSize: rs(context, 13), color: dc.textPrimary)),
                SizedBox(height: rs(context, 2)),
              ],
              if (o.userPhone != null)
                Text(o.userPhone!, style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary)),
              SizedBox(height: rs(context, 6)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(o.planName ?? 'N/A', style: TextStyle(fontSize: rs(context, 12), color: dc.accent)),
                  Text('${o.totalPriceIqd.toStringAsFixed(0)} ${o.currency}',
                    style: TextStyle(fontSize: rs(context, 14), fontWeight: FontWeight.w700, color: dc.textPrimary),
                  ),
                ],
              ),
              if (o.createdAt != null) ...[
                SizedBox(height: rs(context, 4)),
                Text(_formatDate(o.createdAt!), style: TextStyle(fontSize: rs(context, 10), color: dc.textSecondary)),
              ],
              if (o.status == 'pending') ...[
                SizedBox(height: rs(context), 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionBtn(trans(context, 'Approve'), const Color(0xFF4CAF50), () => _approve(o.id)),
                    SizedBox(width: rs(context, 8)),
                    _actionBtn(trans(context, 'Cancel'), const Color(0xFFC62828), () => _cancel(o.id)),
                  ],
                ),
              ],
              if (o.status == 'failed') ...[
                SizedBox(height: rs(context), 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionBtn(trans(context, 'Reprocess'), const Color(0xFFFFA000), () => _reprocess(o.id)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs(context, 10)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 6)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(rs(context, 10)),
        ),
        child: Text(label,
          style: TextStyle(fontSize: rs(context, 12), fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending': return const Color(0xFFFFA000);
      case 'paid': return const Color(0xFF4CAF50);
      case 'cancelled': return const Color(0xFFC62828);
      case 'refunded': return const Color(0xFF1565C0);
      case 'failed': return const Color(0xFFE53935);
      default: return const Color(0xFF757575);
    }
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return d;
    }
  }

  void _openDetail(AdminOrder o) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _OrderDetailPage(order: o)),
    );
  }

  Future<void> _approve(String id) async {
    final err = await context.read<OrdersProvider>().approve(id);
    if (mounted) {
      if (err == null) {
        context.showSuccess(trans(context, 'Order approved'));
      } else {
        context.showError(err);
      }
    }
  }

  Future<void> _cancel(String id) async {
    final err = await context.read<OrdersProvider>().cancel(id);
    if (mounted) {
      if (err == null) {
        context.showSuccess(trans(context, 'Order cancelled'));
      } else {
        context.showError(err);
      }
    }
  }

  Future<void> _reprocess(String id) async {
    final err = await context.read<OrdersProvider>().reprocess(id);
    if (mounted) {
      if (err == null) {
        context.showSuccess(trans(context, 'Order reprocessed'));
      } else {
        context.showError(err);
      }
    }
  }
}

class _OrderDetailPage extends StatelessWidget {
  final AdminOrder order;
  const _OrderDetailPage({required this.order});

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final o = order;

    return Scaffold(
      appBar: AppBar(
        title: Text('#${o.id.substring(0, 8)}...'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(rs(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(context, dc, 'Order Information', [
              _row('Status', o.statusLabel, context),
              _row('Currency', o.currency, context),
              _row('Total', '${o.totalPriceIqd} IQD', context),
              _row('Tax', '${o.taxAmount} IQD', context),
              _row('Discount', '${o.discountAmount} IQD', context),
              _row('Cost', '${o.costPriceIqd} IQD', context),
              if (o.couponCode != null) _row('Coupon', o.couponCode!, context),
            ]),
            SizedBox(height: rs(context, 16)),
            _infoCard(context, dc, 'Customer', [
              if (o.userName != null) _row('Name', o.userName!, context),
              if (o.userPhone != null) _row('Phone', o.userPhone!, context),
            ]),
            SizedBox(height: rs(context, 16)),
            _infoCard(context, dc, 'Plan', [
              _row('Plan', o.planName ?? 'N/A', context),
              _row('Quantity', '${o.quantity}', context),
            ]),
            if (o.items.isNotEmpty) ...[
              SizedBox(height: rs(context, 16)),
              _infoCard(context, dc, 'Items (${o.items.length})', o.items.map((item) {
                return _row('eSIM ${item.esimIccid ?? ''}', item.status, context);
              }).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, dc, String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 14)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary)),
          SizedBox(height: rs(context, 10)),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value, BuildContext ctx) {
    final c = ctx.dialogColors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(ctx, 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: rs(ctx, 13), color: c.textSecondary)),
          Text(value, style: TextStyle(fontSize: rs(ctx, 13), fontWeight: FontWeight.w600, color: c.textPrimary)),
        ],
      ),
    );
  }
}
