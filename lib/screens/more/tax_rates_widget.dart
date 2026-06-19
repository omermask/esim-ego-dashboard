import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/tax_rate_provider.dart';
import '../../data/models/tax_rate_data.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/custom_loader.dart';

class TaxRatesWidget extends StatefulWidget {
  final VoidCallback onBack;
  const TaxRatesWidget({super.key, required this.onBack});

  @override
  State<TaxRatesWidget> createState() => _TaxRatesWidgetState();
}

class _TaxRatesWidgetState extends State<TaxRatesWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaxRateProvider>().load();
    });
  }

  Future<void> _refresh() async {
    await context.read<TaxRateProvider>().load();
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final pctCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(trans(context, 'Create Tax Rate')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              SizedBox(height: rs(context, 12)),
              TextField(controller: pctCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Percentage')),
              SizedBox(height: rs(context, 12)),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(trans(context, 'Cancel'))),
          ElevatedButton(
            onPressed: () async {
              final err = await context.read<TaxRateProvider>().create(
                nameCtrl.text.trim(), pctCtrl.text.trim(), description: descCtrl.text.trim(),
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (err == null) {
                  context.showSuccess(trans(context, 'Tax rate created'));
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
    final provider = context.watch<TaxRateProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(child: _buildContent(dc, provider)),
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
            child: Text(trans(context, 'Tax Rates'),
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

  Widget _buildContent(StroappDialogColors dc, TaxRateProvider provider) {
    if (provider.loading) return const Center(child: CustomLoader());
    if (provider.rates.isEmpty) {
      return Center(child: EmptyState(message: trans(context, 'No tax rates found'), onRetry: _refresh));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 100)),
        itemCount: provider.rates.length,
        itemBuilder: (ctx, i) => _buildRateItem(dc, provider.rates[i]),
      ),
    );
  }

  Widget _buildRateItem(StroappDialogColors dc, TaxRate r) {
    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 10)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(rs(context, 14)),
        child: Row(
          children: [
            Container(
              width: rs(context, 48), height: rs(context, 48),
              decoration: BoxDecoration(color: const Color(0xFFFFA000).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(rs(context, 14))),
              child: Center(
                child: Text('${r.percentage}%',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs(context, 16), color: const Color(0xFFFFA000)),
                ),
              ),
            ),
            SizedBox(width: rs(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary)),
                  if (r.description.isNotEmpty) ...[
                    SizedBox(height: rs(context, 2)),
                    Text(r.description, style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary)),
                  ],
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
              decoration: BoxDecoration(
                color: r.isActive ? const Color(0xFF4CAF50).withValues(alpha: 0.15) : const Color(0xFFC62828).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(rs(context, 6)),
              ),
              child: Text(r.isActive ? 'Active' : 'Inactive',
                style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600,
                  color: r.isActive ? const Color(0xFF4CAF50) : const Color(0xFFC62828),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
