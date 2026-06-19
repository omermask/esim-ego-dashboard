import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/payments_provider.dart';
import '../../data/models/payment_data.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/custom_loader.dart';

class PaymentsWidget extends StatefulWidget {
  final VoidCallback onBack;
  const PaymentsWidget({super.key, required this.onBack});

  @override
  State<PaymentsWidget> createState() => _PaymentsWidgetState();
}

class _PaymentsWidgetState extends State<PaymentsWidget> {
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentsProvider>().load(refresh: true).then((_) {
        if (mounted) setState(() => _initialLoaded = true);
      });
    });
  }

  Future<void> _refresh() async {
    await context.read<PaymentsProvider>().load(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<PaymentsProvider>();
    final payments = provider.payments;
    final loading = provider.loading;
    final hasMore = provider.hasMore;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(
              child: _buildList(dc, payments, loading, hasMore, provider),
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
          Text(trans(context, 'Payments'),
            style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildList(StroappDialogColors dc, List<AdminPayment> payments, bool loading, bool hasMore, PaymentsProvider provider) {
    if (!_initialLoaded && loading) return const Center(child: CustomLoader());
    if (payments.isEmpty && !loading) {
      return Center(
        child: EmptyState(
          message: trans(context, 'No payments found'),
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
          itemCount: payments.length + (hasMore ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i >= payments.length) {
              return const Padding(
                padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildPaymentItem(dc, payments[i]);
          },
        ),
      ),
    );
  }

  Widget _buildPaymentItem(StroappDialogColors dc, AdminPayment p) {
    final statusColor = p.status == 'completed' ? const Color(0xFF4CAF50)
        : p.status == 'pending' ? const Color(0xFFFFA000)
        : p.status == 'failed' ? const Color(0xFFE53935)
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
                  child: Text(p.method.isNotEmpty ? p.method : 'Payment',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(rs(context, 6)),
                  ),
                  child: Text(p.status[0].toUpperCase() + p.status.substring(1),
                    style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: rs(context, 8)),
            if (p.userName != null) ...[
              Text(p.userName!, style: TextStyle(fontSize: rs(context, 13), color: dc.textPrimary)),
              SizedBox(height: rs(context, 2)),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${p.amount} IQD', style: TextStyle(fontSize: rs(context, 14), fontWeight: FontWeight.w700, color: dc.textPrimary)),
                if (p.createdAt != null)
                  Text(_formatDate(p.createdAt!), style: TextStyle(fontSize: rs(context, 10), color: dc.textSecondary)),
              ],
            ),
            if (p.status == 'pending') ...[
              SizedBox(height: rs(context, 10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _confirm(p.id),
                    borderRadius: BorderRadius.circular(rs(context, 10)),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 6)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(rs(context, 10)),
                      ),
                      child: Text(trans(context, 'Confirm'),
                        style: TextStyle(fontSize: rs(context, 12), fontWeight: FontWeight.w600, color: const Color(0xFF4CAF50)),
                      ),
                    ),
                  ),
                ],
              ),
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

  Future<void> _confirm(String id) async {
    final err = await context.read<PaymentsProvider>().confirm(id);
    if (mounted) {
      if (err == null) {
        context.showSuccess(trans(context, 'Payment confirmed'));
      } else {
        context.showError(err);
      }
    }
  }
}
