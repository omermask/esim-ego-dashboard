import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/backup_provider.dart';
import '../../data/models/backup_data.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/custom_loader.dart';

class BackupsWidget extends StatefulWidget {
  final VoidCallback onBack;
  const BackupsWidget({super.key, required this.onBack});

  @override
  State<BackupsWidget> createState() => _BackupsWidgetState();
}

class _BackupsWidgetState extends State<BackupsWidget> {
  bool _initialLoaded = false;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bp = context.read<BackupProvider>();
      Future.wait([bp.load(refresh: true), bp.loadSettings()]).then((_) {
        if (mounted) setState(() => _initialLoaded = true);
      });
    });
  }

  Future<void> _refresh() async {
    await context.read<BackupProvider>().load(refresh: true);
  }

  Future<void> _create() async {
    setState(() => _creating = true);
    final result = await context.read<BackupProvider>().create();
    if (mounted) {
      setState(() => _creating = false);
      if (result != null && result['success'] == true) {
        context.showSuccess(trans(context, 'Backup created'));
      } else {
        context.showError(trans(context, 'Failed to create backup'));
      }
    }
  }

  Future<void> _cleanup() async {
    final deleted = await context.read<BackupProvider>().runCleanup();
    if (mounted) {
      context.showSuccess('Cleanup done: ${deleted ?? 0} deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<BackupProvider>();
    final backups = provider.backups;
    final loading = provider.loading;
    final hasMore = provider.hasMore;
    final settings = provider.settings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(
              child: _buildContent(dc, backups, loading, hasMore, provider, settings),
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
            child: Text(trans(context, 'Backups'),
              style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
            ),
          ),
          InkWell(
            onTap: _creating ? null : _create,
            borderRadius: BorderRadius.circular(rs(context, 10)),
            child: Container(
              padding: EdgeInsets.all(rs(context, 10)),
              decoration: BoxDecoration(color: dc.accent, borderRadius: BorderRadius.circular(rs(context, 10))),
              child: _creating
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : SvgPicture.asset('assets/icons/save_add_icon_241850.svg',
                      width: rs(context, 20), colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
            ),
          ),
          SizedBox(width: rs(context, 8)),
          InkWell(
            onTap: _cleanup,
            borderRadius: BorderRadius.circular(rs(context, 10)),
            child: Container(
              padding: EdgeInsets.all(rs(context, 10)),
              decoration: BoxDecoration(color: const Color(0xFFFFA000), borderRadius: BorderRadius.circular(rs(context, 10))),
              child: SvgPicture.asset('assets/icons/refresh_square_icon_242173.svg',
                width: rs(context, 20), colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(StroappDialogColors dc, List<BackupRecord> backups, bool loading, bool hasMore, BackupProvider provider, BackupSettings settings) {
    if (!_initialLoaded && loading) return const Center(child: CustomLoader());

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 100)),
        itemCount: backups.length + (hasMore ? 1 : 0) + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) return _buildSettingsCard(dc, settings);
          final idx = i - 1;
          if (idx >= backups.length) {
            return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          }
          return _buildBackupItem(dc, backups[idx]);
        },
      ),
    );
  }

  Widget _buildSettingsCard(StroappDialogColors dc, BackupSettings s) {
    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 12)),
      padding: EdgeInsets.all(rs(context, 14)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(dc, s.enabled ? 'Enabled' : 'Disabled', 'Status'),
          _statItem(dc, '${s.intervalHours}h', 'Interval'),
          _statItem(dc, '${s.retentionDays}d', 'Retention'),
        ],
      ),
    );
  }

  Widget _statItem(StroappDialogColors dc, String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: rs(context, 14), fontWeight: FontWeight.w700, color: dc.textPrimary)),
        Text(label, style: TextStyle(fontSize: rs(context, 11), color: dc.textSecondary)),
      ],
    );
  }

  Widget _buildBackupItem(StroappDialogColors dc, BackupRecord b) {
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
                  child: Text(b.filename, style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
                  decoration: BoxDecoration(
                    color: b.status == 'completed' ? const Color(0xFF4CAF50).withValues(alpha: 0.15) : const Color(0xFFFFA000).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(rs(context, 6)),
                  ),
                  child: Text(b.status[0].toUpperCase() + b.status.substring(1),
                    style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600,
                      color: b.status == 'completed' ? const Color(0xFF4CAF50) : const Color(0xFFFFA000),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: rs(context, 6)),
            Row(
              children: [
                if (b.fileSizeHuman != null)
                  Text(b.fileSizeHuman!, style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary)),
                SizedBox(width: rs(context, 16)),
                if (b.createdAt != null)
                  Text(_formatDate(b.createdAt!), style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return d; }
  }
}
