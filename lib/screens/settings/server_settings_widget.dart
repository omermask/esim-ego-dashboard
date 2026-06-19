import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/exchange_rate_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';

const _currencies = ['IQD', 'USD', 'EUR', 'TRY', 'GBP', 'AED', 'SAR', 'EGP'];
const _intervals = [
  'manual',
  'hourly',
  'every_6_hours',
  'daily',
];
const _timezones = [
  'Asia/Baghdad',
  'Asia/Riyadh',
  'Asia/Dubai',
  'Asia/Kuwait',
  'Asia/Qatar',
  'Asia/Tehran',
  'Europe/Istanbul',
  'Europe/London',
  'Europe/Berlin',
  'America/New_York',
];

class ServerSettingsWidget extends StatefulWidget {
  final VoidCallback onBack;
  const ServerSettingsWidget({super.key, required this.onBack});

  @override
  State<ServerSettingsWidget> createState() => _ServerSettingsWidgetState();
}

class _ServerSettingsWidgetState extends State<ServerSettingsWidget> {
  String _currency = 'IQD';
  String _timezone = 'Asia/Baghdad';
  String _interval = 'manual';
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _init = true;
      Future.microtask(() {
        if (!mounted) return;
        final sp = context.read<SettingsProvider>();
        sp.loadServerConfig().then((_) {
          if (mounted) {
            setState(() {
              _currency = sp.officialCurrency;
              _timezone = sp.timezone;
              _interval = sp.autoFetchInterval;
            });
          }
        });
      });
    }
  }

  Future<void> _save() async {
    final sp = context.read<SettingsProvider>();
    final err = await sp.updateServerConfig({
      'official_currency': _currency,
      'timezone': _timezone,
      'auto_fetch_interval': _interval,
    });
    if (mounted) {
      if (err == null) {
        context.showSuccess(trans(context, 'Settings saved'));
      } else {
        context.showError(err);
      }
    }
  }

  Future<void> _fetchRates() async {
    final ep = context.read<ExchangeRateProvider>();
    final d = await ep.fetchNow();
    if (mounted) {
      if (d['success'] == true) {
        context.showSuccess(trans(context, 'Rates fetched'));
      } else {
        context.showError(d['error']?.toString() ?? 'Failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final sp = context.watch<SettingsProvider>();

    if (sp.serverConfigLoading) {
      return Center(
        child: CircularProgressIndicator(color: dc.primaryBtn),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), rs(context, 100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: widget.onBack,
                child: SvgPicture.asset('assets/icons/rightArrow.svg', width: 24, height: 24,
                  colorFilter: ColorFilter.mode(dc.textPrimary, BlendMode.srcIn),
                ),
              ),
              SizedBox(width: rs(context, 12)),
              Text(
                trans(context, 'Settings'),
                style: TextStyle(
                  fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: rs(context, 24)),

          _buildSectionHeader(context, 'Official Currency'),
          _buildDropdown(context, _currency, _currencies, (v) {
            setState(() => _currency = v!);
          }),
          SizedBox(height: rs(context, 16)),

          _buildSectionHeader(context, 'Auto-Fetch Interval'),
          _buildDropdown(context, _interval, _intervals, (v) {
            setState(() => _interval = v!);
          }),
          SizedBox(height: rs(context, 8)),
          _buildActionButton(context, 'Fetch Exchange Rates Now', _fetchRates),
          SizedBox(height: rs(context, 24)),

          _buildSectionHeader(context, 'Timezone'),
          _buildDropdown(context, _timezone, _timezones, (v) {
            setState(() => _timezone = v!);
          }),
          SizedBox(height: rs(context, 24)),

          _buildActionButton(context, 'Save All Settings', _save),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final dc = context.dialogColors;
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 8)),
      child: Text(
        trans(context, title),
        style: TextStyle(fontSize: rs(context, 16), fontWeight: FontWeight.w600, color: dc.textPrimary),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String value, List<String> items, ValueChanged<String?> onChanged) {
    final dc = context.dialogColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
      decoration: BoxDecoration(
        color: dc.inputField,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: dc.bg,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: dc.textPrimary)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, VoidCallback onTap) {
    final dc = context.dialogColors;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: dc.primaryBtn,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(trans(context, label), style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
