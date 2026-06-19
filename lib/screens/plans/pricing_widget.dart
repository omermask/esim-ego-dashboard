import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/services/api_service.dart';
import '../../data/providers/plans_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/custom_loader.dart';

class PricingWidget extends StatefulWidget {
  final VoidCallback onBack;
  const PricingWidget({super.key, required this.onBack});

  @override
  State<PricingWidget> createState() => _PricingWidgetState();
}

class _PricingWidgetState extends State<PricingWidget> {
  final _api = ApiService();
  List<dynamic> _rates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final ratesData = await _api.getExchangeRates();
      if (!mounted) return;
      setState(() {
        _rates = (ratesData['rates'] as List?) ?? (ratesData['items'] as List?) ?? [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; });
    }
  }

  Future<void> _addRate() async {
    final baseCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(trans(context, 'Add Exchange Rate')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: baseCtrl, decoration: const InputDecoration(labelText: 'Base Currency', hintText: 'USD')),
            SizedBox(height: rs(context, 8)),
            TextField(controller: targetCtrl, decoration: const InputDecoration(labelText: 'Target Currency', hintText: 'IQD')),
            SizedBox(height: rs(context, 8)),
            TextField(controller: rateCtrl, decoration: const InputDecoration(labelText: 'Rate', hintText: '1500'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(trans(context, 'Cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(trans(context, 'Add'))),
        ],
      ),
    );
    if (result != true || baseCtrl.text.isEmpty || targetCtrl.text.isEmpty || rateCtrl.text.isEmpty) return;
    try {
      await _api.setExchangeRate(baseCtrl.text.trim(), targetCtrl.text.trim(), rateCtrl.text.trim());
      if (!mounted) return;
      CustomToaster.showSuccess(context, message: trans(context, 'Exchange rate added'));
      _load();
    } on ApiException catch (e) {
      if (mounted) CustomToaster.showError(context, message: e.userMessage);
    } catch (e) {
      if (mounted) CustomToaster.showError(context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final p = context.watch<PlansProvider>();
    final plans = p.plans;

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
              Text(trans(context, 'Pricing'), style: TextStyle(
                fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
            ],
          ),
          SizedBox(height: rs(context, 24)),
          _buildRatesCard(dc),
          SizedBox(height: rs(context, 16)),
          _buildPlanPricingCard(dc, plans),
        ],
      ),
    );
  }

  Widget _buildRatesCard(StroappDialogColors dc) {
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
              _svgIcon('assets/icons/exchange-alt.svg', rs(context, 18), dc.accent),
              SizedBox(width: rs(context, 8)),
              Text(trans(context, 'Exchange Rates'), style: TextStyle(
                fontSize: rs(context, 15), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
              const Spacer(),
              GestureDetector(
                onTap: _addRate,
                child: Container(
                  padding: EdgeInsets.all(rs(context, 6)),
                  decoration: BoxDecoration(
                    color: dc.primaryBtn.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(rs(context, 8)),
                  ),
                  child: _svgIcon('assets/icons/wallet_add_icon_241828.svg', rs(context, 14), dc.primaryBtn),
                ),
              ),
            ],
          ),
          SizedBox(height: rs(context, 14)),
          if (_loading)
            const CustomLoader()
          else if (_rates.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: rs(context, 20)),
              child: Center(child: Text(trans(context, 'No exchange rates'),
                style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 14)),
              )),
            )
          else
            ..._rates.map((r) {
              final rate = r as Map<String, dynamic>;
              final base = rate['base_currency'] ?? rate['base'] ?? 'USD';
              final target = rate['target_currency'] ?? rate['target'] ?? 'IQD';
              final val = rate['rate']?.toString() ?? '0';
              return Container(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 10)),
                margin: EdgeInsets.only(bottom: rs(context, 6)),
                decoration: BoxDecoration(
                  color: dc.iconBox.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
                ),
                child: Row(
                  children: [
                    _svgIcon('assets/icons/moneys_icon_242132.svg', rs(context, 16), dc.accent),
                    SizedBox(width: rs(context, 10)),
                    Text('$base → $target', style: TextStyle(
                      fontSize: rs(context, 13), fontWeight: FontWeight.w600, color: dc.textPrimary,
                    )),
                    const Spacer(),
                    Text(val, style: TextStyle(
                      fontSize: rs(context, 14), fontWeight: FontWeight.w700, color: dc.primaryBtn,
                    )),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPlanPricingCard(StroappDialogColors dc, List<dynamic> plans) {
    final displayPlans = plans.length > 20 ? plans.sublist(0, 20) : plans;
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
              _svgIcon('assets/icons/coinicon_114542.svg', rs(context, 18), dc.primaryBtn),
              SizedBox(width: rs(context, 8)),
              Text(trans(context, 'Plan Pricing'), style: TextStyle(
                fontSize: rs(context, 15), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
            ],
          ),
          SizedBox(height: rs(context, 14)),
          if (displayPlans.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: rs(context, 20)),
              child: Center(child: Text(trans(context, 'No plans'),
                style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 14)),
              )),
            )
          else
            ...displayPlans.map((plan) {
              final p = plan as dynamic;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 10)),
                margin: EdgeInsets.only(bottom: rs(context, 6)),
                decoration: BoxDecoration(
                  color: dc.iconBox.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: TextStyle(
                            fontSize: rs(context, 12), fontWeight: FontWeight.w600, color: dc.textPrimary,
                          ), maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: rs(context, 2)),
                          Text('\$${p.priceUsd.toStringAsFixed(2)} / ${NumberFormat('#,##0').format(p.priceIqd)} IQD', style: TextStyle(
                            fontSize: rs(context, 10), color: dc.textSecondary,
                          )),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 4)),
                      decoration: BoxDecoration(
                        color: dc.primaryBtn.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(rs(context, 6)),
                      ),
                      child: Text('${p.markupPercentage.toStringAsFixed(0)}%', style: TextStyle(
                        fontSize: rs(context, 10), fontWeight: FontWeight.w600, color: dc.primaryBtn,
                      )),
                    ),
                  ],
                ),
              );
            }),
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
