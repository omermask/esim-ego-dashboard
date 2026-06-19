import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/exchange_rate_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/custom_loader.dart';

class ExchangeRateWidget extends StatefulWidget {
  final VoidCallback onBack;
  const ExchangeRateWidget({super.key, required this.onBack});

  @override
  State<ExchangeRateWidget> createState() => _ExchangeRateWidgetState();
}

class _ExchangeRateWidgetState extends State<ExchangeRateWidget> {
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExchangeRateProvider>().load().then((_) {
        if (mounted) setState(() => _initialLoaded = true);
      });
    });
  }

  Future<void> _fetchNow() async {
    final result = await context.read<ExchangeRateProvider>().fetchNow();
    if (mounted) {
      if (result['success'] == true) {
        context.showSuccess(trans(context, 'Rates updated'));
      } else {
        context.showError(result['error'] ?? 'Failed');
      }
    }
  }

  void _showSetDialog() {
    final baseCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(trans(context, 'Set Exchange Rate')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: baseCtrl, decoration: const InputDecoration(labelText: 'Base Currency (e.g. USD)')),
            TextField(controller: targetCtrl, decoration: const InputDecoration(labelText: 'Target Currency (e.g. IQD)')),
            TextField(controller: rateCtrl, decoration: const InputDecoration(labelText: 'Rate'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(trans(context, 'Cancel'))),
          TextButton(
            onPressed: () async {
              final err = await context.read<ExchangeRateProvider>().set(
                baseCtrl.text.trim().toUpperCase(),
                targetCtrl.text.trim().toUpperCase(),
                rateCtrl.text.trim(),
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (err == null) {
                  context.showSuccess(trans(context, 'Rate set'));
                } else {
                  context.showError(err);
                }
              }
            },
            child: Text(trans(context, 'Set')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<ExchangeRateProvider>();
    final rates = provider.rates;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(
              child: !_initialLoaded && provider.loading
                  ? const Center(child: CustomLoader())
                  : RefreshIndicator(
                      onRefresh: () => provider.load(),
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 100)),
                        itemCount: rates.length,
                        itemBuilder: (ctx, i) => _buildRateItem(dc, rates[i]),
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
          Expanded(
            child: Text(trans(context, 'Exchange Rates'),
              style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
            ),
          ),
          InkWell(
            onTap: _fetchNow,
            borderRadius: BorderRadius.circular(rs(context, 10)),
            child: Container(
              padding: EdgeInsets.all(rs(context, 10)),
              decoration: BoxDecoration(color: const Color(0xFFFFA000), borderRadius: BorderRadius.circular(rs(context, 10))),
              child: SvgPicture.asset('assets/icons/refresh_square_icon_242173.svg',
                width: rs(context, 20), colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(width: rs(context, 8)),
          InkWell(
            onTap: _showSetDialog,
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

  Widget _buildRateItem(StroappDialogColors dc, dynamic rate) {
    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 10)),
      padding: EdgeInsets.all(rs(context, 14)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${rate.baseCurrency} → ${rate.targetCurrency}',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary),
                ),
                SizedBox(height: rs(context, 4)),
                Text('1 ${rate.baseCurrency} = ${rate.rate} ${rate.targetCurrency}',
                  style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary),
                ),
              ],
            ),
          ),
          if (rate.source.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
              decoration: BoxDecoration(
                color: dc.iconBox,
                borderRadius: BorderRadius.circular(rs(context, 6)),
              ),
              child: Text(rate.source,
                style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600, color: dc.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
