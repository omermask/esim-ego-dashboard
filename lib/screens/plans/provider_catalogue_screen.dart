import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/plans_provider.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/custom_loader.dart';

class ProviderCatalogueScreen extends StatefulWidget {
  final bool embedded;
  final VoidCallback? onBack;

  const ProviderCatalogueScreen({super.key, this.embedded = false, this.onBack});

  @override
  State<ProviderCatalogueScreen> createState() => _ProviderCatalogueScreenState();
}

class _ProviderCatalogueScreenState extends State<ProviderCatalogueScreen> {
  String _search = '';
  String? _region;
  String? _country;
  int? _minDays;
  int? _maxDays;
  int? _minDataMb;
  int? _maxDataMb;
  double? _minPrice;
  double? _maxPrice;
  String? _network;
  bool _networksLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<PlansProvider>();
      if (p.catalogue.isEmpty) p.loadCatalogue();
      p.loadNetworks();
    });
  }

  Future<void> _refresh() => context.read<PlansProvider>().loadCatalogue();

  Set<String> get _allRegions {
    final all = <String>{};
    for (final b in context.read<PlansProvider>().catalogue) {
      all.addAll(b.regions);
    }
    return all;
  }

  Set<String> get _allCountries {
    final all = <String>{};
    for (final b in context.read<PlansProvider>().catalogue) {
      all.addAll(b.countries);
    }
    return all;
  }

  Set<String> get _countriesForRegion {
    if (_region == null) return _allCountries;
    final result = <String>{};
    for (final b in context.read<PlansProvider>().catalogue) {
      if (b.regions.contains(_region)) {
        result.addAll(b.countries);
      }
    }
    return result;
  }

  List<CatalogueBundle> get _filtered {
    final all = context.read<PlansProvider>().catalogue;
    return all.where((b) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!b.name.toLowerCase().contains(q) &&
            !b.countries.any((c) => c.toLowerCase().contains(q))) {
          return false;
        }
      }
      if (_region != null && !b.regions.any((r) => r == _region)) return false;
      if (_country != null && !b.countries.any((c) => c.toLowerCase() == _country!.toLowerCase())) return false;
      if (_minDays != null && b.duration > 0 && b.duration < _minDays!) return false;
      if (_maxDays != null && b.duration > 0 && b.duration > _maxDays!) return false;
      if (_minDataMb != null && b.dataAmount > 0 && b.dataAmount < _minDataMb!) return false;
      if (_maxDataMb != null && b.dataAmount > 0 && b.dataAmount > _maxDataMb!) return false;
      if (_minPrice != null && b.price > 0 && b.price < _minPrice!) return false;
      if (_maxPrice != null && b.price > 0 && b.price > _maxPrice!) return false;
      return true;
    }).toList();
  }

  bool get _hasFilters => _region != null || _country != null || _minDays != null || _maxDays != null
      || _minDataMb != null || _maxDataMb != null || _minPrice != null || _maxPrice != null || _network != null;

  void _clearFilters() {
    setState(() {
      _search = '';
      _region = null;
      _country = null;
      _minDays = null;
      _maxDays = null;
      _minDataMb = null;
      _maxDataMb = null;
      _minPrice = null;
      _maxPrice = null;
      _network = null;
    });
    context.read<PlansProvider>().loadCatalogue();
  }

  Future<void> _importAndGo(CatalogueBundle bundle) async {
    final p = context.read<PlansProvider>();
    final result = await p.importFromCatalogue([bundle.name]);
    if (!mounted) return;
    if (result['error'] != null) {
      CustomToaster.showError(context, title: trans(context, 'Import Failed'), message: '${result['error']}');
      return;
    }
    if (!mounted) return;
    final existed = result['already_existed'] == 1;
    if (existed) {
      CustomToaster.showInfo(context, title: trans(context, 'Already Exists'), message: bundle.name);
    } else {
      CustomToaster.showSuccess(context, title: trans(context, 'Imported'), message: bundle.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final p = context.watch<PlansProvider>();

    final body = _buildBody(p, dc);

    return Scaffold(
      backgroundColor: dc.bg,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: dc.bg,
              elevation: 0,
              leading: IconButton(
                icon: AppIcons.svg(AppIcons.rightArrow, size: rs(context, 18), color: dc.textPrimary, flipX: true),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text('Provider Catalogue', style: TextStyle(
                fontSize: rs(context, 18), fontWeight: FontWeight.w700, color: dc.textPrimary,
              )),
            ),
      body: body,
    );
  }

  Widget _buildBody(PlansProvider p, StroappDialogColors dc) {
    if (p.catalogueLoading && p.catalogue.isEmpty) return const CustomLoader();
    if (p.catalogueError != null || p.catalogue.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcons.svg(AppIcons.cloudOff, size: rs(context, 48), color: dc.textSecondary),
            SizedBox(height: rs(context, 12)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 32)),
              child: Text(p.catalogueError ?? 'No bundles available',
                style: TextStyle(color: dc.textSecondary, fontSize: rs(context, 14)), textAlign: TextAlign.center),
            ),
            SizedBox(height: rs(context, 16)),
            GestureDetector(
              onTap: _refresh,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 24), vertical: rs(context, 12)),
                decoration: BoxDecoration(color: dc.accent, borderRadius: BorderRadius.circular(rs(context, 12))),
                child: Text(trans(context, 'Retry'),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    }

    final filtered = _filtered;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        slivers: [
          if (widget.embedded)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
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
                    Text('Provider Catalogue', style: TextStyle(
                      fontSize: rs(context, 22), fontWeight: FontWeight.w700, color: dc.textPrimary,
                    )),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(child: _buildFilters(dc, p, filtered.length)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(rs(context, 16), 0, rs(context, 16), rs(context, 100)),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildBundleTile(filtered[i], dc),
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(StroappDialogColors dc, PlansProvider p, int filteredCount) {
    final hasNetworks = p.networkList.isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(rs(context, 16), rs(context, 8), rs(context, 16), rs(context, 4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search bundles...',
              prefixIcon: AppIcons.svg(AppIcons.search, size: rs(context, 18)),
              filled: true,
              fillColor: dc.iconBox.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(rs(context, 10)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: rs(context, 10)),
            ),
            style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 13)),
          ),
          SizedBox(height: rs(context, 10)),
          SizedBox(
            height: rs(context, 34),
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _chip('Region', _region != null, _region ?? '', () => _pickRegion(dc), AppIcons.svg(AppIcons.map, size: rs(context, 13), color: dc.textSecondary)),
              SizedBox(width: rs(context, 6)),
              _chip('Country', _country != null, _country ?? '', () => _pickCountry(dc), AppIcons.svg(AppIcons.flag, size: rs(context, 13), color: dc.textSecondary)),
              SizedBox(width: rs(context, 6)),
              _chip('Duration', _minDays != null || _maxDays != null, _durationLabel, () => _pickDuration(dc), AppIcons.svg(AppIcons.hourglass, size: rs(context, 13), color: dc.textSecondary)),
              SizedBox(width: rs(context, 6)),
              _chip('Data', _minDataMb != null || _maxDataMb != null, _dataLabel, () => _pickData(dc), AppIcons.svg(AppIcons.wifi, size: rs(context, 13), color: dc.textSecondary)),
              SizedBox(width: rs(context, 6)),
              _chip('Price', _minPrice != null || _maxPrice != null, _priceLabel, () => _pickPrice(dc), AppIcons.svg(AppIcons.coin, size: rs(context, 13), color: dc.textSecondary)),
              SizedBox(width: rs(context, 6)),
              _chip('Network', _network != null, _network ?? '', () => _pickNetwork(dc), AppIcons.svg(AppIcons.cellular, size: rs(context, 13), color: dc.textSecondary)),
              if (_networksLoading) ...[
                SizedBox(width: rs(context, 6)),
                SizedBox(
                  width: rs(context, 24), height: rs(context, 24),
                  child: CircularProgressIndicator(strokeWidth: 2, color: dc.accent),
                ),
              ],
              if (!hasNetworks && !_networksLoading) ...[
                SizedBox(width: rs(context, 6)),
                _chip('Build Index', true, '', () {
                  _networksLoading = true; setState(() {});
                  p.buildNetworkIndex().then((_) {
                    _networksLoading = false; if (mounted) setState(() {});
                  });
                }, AppIcons.svg(AppIcons.settings, size: rs(context, 13), color: dc.textSecondary), isAction: true),
              ],
              if (_hasFilters) ...[
                SizedBox(width: rs(context, 6)),
                _chip('Clear', true, '', _clearFilters, AppIcons.svg(AppIcons.cross, size: rs(context, 13), color: dc.textSecondary), isAction: true),
              ],
            ]),
          ),
          SizedBox(height: rs(context, 6)),
          Row(children: [
            Text('$filteredCount of ${p.catalogue.length} bundles',
              style: TextStyle(fontSize: rs(context, 11), color: dc.textSecondary)),
          ]),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, String subtitle, VoidCallback onTap, Widget icon, {bool isAction = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 10)),
        decoration: BoxDecoration(
          color: active ? context.dialogColors.accent.withValues(alpha: 0.15) : context.dialogColors.iconBox.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(rs(context, 20)),
          border: Border.all(
            color: active
              ? context.dialogColors.accent.withValues(alpha: 0.4)
              : context.dialogColors.borderColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          icon,
          SizedBox(width: rs(context, 4)),
          Text(subtitle.isNotEmpty ? subtitle : label, style: TextStyle(
            fontSize: rs(context, 11),
            color: active ? context.dialogColors.accent : context.dialogColors.textSecondary,
          )),
          if (!isAction) AppIcons.svg(AppIcons.dropDown, size: rs(context, 16),
            color: active ? context.dialogColors.accent : context.dialogColors.textSecondary, rotate: math.pi / 2),
        ]),
      ),
    );
  }

  String get _durationLabel {
    if (_minDays != null && _maxDays != null) return '${_minDays!}-${_maxDays!}d';
    if (_minDays != null) return '≥${_minDays!}d';
    if (_maxDays != null) return '≤${_maxDays!}d';
    return '';
  }

  String get _dataLabel {
    if (_minDataMb != null && _maxDataMb != null) return '${_fmtData(_minDataMb!)}-${_fmtData(_maxDataMb!)}';
    if (_minDataMb != null) return '≥${_fmtData(_minDataMb!)}';
    if (_maxDataMb != null) return '≤${_fmtData(_maxDataMb!)}';
    return '';
  }

  String get _priceLabel {
    if (_minPrice != null && _maxPrice != null) return '\$${_minPrice!.toInt()}-\$${_maxPrice!.toInt()}';
    if (_minPrice != null) return '≥\$${_minPrice!.toInt()}';
    if (_maxPrice != null) return '≤\$${_maxPrice!.toInt()}';
    return '';
  }

  // ── Region Picker ──
  void _pickRegion(StroappDialogColors dc) {
    final regions = _allRegions.toList()..sort((a, b) {
      if (a.startsWith('Global')) return a.compareTo(b);
      if (b.startsWith('Global')) return b.compareTo(a);
      return a.compareTo(b);
    });
    showModalBottomSheet(
      context: context,
      backgroundColor: dc.bg,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(rs(context, 16)))),
      builder: (ctx) {
        String search = '';
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final filtered = search.isEmpty ? regions : regions.where((r) => r.toLowerCase().contains(search.toLowerCase())).toList();
          return DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.4,
            maxChildSize: 0.75,
            expand: false,
            builder: (ctx, scrollController) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(rs(context, 16), rs(context, 12), rs(context, 16), rs(context, 8)),
                  child: TextField(
                    onChanged: (v) => setSheetState(() => search = v),
                    decoration: InputDecoration(
                      hintText: 'Search region...',
                      prefixIcon: AppIcons.svg(AppIcons.search, size: rs(context, 18)),
                      filled: true,
                      fillColor: dc.iconBox.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(rs(context, 10)), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: rs(context, 8)),
                    ),
                    style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 13)),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length + 1,
                    itemBuilder: (ctx, i) {
                      if (i == 0) {
                        return ListTile(
                          title: Text('All Regions', style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 13))),
                          leading: AppIcons.svg(AppIcons.language, size: rs(context, 20), color: dc.accent),
                          onTap: () { Navigator.pop(ctx); setState(() => _region = null); },
                        );
                      }
                      final r = filtered[i - 1];
                      return ListTile(
                        dense: true,
                        title: Text(r, style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 13))),
                        leading: AppIcons.svg(AppIcons.map, size: rs(context, 20), color: dc.textSecondary),
                        trailing: _region == r ? AppIcons.svg(AppIcons.check, size: rs(context, 18), color: dc.accent) : null,
                        onTap: () { Navigator.pop(ctx); setState(() { _region = r; _country = null; }); },
                      );
                    },
                  ),
                ),
              ]);
            },
          );
        });
      },
    );
  }

  // ── Country Picker ──
  void _pickCountry(StroappDialogColors dc) {
    final countries = _countriesForRegion.toList()..sort();
    if (countries.isEmpty) {
      CustomToaster.showInfo(context, title: trans(context, 'No countries'), message: trans(context, 'No countries available for selected region'));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: dc.bg,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(rs(context, 16)))),
      builder: (ctx) {
        String search = '';
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final filtered = search.isEmpty ? countries : countries.where((c) => c.toLowerCase().contains(search.toLowerCase())).toList();
          return DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.4,
            maxChildSize: 0.75,
            expand: false,
            builder: (ctx, scrollController) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(rs(context, 16), rs(context, 12), rs(context, 16), rs(context, 8)),
                  child: TextField(
                    onChanged: (v) => setSheetState(() => search = v),
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      prefixIcon: AppIcons.svg(AppIcons.search, size: rs(context, 18)),
                      filled: true,
                      fillColor: dc.iconBox.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(rs(context, 10)), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: rs(context, 8)),
                    ),
                    style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 13)),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length + 1,
                    itemBuilder: (ctx, i) {
                      if (i == 0) {
                        return ListTile(
                          title: Text('All Countries', style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 13))),
                          leading: AppIcons.svg(AppIcons.language, size: rs(context, 20), color: dc.accent),
                          onTap: () { Navigator.pop(ctx); setState(() => _country = null); },
                        );
                      }
                      final c = filtered[i - 1];
                      final iso = c.length >= 2 ? c.substring(0, 2).toUpperCase() : '';
                      return ListTile(
                        dense: true,
                        title: Text(c, style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 13))),
                        leading: Text(iso, style: TextStyle(fontSize: rs(context, 18))),
                        trailing: _country == c ? AppIcons.svg(AppIcons.check, size: rs(context, 18), color: dc.accent) : null,
                        onTap: () { Navigator.pop(ctx); setState(() { _country = c; _region = null; }); },
                      );
                    },
                  ),
                ),
              ]);
            },
          );
        });
      },
    );
  }

  // ── Duration Picker ──
  void _pickDuration(StroappDialogColors dc) {
    final presets = [
      (label: 'Any', min: null, max: null),
      (label: '1-3 days', min: 1, max: 3),
      (label: '4-7 days', min: 4, max: 7),
      (label: '8-15 days', min: 8, max: 15),
      (label: '16-30 days', min: 16, max: 30),
      (label: '31-60 days', min: 31, max: 60),
      (label: '61-90 days', min: 61, max: 90),
      (label: '91-180 days', min: 91, max: 180),
    ];
    _showSimplePicker(dc, 'Duration', presets, (p) {
      _minDays = p.min;
      _maxDays = p.max;
    });
  }

  // ── Data Picker ──
  void _pickData(StroappDialogColors dc) {
    final presets = [
      (label: 'Any', min: null, max: null),
      (label: '< 100 MB', min: 0, max: 99),
      (label: '100-500 MB', min: 100, max: 500),
      (label: '500 MB - 1 GB', min: 500, max: 1024),
      (label: '1-5 GB', min: 1024, max: 5120),
      (label: '5-10 GB', min: 5120, max: 10240),
      (label: '10-50 GB', min: 10240, max: 51200),
      (label: '50+ GB', min: 51200, max: null),
    ];
    _showSimplePicker(dc, 'Data Size', presets, (p) {
      _minDataMb = p.min;
      _maxDataMb = p.max;
    });
  }

  // ── Price Picker ──
  void _pickPrice(StroappDialogColors dc) {
    final presets = [
      (label: 'Any', min: null, max: null),
      (label: '< \$5', min: null, max: 5),
      (label: '\$5-\$10', min: 5, max: 10),
      (label: '\$10-\$25', min: 10, max: 25),
      (label: '\$25-\$50', min: 25, max: 50),
      (label: '\$50-\$100', min: 50, max: 100),
      (label: '\$100+', min: 100, max: null),
    ];
    _showSimplePicker(dc, 'Price Range', presets, (p) {
      _minPrice = p.min?.toDouble();
      _maxPrice = p.max?.toDouble();
    });
  }

  void _pickNetwork(StroappDialogColors dc) {
    final p = context.read<PlansProvider>();
    final networks = p.networkList;
    if (networks.isEmpty) {
      CustomToaster.showInfo(context, title: trans(context, 'Network Index'), message: trans(context, 'Network index not built yet. Build it in the filter menu.'));
      return;
    }
    String search = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: dc.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(rs(context, 20)))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final filtered = networks.where((n) {
            if (search.isEmpty) return true;
            return (n['name'] as String? ?? '').toLowerCase().contains(search.toLowerCase());
          }).toList();
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            expand: false,
            builder: (ctx, scrollController) {
              return Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 12), rs(context, 20), rs(context, 8)),
                  child: TextField(
                    onChanged: (v) => setSheetState(() => search = v),
                    decoration: InputDecoration(
                      hintText: 'Search network...',
                      prefixIcon: AppIcons.svg(AppIcons.search, size: rs(context, 18)),
                      filled: true,
                      fillColor: dc.iconBox.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(rs(context, 10)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: rs(context, 10)),
                    ),
                    style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 13)),
                  ),
                ),
                Text('${networks.length} networks indexed', style: TextStyle(fontSize: rs(context, 11), color: dc.textSecondary)),
                SizedBox(height: rs(context, 4)),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final n = filtered[i];
                      final name = n['name'] as String? ?? '';
                      final count = n['bundle_count'] as int? ?? 0;
                      return ListTile(
                        dense: true,
                        title: Text(name, style: TextStyle(fontSize: rs(context, 13), color: dc.textPrimary)),
                        trailing: Text('$count bundles', style: TextStyle(fontSize: rs(context, 11), color: dc.textSecondary)),
                        onTap: () {
                          Navigator.pop(ctx);
                          p.loadCatalogueWithNetwork(name);
                          setState(() => _network = name);
                        },
                      );
                    },
                  ),
                ),
              ]);
            },
          );
        });
      },
    );
  }

  void _showSimplePicker(StroappDialogColors dc, String title, List<({String label, int? min, int? max})> options, void Function(({String label, int? min, int? max}) selected) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: dc.bg,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(rs(context, 16)))),
      builder: (ctx) => SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: EdgeInsets.all(rs(context, 16)),
            child: Text(title, style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 15), fontWeight: FontWeight.w600)),
          ),
          ...options.map((o) => ListTile(
            dense: true,
            title: Text(o.label, style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 13))),
            leading: AppIcons.svg(AppIcons.tickCircle, size: rs(context, 20), color: dc.textSecondary),
            onTap: () { Navigator.pop(ctx); setState(() => onSelect(o)); },
          )),
          SizedBox(height: rs(context, 16)),
        ]),
      ),
    );
  }

  // ── Bundle Tile ──
  Widget _buildBundleTile(CatalogueBundle bundle, StroappDialogColors dc) {
    final dataStr = bundle.dataAmount >= 1024
        ? '${(bundle.dataAmount / 1024).toStringAsFixed(1)} GB'
        : '${bundle.dataAmount} MB';
    final countryStr = bundle.countries.isNotEmpty
        ? bundle.countries.take(2).join(', ') + (bundle.countries.length > 2 ? ' +${bundle.countries.length - 2}' : '')
        : 'Global';
    final flag = bundle.countries.isNotEmpty && bundle.countries[0].length >= 2
        ? bundle.countries[0].substring(0, 2).toUpperCase() : '';

    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 10)),
      decoration: BoxDecoration(
        color: dc.iconBox.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(rs(context, 14)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(rs(context, 14)),
        child: InkWell(
          borderRadius: BorderRadius.circular(rs(context, 14)),
          onTap: () => _showBundleDetails(bundle, dc),
          child: Padding(
            padding: EdgeInsets.all(rs(context, 14)),
            child: Row(children: [
              // Flag circle
              Container(
                width: rs(context, 42), height: rs(context, 42),
                decoration: BoxDecoration(
                  color: dc.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                ),
                child: Center(child: Text(flag.isNotEmpty ? flag : '🌍', style: TextStyle(fontSize: rs(context, 20)))),
              ),
              SizedBox(width: rs(context, 12)),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + region badge
                  Row(children: [
                    Expanded(child: Text(bundle.name, style: TextStyle(
                      fontSize: rs(context, 12), fontWeight: FontWeight.w600, color: dc.textPrimary,
                    ), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (bundle.regions.isNotEmpty) ...[
                      SizedBox(width: rs(context, 4)),
                      _regionBadge(dc, bundle.regions.first),
                    ],
                  ]),
                  SizedBox(height: rs(context, 5)),
                  // Tags row
                  Row(children: [
                    _tag(dc, dataStr, AppIcons.svg(AppIcons.wifi, size: rs(context, 10), color: dc.textSecondary)),
                    SizedBox(width: rs(context, 5)),
                    _tag(dc, '${bundle.duration}d', AppIcons.svg(AppIcons.hourglass, size: rs(context, 10), color: dc.textSecondary)),
                    SizedBox(width: rs(context, 5)),
                    _priceTag(dc, '\$${bundle.price.toStringAsFixed(2)}'),
                  ]),
                  SizedBox(height: rs(context, 3)),
                  // Country
                  Row(children: [
                    AppIcons.svg(AppIcons.language, size: rs(context, 10), color: dc.textSecondary),
                    SizedBox(width: rs(context, 3)),
                    Flexible(child: Text(countryStr, style: TextStyle(
                      fontSize: rs(context, 9), color: dc.textSecondary,
                    ), overflow: TextOverflow.ellipsis)),
                  ]),
                ],
              )),
              AppIcons.svg(AppIcons.rightArrow, size: rs(context, 18), color: dc.textSecondary),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _regionBadge(StroappDialogColors dc, String region) {
    final colors = {
      'Europe': const Color(0xFF4CAF50),
      'North America': const Color(0xFF2196F3),
      'Africa': const Color(0xFFFF9800),
      'Asia': const Color(0xFFE91E63),
      'Middle East': const Color(0xFF9C27B0),
      'South America': const Color(0xFF00BCD4),
      'Oceania': const Color(0xFF009688),
      'Global': const Color(0xFF607D8B),
    };
    final color = colors.entries.firstWhere(
      (e) => region.startsWith(e.key), orElse: () => MapEntry('', dc.accent),
    ).value;

    final short = region.replaceAll('Global', 'GL').replaceAll('Europe', 'EU').replaceAll('America', 'AM').replaceAll('Americas', 'AM');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 5), vertical: rs(context, 1)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(rs(context, 4)),
      ),
      child: Text(short.length > 6 ? '${short.substring(0, 6)}..' : short,
        style: TextStyle(fontSize: rs(context, 8), color: color, fontWeight: FontWeight.w600)),
    );
  }

  // ── Bundle Details Bottom Sheet ──
  void _showBundleDetails(CatalogueBundle bundle, StroappDialogColors dc) {
    final dataStr = bundle.dataAmount >= 1024
        ? '${(bundle.dataAmount / 1024).toStringAsFixed(1)} GB'
        : '${bundle.dataAmount} MB';
    final countryStr = bundle.countries.isNotEmpty ? bundle.countries.join(', ') : 'Global';
    final flag = bundle.countries.isNotEmpty && bundle.countries[0].length >= 2
        ? bundle.countries[0].substring(0, 2).toUpperCase() : '';
    final unlimited = bundle.raw['unlimited'] == true || bundle.dataAmount <= 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: dc.bg,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(rs(context, 16)))),
      builder: (ctx) {
        bool importing = false;
        // Fetch full details (async, stored in provider)
        context.read<PlansProvider>().fetchBundleDetail(bundle.name);

        return StatefulBuilder(builder: (ctx, setSheetState) {
          final detail = context.watch<PlansProvider>().catalogueBundleDetail;
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            expand: false,
            builder: (ctx, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), rs(context, 32)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(children: [
                      Container(
                        width: rs(context, 52), height: rs(context, 52),
                        decoration: BoxDecoration(
                          color: dc.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(rs(context, 14)),
                        ),
                        child: Center(child: Text(flag.isNotEmpty ? flag : '🌍', style: TextStyle(fontSize: rs(context, 26)))),
                      ),
                      SizedBox(width: rs(context, 14)),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bundle.name, style: TextStyle(fontSize: rs(context, 16), fontWeight: FontWeight.w700, color: dc.textPrimary)),
                          SizedBox(height: rs(context, 4)),
                          Row(children: [
                            AppIcons.svg(AppIcons.language, size: rs(context, 13), color: dc.textSecondary),
                            SizedBox(width: rs(context, 4)),
                            Flexible(child: Text(countryStr, style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary))),
                          ]),
                          if (bundle.regions.isNotEmpty) ...[
                            SizedBox(height: rs(context, 4)),
                            Wrap(spacing: rs(context, 4), children: bundle.regions.map((r) => _regionBadge(dc, r)).toList()),
                          ],
                        ],
                      )),
                    ]),
                    SizedBox(height: rs(context, 16)),

                    // Group / Category badge
                    if (bundle.groups.isNotEmpty) ...[
                      Row(children: [
                        AppIcons.svg(AppIcons.category, size: rs(context, 14), color: dc.accent),
                        SizedBox(width: rs(context, 6)),
                        Text(bundle.groups.join(' • '), style: TextStyle(fontSize: rs(context, 12), color: dc.accent, fontWeight: FontWeight.w600)),
                      ]),
                      SizedBox(height: rs(context, 12)),
                    ],

                    // Stats grid
                    Row(children: [
                      _statBox(dc, AppIcons.svg(AppIcons.wifi, size: rs(context, 20), color: dc.accent), 'Data', unlimited ? 'Unlimited' : dataStr, dc.accent),
                      SizedBox(width: rs(context, 8)),
                      _statBox(dc, AppIcons.svg(AppIcons.hourglass, size: rs(context, 20), color: dc.accent), 'Duration', '${bundle.duration} days', dc.accent),
                      SizedBox(width: rs(context, 8)),
                      _statBox(dc, AppIcons.svg(AppIcons.coin, size: rs(context, 20), color: Colors.green), 'Price', '\$${bundle.price.toStringAsFixed(2)}', Colors.green),
                    ]),

                    // Speed & Roaming
                    SizedBox(height: rs(context, 12)),
                    Row(children: [
                      _infoChip(dc, AppIcons.svg(AppIcons.speed, size: rs(context, 16), color: dc.textSecondary), 'Speed', bundle.raw['speed'] is List
                        ? (bundle.raw['speed'] as List).join(', ')
                        : 'Standard'),
                      SizedBox(width: rs(context, 8)),
                      _infoChip(dc, AppIcons.svg(AppIcons.cellular, size: rs(context, 16), color: dc.textSecondary), 'Roaming',
                        bundle.raw['roamingEnabled'] is List && bundle.raw['roamingEnabled'].isNotEmpty
                        ? 'Yes (${bundle.raw['roamingEnabled'].length} countries)' : 'N/A'),
                      SizedBox(width: rs(context, 8)),
                      _infoChip(dc, AppIcons.svg(AppIcons.loop, size: rs(context, 16), color: dc.textSecondary), 'Auto', bundle.raw['autorenew'] == true ? 'Renew' : 'One-time'),
                    ]),
                    SizedBox(height: rs(context, 8)),
                    Row(children: [
                      _infoChip(dc, AppIcons.svg(AppIcons.receipt, size: rs(context, 16), color: dc.textSecondary), 'Type', bundle.raw['billingType']?.toString() ?? 'N/A'),
                      SizedBox(width: rs(context, 8)),
                      _infoChip(dc, AppIcons.svg(AppIcons.person, size: rs(context, 16), color: dc.textSecondary), 'Profile', bundle.raw['profileName']?.toString() ?? 'N/A'),
                      SizedBox(width: rs(context, 8)),
                      _infoChip(dc, AppIcons.svg(AppIcons.playCircle, size: rs(context, 16), color: dc.textSecondary), 'Start', bundle.raw['autostart'] == true ? 'Auto' : 'Manual'),
                    ]),
                    if (bundle.raw['durationUnit'] != null && bundle.raw['durationUnit'] != 'day')
                      SizedBox(height: rs(context, 4)),
                    if (bundle.raw['durationUnit'] != null && bundle.raw['durationUnit'] != 'day')
                      _infoChip(dc, AppIcons.svg(AppIcons.info, size: rs(context, 16), color: dc.textSecondary), 'Unit', bundle.raw['durationUnit'].toString()),

                    // Allowances from detail if available
                    ..._buildAllowances(detail, dc),

                    // Networks from detail
                    ..._buildNetworks(detail, dc),

                    if (bundle.description != null && bundle.description!.isNotEmpty) ...[
                      SizedBox(height: rs(context, 16)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(rs(context, 12)),
                        decoration: BoxDecoration(
                          color: dc.iconBox.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(rs(context, 10)),
                        ),
                        child: Text(bundle.description!, style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary)),
                      ),
                    ],

                    SizedBox(height: rs(context, 24)),
                    SizedBox(
                      width: double.infinity,
                      height: rs(context, 48),
                      child: ElevatedButton.icon(
                        onPressed: importing ? null : () async {
                          setSheetState(() => importing = true);
                          Navigator.pop(ctx);
                          await _importAndGo(bundle);
                        },
                        icon: importing
                          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : AppIcons.svg(AppIcons.download, size: rs(context, 20)),
                        label: Text(importing ? 'Importing...' : 'Import This Bundle',
                          style: TextStyle(fontSize: rs(context, 14), fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dc.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  Widget _infoChip(StroappDialogColors dc, Widget icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rs(context, 8), horizontal: rs(context, 8)),
        decoration: BoxDecoration(
          color: dc.iconBox.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(rs(context, 10)),
        ),
        child: Column(children: [
          icon,
          SizedBox(height: rs(context, 2)),
          Text(label, style: TextStyle(fontSize: rs(context, 8), color: dc.textSecondary)),
          Text(value, style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600, color: dc.textPrimary), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _statBox(StroappDialogColors dc, Widget icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rs(context, 12), horizontal: rs(context, 8)),
        decoration: BoxDecoration(
          color: dc.iconBox.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(rs(context, 12)),
        ),
        child: Column(children: [
          icon,
          SizedBox(height: rs(context, 6)),
          Text(label, style: TextStyle(fontSize: rs(context, 10), color: dc.textSecondary)),
          SizedBox(height: rs(context, 2)),
          Text(value, style: TextStyle(fontSize: rs(context, 12), fontWeight: FontWeight.w700, color: dc.textPrimary),
            textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  String _fmtData(int mb) {
    if (mb >= 1024) return '${(mb / 1024).toStringAsFixed(0)}GB';
    return '${mb}MB';
  }

  Widget _tag(StroappDialogColors dc, String label, Widget icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 6), vertical: rs(context, 2)),
      decoration: BoxDecoration(
        color: dc.borderColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(rs(context, 4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        icon,
        SizedBox(width: rs(context, 3)),
        Text(label, style: TextStyle(fontSize: rs(context, 9), color: dc.textSecondary)),
      ]),
    );
  }

  Widget _priceTag(StroappDialogColors dc, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 6), vertical: rs(context, 2)),
      decoration: BoxDecoration(
        color: dc.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rs(context, 4)),
      ),
      child: Text(label, style: TextStyle(fontSize: rs(context, 9), color: dc.accent, fontWeight: FontWeight.w600)),
    );
  }

  List<Widget> _buildAllowances(Map<String, dynamic>? detail, StroappDialogColors dc) {
    if (detail?['allowances'] is! List) return [];
    final allowances = detail!['allowances'] as List;
    return [
      SizedBox(height: rs(context, 16)),
      Text('Allowances', style: TextStyle(fontSize: rs(context, 13), fontWeight: FontWeight.w600, color: dc.textPrimary)),
      SizedBox(height: rs(context, 8)),
      Wrap(
        spacing: rs(context, 6),
        runSpacing: rs(context, 6),
        children: allowances.map((a) {
          if (a is! Map) return const SizedBox();
          final type = a['type']?.toString() ?? '';
          final amt = a['amount'];
          final unit = a['unit']?.toString() ?? '';
          final service = a['service']?.toString() ?? '';
          final isUnlimited = a['unlimited'] == true;
          final desc = a['description']?.toString() ?? '';
          Widget icon;
          if (type == 'DATA') { icon = AppIcons.svg(AppIcons.wifi, size: rs(context, 14), color: dc.accent); }
          else if (type == 'SMS') { icon = AppIcons.svg(AppIcons.messages, size: rs(context, 14), color: dc.accent); }
          else if (type == 'VOICE') { icon = AppIcons.svg(AppIcons.voice, size: rs(context, 14), color: dc.accent); }
          else { icon = AppIcons.svg(AppIcons.moreCircle, size: rs(context, 14), color: dc.accent); }
          return Tooltip(
            message: [
              if (service.isNotEmpty) 'Service: $service',
              if (desc.isNotEmpty) desc,
            ].join('\n'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 6)),
              decoration: BoxDecoration(
                color: dc.iconBox.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(rs(context, 8)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: rs(context, 14), height: rs(context, 14), child: icon),
                SizedBox(width: rs(context, 4)),
                Text('$type: ${isUnlimited ? "∞" : "$amt $unit"}', style: TextStyle(fontSize: rs(context, 11), color: dc.textPrimary)),
              ]),
            ),
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _buildNetworks(Map<String, dynamic>? detail, StroappDialogColors dc) {
    if (detail?['countries'] is! List) return [];
    final countriesData = detail!['countries'] as List;
    return [
      SizedBox(height: rs(context, 16)),
      Text('Supported Networks', style: TextStyle(fontSize: rs(context, 13), fontWeight: FontWeight.w600, color: dc.textPrimary)),
      SizedBox(height: rs(context, 8)),
      ...countriesData.whereType<Map<String, dynamic>>().map((c) {
        final country = c['country'] is Map ? c['country'] as Map : null;
        final networks = c['networks'] as List? ?? [];
        final name = country?['name']?.toString() ?? '';
        return Padding(
          padding: EdgeInsets.only(bottom: rs(context, 6)),
          child: Row(children: [
            Text(name.isNotEmpty ? name : 'Unknown', style: TextStyle(fontSize: rs(context, 11), color: dc.textPrimary, fontWeight: FontWeight.w500)),
            SizedBox(width: rs(context, 8)),
            Expanded(child: Text(
              networks.isNotEmpty ? networks.join(', ') : 'All networks',
              style: TextStyle(fontSize: rs(context, 10), color: dc.textSecondary),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            )),
          ]),
        );
      }),
    ];
  }
}
