import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/providers/plans_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/services/api_service.dart';
import '../../data/models/plan_data.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/custom_loader.dart';

class PlanDetailWidget extends StatefulWidget {
  final AdminPlan plan;
  final VoidCallback onBack;
  const PlanDetailWidget({super.key, required this.plan, required this.onBack});

  @override
  State<PlanDetailWidget> createState() => _PlanDetailWidgetState();
}

class _PlanDetailWidgetState extends State<PlanDetailWidget> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _dataCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _priceUsdCtrl;
  late TextEditingController _priceIqdCtrl;
  late TextEditingController _markupCtrl;
  late TextEditingController _countriesCtrl;
  late TextEditingController _bundleIdCtrl;
  late TextEditingController _sortOrderCtrl;
  bool _isActive = true;
  bool _saving = false;
  bool _deleting = false;
  List<dynamic> _rates = [];
  bool _ratesLoading = true;
  Map<String, dynamic>? _providerDetail;
  bool _providerLoading = false;
  String _officialCurrency = 'IQD';

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _nameCtrl = TextEditingController(text: p.name);
    _descCtrl = TextEditingController(text: p.description);
    _dataCtrl = TextEditingController(text: p.dataAmountMb.toString());
    _durationCtrl = TextEditingController(text: p.durationDays.toString());
    _priceUsdCtrl = TextEditingController(text: p.priceUsd.toStringAsFixed(2));
    _priceIqdCtrl = TextEditingController(text: p.priceIqd.toString());
    _markupCtrl = TextEditingController(text: p.markupPercentage.toStringAsFixed(1));
    _countriesCtrl = TextEditingController(text: p.countries);
    _bundleIdCtrl = TextEditingController(text: p.providerBundleId);
    _sortOrderCtrl = TextEditingController(text: p.sortOrder.toString());
    _isActive = p.isActive;
    _loadRates();
    _loadProviderDetail();
  }

  bool _initDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initDone) {
      _initDone = true;
      Future.microtask(() {
        if (!mounted) return;
        final sp = context.read<SettingsProvider>();
        sp.loadServerConfig().then((_) {
          if (mounted) {
            setState(() => _officialCurrency = sp.officialCurrency);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _dataCtrl.dispose();
    _durationCtrl.dispose();
    _priceUsdCtrl.dispose();
    _priceIqdCtrl.dispose();
    _markupCtrl.dispose();
    _countriesCtrl.dispose();
    _bundleIdCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRates() async {
    try {
      final data = await _api.getExchangeRates();
      if (!mounted) return;
      setState(() {
        _rates = (data['rates'] as List?) ?? (data['items'] as List?) ?? [];
        _ratesLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _ratesLoading = false);
    }
  }

  String _getOfficialPrice(num usdPrice) {
    if (_officialCurrency == 'IQD') {
      final plan = widget.plan;
      if (plan.priceIqd > 0) return '${NumberFormat('#,##0').format(plan.priceIqd)} IQD';
    }
    for (final r in _rates) {
      final rate = r as Map<String, dynamic>;
      final target = rate['target_currency'] ?? rate['target'] ?? '';
      if (target == _officialCurrency) {
        final val = double.tryParse(rate['rate']?.toString() ?? '') ?? 0;
        if (val > 0) {
          final converted = usdPrice * val;
          return '${NumberFormat('#,##0.##').format(converted)} $_officialCurrency';
        }
      }
    }
    return '\$${usdPrice.toStringAsFixed(2)}';
  }

  Future<void> _loadProviderDetail() async {
    final bundleId = widget.plan.providerBundleId;
    if (bundleId.isEmpty) return;
    setState(() => _providerLoading = true);
    try {
      final d = await context.read<PlansProvider>().fetchBundleDetail(bundleId);
      if (!mounted) return;
      final bundle = d?['bundle'] as Map<String, dynamic>? ?? d;
      setState(() { _providerDetail = bundle; _providerLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _providerLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = <String, dynamic>{};
    final orig = widget.plan;
    final name = _nameCtrl.text.trim();
    if (name != orig.name) data['name'] = name;
    final desc = _descCtrl.text.trim();
    if (desc != orig.description) data['description'] = desc;
    final dataMb = int.tryParse(_dataCtrl.text.trim()) ?? orig.dataAmountMb;
    if (dataMb != orig.dataAmountMb) data['data_amount_mb'] = dataMb;
    final dur = int.tryParse(_durationCtrl.text.trim()) ?? orig.durationDays;
    if (dur != orig.durationDays) data['duration_days'] = dur;
    final usd = double.tryParse(_priceUsdCtrl.text.trim()) ?? orig.priceUsd;
    if (usd != orig.priceUsd) data['price_usd'] = usd;
    final iqd = int.tryParse(_priceIqdCtrl.text.trim()) ?? orig.priceIqd;
    if (iqd != orig.priceIqd) data['price_iqd'] = iqd;
    final markup = double.tryParse(_markupCtrl.text.trim()) ?? orig.markupPercentage;
    if (markup != orig.markupPercentage) data['markup_percentage'] = markup;
    final countries = _countriesCtrl.text.trim();
    if (countries != orig.countries) data['countries'] = countries;
    final bundleId = _bundleIdCtrl.text.trim();
    if (bundleId != orig.providerBundleId) data['provider_bundle_id'] = bundleId;
    final sort = int.tryParse(_sortOrderCtrl.text.trim()) ?? orig.sortOrder;
    if (sort != orig.sortOrder) data['sort_order'] = sort;
    if (_isActive != orig.isActive) data['is_active'] = _isActive;

    if (data.isEmpty) {
      CustomToaster.showInfo(context, message: trans(context, 'No changes'));
      setState(() => _saving = false);
      return;
    }

    final err = await context.read<PlansProvider>().update(orig.id, data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      CustomToaster.showError(context, message: err);
    } else {
      CustomToaster.showSuccess(context, message: trans(context, 'Plan updated'));
      widget.onBack();
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(trans(context, 'Delete Plan')),
        content: Text('${trans(context, 'Delete')} "${widget.plan.name}"? ${trans(context, 'This cannot be undone.')}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(trans(context, 'Cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(trans(context, 'Delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _deleting = true);
    final err = await context.read<PlansProvider>().delete(widget.plan.id);
    if (!mounted) return;
    if (err != null) {
      CustomToaster.showError(context, message: err);
      setState(() => _deleting = false);
    } else {
      CustomToaster.showSuccess(context, message: trans(context, 'Plan deleted'));
      widget.onBack();
    }
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
              Expanded(
                child: Text(widget.plan.name, style: TextStyle(
                  fontSize: rs(context, 20), fontWeight: FontWeight.w700, color: dc.textPrimary,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          _buildPlanInfoCard(dc),
          if (widget.plan.providerBundleId.isNotEmpty) ...[
            SizedBox(height: rs(context, 16)),
            _buildProviderBundleCard(dc),
          ],
          SizedBox(height: rs(context, 16)),
          _buildDetailsCard(dc),
          SizedBox(height: rs(context, 16)),
          _buildPricingCard(dc),
          SizedBox(height: rs(context, 16)),
          _buildExchangeRatesCard(dc),
          SizedBox(height: rs(context, 20)),
          _buildActions(dc),
        ],
      ),
    );
  }

  List<String> _parseCountries(String raw) {
    if (raw.isEmpty || raw == 'all') return [];
    return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Widget _buildPlanInfoCard(StroappDialogColors dc) {
    final p = widget.plan;
    final double gb = p.dataAmountMb / 1000.0;
    final countries = _parseCountries(p.countries);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 14)),
      decoration: BoxDecoration(
        color: dc.iconBox.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _svgIcon('assets/icons/info_square_icon_184028.svg', rs(context, 16), dc.accent),
              SizedBox(width: rs(context, 8)),
              Text(trans(context, 'Plan Info'), style: TextStyle(
                fontSize: rs(context, 15), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
            ],
          ),
          SizedBox(height: rs(context, 12)),
          _infoRow(dc, 'ID', p.id, isMono: true),
          SizedBox(height: rs(context, 6)),
          Row(
            children: [
              Expanded(child: _infoRow(dc, '${trans(context, 'Data')} (GB)', gb.toStringAsFixed(2))),
              SizedBox(width: rs(context, 10)),
              Expanded(child: _infoRow(dc, '${trans(context, 'Duration')} (${trans(context, 'days')})', p.durationDays.toString())),
            ],
          ),
          if (countries.isNotEmpty) ...[
            SizedBox(height: rs(context, 8)),
            Text(trans(context, 'Countries'), style: TextStyle(
              fontSize: rs(context, 10), color: dc.textSecondary, fontWeight: FontWeight.w500,
            )),
            SizedBox(height: rs(context, 6)),
            Wrap(
              spacing: rs(context, 6),
              runSpacing: rs(context, 6),
              children: countries.map((c) => _countryChip(dc, c)).toList(),
            ),
          ],
          if (p.createdAt != null) ...[
            SizedBox(height: rs(context, 6)),
            _infoRow(dc, trans(context, 'Created'), p.createdAt!),
          ],
          if (p.updatedAt != null) ...[
            SizedBox(height: rs(context, 6)),
            _infoRow(dc, trans(context, 'Updated'), p.updatedAt!),
          ],
        ],
      ),
    );
  }

  Widget _countryChip(StroappDialogColors dc, String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 5)),
      decoration: BoxDecoration(
        color: dc.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: dc.accent.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_countryFlag(name), style: TextStyle(fontSize: rs(context, 12))),
          SizedBox(width: rs(context, 5)),
          Text(name, style: TextStyle(
            fontSize: rs(context, 11), color: dc.accent, fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }

  String _countryFlag(String name) {
    final known = <String, String>{
      'united states': '\u{1F1FA}\u{1F1F8}',
      'united kingdom': '\u{1F1EC}\u{1F1E7}',
      'france': '\u{1F1EB}\u{1F1F7}',
      'germany': '\u{1F1E9}\u{1F1EA}',
      'italy': '\u{1F1EE}\u{1F1F9}',
      'spain': '\u{1F1EA}\u{1F1F8}',
      'japan': '\u{1F1EF}\u{1F1F5}',
      'china': '\u{1F1E8}\u{1F1F3}',
      'india': '\u{1F1EE}\u{1F1F3}',
      'australia': '\u{1F1E6}\u{1F1FA}',
      'canada': '\u{1F1E8}\u{1F1E6}',
      'brazil': '\u{1F1E7}\u{1F1F7}',
      'mexico': '\u{1F1F2}\u{1F1FD}',
      'uae': '\u{1F1E6}\u{1F1EA}',
      'saudi arabia': '\u{1F1F8}\u{1F1E6}',
      'egypt': '\u{1F1EA}\u{1F1EC}',
      'turkey': '\u{1F1F9}\u{1F1F7}',
      'russia': '\u{1F1F7}\u{1F1FA}',
      'south korea': '\u{1F1F0}\u{1F1F7}',
      'thailand': '\u{1F1F9}\u{1F1ED}',
      'singapore': '\u{1F1F8}\u{1F1EC}',
      'malaysia': '\u{1F1F2}\u{1F1FE}',
      'indonesia': '\u{1F1EE}\u{1F1E9}',
      'netherlands': '\u{1F1F3}\u{1F1F1}',
      'switzerland': '\u{1F1E8}\u{1F1ED}',
      'sweden': '\u{1F1F8}\u{1F1EA}',
      'norway': '\u{1F1F3}\u{1F1F4}',
      'poland': '\u{1F1F5}\u{1F1F1}',
      'portugal': '\u{1F1F5}\u{1F1F9}',
      'austria': '\u{1F1E6}\u{1F1F9}',
      'belgium': '\u{1F1E7}\u{1F1EA}',
      'denmark': '\u{1F1E9}\u{1F1F0}',
      'finland': '\u{1F1EB}\u{1F1EE}',
      'greece': '\u{1F1EC}\u{1F1F7}',
      'ireland': '\u{1F1EE}\u{1F1EA}',
      'new zealand': '\u{1F1F3}\u{1F1FF}',
      'south africa': '\u{1F1FF}\u{1F1E6}',
      'argentina': '\u{1F1E6}\u{1F1F7}',
      'colombia': '\u{1F1E8}\u{1F1F4}',
      'chile': '\u{1F1E8}\u{1F1F1}',
      'peru': '\u{1F1F5}\u{1F1EA}',
      'vietnam': '\u{1F1FB}\u{1F1F3}',
      'philippines': '\u{1F1F5}\u{1F1ED}',
      'hong kong': '\u{1F1ED}\u{1F1F0}',
      'taiwan': '\u{1F1F9}\u{1F1FC}',
      'israel': '\u{1F1EE}\u{1F1F1}',
      'qatar': '\u{1F1F6}\u{1F1E6}',
      'kuwait': '\u{1F1F0}\u{1F1FC}',
      'oman': '\u{1F1F4}\u{1F1F2}',
      'bahrain': '\u{1F1E7}\u{1F1ED}',
      'morocco': '\u{1F1F2}\u{1F1E6}',
      'nigeria': '\u{1F1F3}\u{1F1EC}',
      'kenya': '\u{1F1F0}\u{1F1EA}',
      'ukraine': '\u{1F1FA}\u{1F1E6}',
      'czech republic': '\u{1F1E8}\u{1F1FF}',
      'romania': '\u{1F1F7}\u{1F1F4}',
      'hungary': '\u{1F1ED}\u{1F1FA}',
      'croatia': '\u{1F1ED}\u{1F1F7}',
      'serbia': '\u{1F1F7}\u{1F1F8}',
      'bulgaria': '\u{1F1E7}\u{1F1EC}',
      'slovakia': '\u{1F1F8}\u{1F1F0}',
      'slovenia': '\u{1F1F8}\u{1F1EE}',
      'lithuania': '\u{1F1F1}\u{1F1F9}',
      'latvia': '\u{1F1F1}\u{1F1FB}',
      'estonia': '\u{1F1EA}\u{1F1EA}',
      'luxembourg': '\u{1F1F1}\u{1F1FA}',
      'malta': '\u{1F1F2}\u{1F1F9}',
      'iceland': '\u{1F1EE}\u{1F1F8}',
      'cyprus': '\u{1F1E8}\u{1F1FE}',
      'global': '\u{1F30D}',
    };
    return known[name.toLowerCase()] ?? '\u{1F310}';
  }

  Widget _infoRow(StroappDialogColors dc, String label, String value, {bool isMono = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: rs(context, 80),
          child: Text(label, style: TextStyle(
            fontSize: rs(context, 10), color: dc.textSecondary, fontWeight: FontWeight.w500,
          )),
        ),
        Expanded(child: Text(value, style: TextStyle(
          fontSize: rs(context, 12), color: dc.textPrimary, fontWeight: FontWeight.w500,
          fontFamily: isMono ? 'monospace' : null,
        ), maxLines: 2, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildDetailsCard(StroappDialogColors dc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 14)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _svgIcon('assets/icons/virtual_card.svg', rs(context, 18), dc.accent),
                SizedBox(width: rs(context, 8)),
                Text(trans(context, 'Plan Details'), style: TextStyle(
                  fontSize: rs(context, 15), fontWeight: FontWeight.w700, color: dc.textPrimary,
                )),
              ],
            ),
            SizedBox(height: rs(context, 14)),
            _field(trans(context, 'Name'), _nameCtrl, required: true),
            SizedBox(height: rs(context, 10)),
            _field(trans(context, 'Description'), _descCtrl, maxLines: 2),
            SizedBox(height: rs(context, 10)),
            Row(
              children: [
                Expanded(child: _field(trans(context, 'Data (MB)'), _dataCtrl, keyboardType: TextInputType.number, required: true)),
                SizedBox(width: rs(context, 10)),
                Expanded(child: _field(trans(context, 'Duration (days)'), _durationCtrl, keyboardType: TextInputType.number, required: true)),
              ],
            ),
            SizedBox(height: rs(context, 10)),
            _buildCountriesField(dc),
            SizedBox(height: rs(context, 10)),
            _field(trans(context, 'Provider Bundle ID'), _bundleIdCtrl),
            SizedBox(height: rs(context, 10)),
            _field(trans(context, 'Sort Order'), _sortOrderCtrl, keyboardType: TextInputType.number),
            SizedBox(height: rs(context, 10)),
            Row(
              children: [
                Text(trans(context, 'Active'), style: TextStyle(
                  fontSize: rs(context, 14), fontWeight: FontWeight.w500, color: dc.textPrimary,
                )),
                SizedBox(width: rs(context, 10)),
                Switch(
                  value: _isActive,
                  activeTrackColor: dc.primaryBtn,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountriesField(StroappDialogColors dc) {
    final countries = _parseCountries(_countriesCtrl.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(trans(context, 'Countries'), style: TextStyle(
              fontSize: rs(context, 11), color: dc.textSecondary, fontWeight: FontWeight.w500,
            )),
            if (countries.isNotEmpty) ...[
              SizedBox(width: rs(context, 6)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 6), vertical: rs(context, 2)),
                decoration: BoxDecoration(
                  color: dc.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(rs(context, 8)),
                ),
                child: Text('${countries.length}', style: TextStyle(
                  fontSize: rs(context, 9), color: dc.accent, fontWeight: FontWeight.w600,
                )),
              ),
            ],
          ],
        ),
        SizedBox(height: rs(context, 6)),
        if (countries.isNotEmpty) ...[
          Wrap(
            spacing: rs(context, 6),
            runSpacing: rs(context, 6),
            children: [
              ...countries.map((c) => GestureDetector(
                onTap: () {
                  final remaining = countries.where((x) => x != c).join(', ');
                  _countriesCtrl.text = remaining;
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 4)),
                  decoration: BoxDecoration(
                    color: dc.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(rs(context, 14)),
                    border: Border.all(color: dc.accent.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_countryFlag(c), style: TextStyle(fontSize: rs(context, 10))),
                      SizedBox(width: rs(context, 4)),
                      Text(c, style: TextStyle(
                        fontSize: rs(context, 10), color: dc.accent, fontWeight: FontWeight.w500,
                      )),
                      SizedBox(width: rs(context, 4)),
                      Icon(Icons.close, size: rs(context, 10), color: dc.accent.withValues(alpha: 0.6)),
                    ],
                  ),
                ),
              )),
              GestureDetector(
                onTap: () => _showAddCountryDialog(dc),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 4)),
                  decoration: BoxDecoration(
                    color: dc.primaryBtn.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(rs(context, 14)),
                    border: Border.all(color: dc.primaryBtn.withValues(alpha: 0.3), width: 0.5, style: BorderStyle.solid),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: rs(context, 10), color: dc.primaryBtn),
                      SizedBox(width: rs(context, 4)),
                      Text(trans(context, 'Add'), style: TextStyle(
                        fontSize: rs(context, 10), color: dc.primaryBtn, fontWeight: FontWeight.w500,
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: rs(context, 6)),
        ],
        _field(null, _countriesCtrl, hint: 'all', maxLines: 2),
      ],
    );
  }

  Future<void> _showAddCountryDialog(StroappDialogColors dc) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(trans(context, 'Add Country')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: trans(context, 'Country name'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(trans(context, 'Cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(trans(context, 'Add')),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final current = _parseCountries(_countriesCtrl.text);
      if (!current.map((e) => e.toLowerCase()).contains(result.toLowerCase())) {
        current.add(result);
      }
      _countriesCtrl.text = current.join(', ');
      setState(() {});
    }
  }

  Widget _buildPricingCard(StroappDialogColors dc) {
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
              Text(trans(context, 'Pricing'), style: TextStyle(
                fontSize: rs(context, 15), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
            ],
          ),
          SizedBox(height: rs(context, 14)),
          Row(
            children: [
              Expanded(child: _field(trans(context, 'Price USD'), _priceUsdCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), required: true)),
              SizedBox(width: rs(context, 10)),
              Expanded(child: _field('${trans(context, 'Price')} $_officialCurrency', _priceIqdCtrl, keyboardType: TextInputType.number, required: true)),
            ],
          ),
          SizedBox(height: rs(context, 10)),
          _field('${trans(context, 'Markup')} (%)', _markupCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        ],
      ),
    );
  }

  Widget _buildProviderBundleCard(StroappDialogColors dc) {
    final detail = _providerDetail;
    final plan = widget.plan;
    final dataMb = (detail?['dataAmount'] is int) ? detail!['dataAmount'] as int : plan.dataAmountMb;
    final dur = (detail?['duration'] is int) ? detail!['duration'] as int : plan.durationDays;
    final price = (detail?['price'] is num) ? detail!['price'] as num : plan.priceUsd;
    final dataStr = dataMb >= 1024 ? '${(dataMb / 1024).toStringAsFixed(1)} GB' : '${dataMb} MB';
    final countryNames = _extractProviderCountries(detail);
    final countryStr = countryNames.isNotEmpty ? countryNames.join(', ') : 'Global';
    final flag = countryNames.isNotEmpty && countryNames[0].length >= 2
        ? countryNames[0].substring(0, 2).toUpperCase() : '';
    final unlimited = detail?['unlimited'] == true || dataMb <= 0;
    final speedList = _safeList(detail?['speed']);
    final roaming = _safeList(detail?['roamingEnabled']);
    final autoRenew = detail?['autorenew'] == true;
    final billingType = detail?['billingType']?.toString() ?? 'N/A';
    final profileName = detail?['profileName']?.toString() ?? 'N/A';
    final autoStart = detail?['autostart'] == true;
    final durUnit = detail?['durationUnit']?.toString() ?? 'day';
    final groups = _safeList(detail?['groups']);
    final desc = detail?['description']?.toString() ?? '';

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
              _svgIcon('assets/icons/details.svg', rs(context, 18), dc.accent),
              SizedBox(width: rs(context, 8)),
              Text(trans(context, 'Provider Bundle Info'), style: TextStyle(
                fontSize: rs(context, 15), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
            ],
          ),
          SizedBox(height: rs(context, 12)),

          if (_providerLoading)
            const CustomLoader()
          else ...[
            // Header with flag and name
            Row(children: [
              Container(
                width: rs(context, 44), height: rs(context, 44),
                decoration: BoxDecoration(
                  color: dc.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                ),
                child: Center(child: Text(flag.isNotEmpty ? flag : '\u{1F310}', style: TextStyle(fontSize: rs(context, 22)))),
              ),
              SizedBox(width: rs(context, 12)),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.providerBundleId, style: TextStyle(
                    fontSize: rs(context, 13), fontWeight: FontWeight.w600, color: dc.textPrimary,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: rs(context, 3)),
                  Text(countryStr, style: TextStyle(fontSize: rs(context, 11), color: dc.textSecondary)),
                ],
              )),
            ]),
            if (groups.isNotEmpty) ...[
              SizedBox(height: rs(context, 8)),
              Text(groups.join(' • '), style: TextStyle(fontSize: rs(context, 11), color: dc.accent, fontWeight: FontWeight.w600)),
            ],

            // Stats
            SizedBox(height: rs(context, 12)),
            Row(children: [
              _statBox(dc, 'Data', unlimited ? 'Unlimited' : dataStr, dc.accent),
              SizedBox(width: rs(context, 8)),
              _statBox(dc, 'Duration', durUnit == 'day' ? '${dur} days' : '${dur} $durUnit', dc.accent),
              SizedBox(width: rs(context, 8)),
              _statBox(dc, 'Price', _getOfficialPrice(price.toDouble()), const Color(0xFF4CAF50)),
            ]),

            // Speed, Roaming, Auto
            SizedBox(height: rs(context, 10)),
            Row(children: [
              _infoChip(dc, 'Speed', speedList.isNotEmpty ? speedList.join(', ') : 'Standard'),
              SizedBox(width: rs(context, 6)),
              _infoChip(dc, 'Roaming', roaming.isNotEmpty ? 'Yes (${roaming.length} countries)' : 'N/A'),
              SizedBox(width: rs(context, 6)),
              _infoChip(dc, 'Auto', autoRenew ? 'Renew' : 'One-time'),
            ]),
            SizedBox(height: rs(context, 6)),
            Row(children: [
              _infoChip(dc, 'Type', billingType),
              SizedBox(width: rs(context, 6)),
              _infoChip(dc, 'Profile', profileName),
              SizedBox(width: rs(context, 6)),
              _infoChip(dc, 'Start', autoStart ? 'Auto' : 'Manual'),
            ]),

            // Allowances
            ..._buildAllowances(detail, dc),

            // Networks per country
            ..._buildNetworks(detail, dc),

            // Description
            if (desc.isNotEmpty) ...[
              SizedBox(height: rs(context, 12)),
              Text(desc, style: TextStyle(fontSize: rs(context, 11), color: dc.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ],
        ],
      ),
    );
  }

  List<String> _extractProviderCountries(Map<String, dynamic>? detail) {
    if (detail == null) return [];
    final raw = _safeList(detail['countries']);
    final names = <String>[];
    for (final c in raw) {
      if (c is! Map) continue;
      // Detail endpoint: {"country": {"name": "X"}, "networks": [...]}
      final country = c['country'];
      if (country is Map) {
        final name = country['name']?.toString();
        if (name != null && name.isNotEmpty) names.add(name);
      }
      // List endpoint: {"name": "X", ...}
      else {
        final name = c['name']?.toString();
        if (name != null && name.isNotEmpty) names.add(name);
      }
    }
    return names;
  }

  List _safeList(dynamic v) {
    if (v is List) return v;
    return [];
  }

  Widget _statBox(StroappDialogColors dc, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rs(context, 10), horizontal: rs(context, 6)),
        decoration: BoxDecoration(
          color: dc.iconBox.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(rs(context, 10)),
        ),
        child: Column(children: [
          Text(label, style: TextStyle(fontSize: rs(context, 9), color: dc.textSecondary)),
          SizedBox(height: rs(context, 4)),
          Text(value, style: TextStyle(fontSize: rs(context, 11), fontWeight: FontWeight.w700, color: dc.textPrimary),
            textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _infoChip(StroappDialogColors dc, String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rs(context, 6), horizontal: rs(context, 6)),
        decoration: BoxDecoration(
          color: dc.iconBox.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(rs(context, 8)),
        ),
        child: Column(children: [
          Text(label, style: TextStyle(fontSize: rs(context, 8), color: dc.textSecondary)),
          SizedBox(height: rs(context, 1)),
          Text(value, style: TextStyle(fontSize: rs(context, 9), fontWeight: FontWeight.w600, color: dc.textPrimary),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  List<Widget> _buildAllowances(Map<String, dynamic>? detail, StroappDialogColors dc) {
    final allowances = _safeList(detail?['allowances']);
    if (allowances.isEmpty) return [];
    return [
      SizedBox(height: rs(context, 12)),
      Text('Allowances', style: TextStyle(fontSize: rs(context, 12), fontWeight: FontWeight.w600, color: dc.textPrimary)),
      SizedBox(height: rs(context, 6)),
      Wrap(
        spacing: rs(context, 6),
        runSpacing: rs(context, 6),
        children: allowances.whereType<Map>().map((a) {
          final type = a['type']?.toString() ?? '';
          final amt = a['amount'];
          final unit = a['unit']?.toString() ?? '';
          final isUnlimited = a['unlimited'] == true;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 5)),
            decoration: BoxDecoration(
              color: dc.iconBox.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(rs(context, 8)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('$type: ${isUnlimited ? "\u{221E}" : "$amt $unit"}', style: TextStyle(fontSize: rs(context, 10), color: dc.textPrimary)),
            ]),
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _buildNetworks(Map<String, dynamic>? detail, StroappDialogColors dc) {
    final countriesData = _safeList(detail?['countries']);
    if (countriesData.isEmpty) return [];
    final hasNetworks = countriesData.any((c) {
      if (c is! Map) return false;
      return (c['networks'] as List?)?.isNotEmpty == true;
    });
    if (!hasNetworks) return [];
    return [
      SizedBox(height: rs(context, 12)),
      Text(trans(context, 'Networks'), style: TextStyle(fontSize: rs(context, 12), fontWeight: FontWeight.w600, color: dc.textPrimary)),
      SizedBox(height: rs(context, 6)),
      ...countriesData.whereType<Map<String, dynamic>>().map((c) {
        final country = c['country'] is Map ? c['country'] as Map : null;
        final networks = c['networks'] as List? ?? [];
        final name = country?['name']?.toString() ?? '';
        if (networks.isEmpty) return const SizedBox();
        return Padding(
          padding: EdgeInsets.only(bottom: rs(context, 4)),
          child: Row(children: [
            Text(_countryFlag(name), style: TextStyle(fontSize: rs(context, 10))),
            SizedBox(width: rs(context, 4)),
            Text(name.isNotEmpty ? name : '', style: TextStyle(fontSize: rs(context, 10), color: dc.textPrimary, fontWeight: FontWeight.w500)),
            SizedBox(width: rs(context, 6)),
            Expanded(child: Text(
              networks.join(', '),
              style: TextStyle(fontSize: rs(context, 9), color: dc.textSecondary),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            )),
          ]),
        );
      }),
    ];
  }

  Widget _buildExchangeRatesCard(StroappDialogColors dc) {
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
            ],
          ),
          SizedBox(height: rs(context, 14)),
          if (_ratesLoading)
            const CustomLoader()
          else if (_rates.isEmpty)
            Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: rs(context, 16)),
              child: Text(trans(context, 'No exchange rates'), style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 13))),
            ))
          else
            ..._rates.map((r) {
              final rate = r as Map<String, dynamic>;
              final base = rate['base_currency'] ?? rate['base'] ?? 'USD';
              final target = rate['target_currency'] ?? rate['target'] ?? 'IQD';
              final val = rate['rate']?.toString() ?? '0';
              return Container(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 8)),
                margin: EdgeInsets.only(bottom: rs(context, 6)),
                decoration: BoxDecoration(
                  color: dc.iconBox.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(rs(context, 10)),
                  border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
                ),
                child: Row(
                  children: [
                    _svgIcon('assets/icons/moneys_icon_242132.svg', rs(context, 14), dc.accent),
                    SizedBox(width: rs(context, 8)),
                    Text('$base → $target', style: TextStyle(fontSize: rs(context, 12), fontWeight: FontWeight.w600, color: dc.textPrimary)),
                    const Spacer(),
                    Text(val, style: TextStyle(fontSize: rs(context, 13), fontWeight: FontWeight.w700, color: dc.primaryBtn)),
                  ],
                ),
              );
            }),
          SizedBox(height: rs(context, 8)),
          Container(
            padding: EdgeInsets.all(rs(context, 10)),
            decoration: BoxDecoration(
              color: dc.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(rs(context, 10)),
            ),
            child: Row(
              children: [
                _svgIcon('assets/icons/info_square_icon_184028.svg', rs(context, 14), dc.accent),
                SizedBox(width: rs(context, 8)),
                Expanded(child: Text(
                  'Plan pricing uses these rates for conversion. Add new rates in the Pricing section.',
                  style: TextStyle(fontSize: rs(context, 10), color: dc.accent),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(StroappDialogColors dc) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: dc.primaryBtn,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
            ),
            child: _saving
              ? SizedBox(width: rs(context, 20), height: rs(context, 20),
                  child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(trans(context, 'Save Changes'), style: TextStyle(fontSize: rs(context, 14), fontWeight: FontWeight.w600)),
          ),
        ),
        SizedBox(width: rs(context, 10)),
        SizedBox(
          width: rs(context, 52),
          height: rs(context, 52),
          child: ElevatedButton(
            onPressed: _deleting ? null : _confirmDelete,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              foregroundColor: Colors.red,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
            ),
            child: _deleting
              ? SizedBox(width: rs(context, 20), height: rs(context, 20),
                  child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
              : _svgIcon('assets/icons/trash_icon_241955.svg', rs(context, 20), Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _field(String? label, TextEditingController ctrl, {bool required = false, TextInputType? keyboardType, int maxLines = 1, String? hint}) {
    final dc = context.dialogColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text('$label${required ? ' *' : ''}', style: TextStyle(
            fontSize: rs(context, 11), color: dc.textSecondary, fontWeight: FontWeight.w500,
          )),
          SizedBox(height: rs(context, 4)),
        ],
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: rs(context, 13), color: dc.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: dc.iconBox.withValues(alpha: 0.3),
            contentPadding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 10)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 8)),
              borderSide: BorderSide(color: dc.borderColor.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 8)),
              borderSide: BorderSide(color: dc.borderColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 8)),
              borderSide: BorderSide(color: dc.accent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 8)),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? trans(context, 'Required') : null : null,
        ),
      ],
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
