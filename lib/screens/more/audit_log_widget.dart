import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/audit_log_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/custom_loader.dart';

class AuditLogWidget extends StatefulWidget {
  final VoidCallback onBack;
  const AuditLogWidget({super.key, required this.onBack});

  @override
  State<AuditLogWidget> createState() => _AuditLogWidgetState();
}

class _AuditLogWidgetState extends State<AuditLogWidget> {
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditLogProvider>().load(refresh: true).then((_) {
        if (mounted) setState(() => _initialLoaded = true);
      });
    });
  }

  Future<void> _refresh() async {
    await context.read<AuditLogProvider>().load(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<AuditLogProvider>();
    final logs = provider.logs;
    final loading = provider.loading;
    final hasMore = provider.hasMore;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(child: _buildContent(dc, logs, loading, hasMore, provider)),
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
          Text(trans(context, 'Audit Log'),
            style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(StroappDialogColors dc, List<AuditLogEntry> logs, bool loading, bool hasMore, AuditLogProvider provider) {
    if (!_initialLoaded && loading) return const Center(child: CustomLoader());
    if (logs.isEmpty && !loading) {
      return Center(child: EmptyState(message: trans(context, 'No audit logs found'), onRetry: _refresh));
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
          itemCount: logs.length + (hasMore ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i >= logs.length) {
              return const Padding(
                padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildLogItem(dc, logs[i]);
          },
        ),
      ),
    );
  }

  Widget _buildLogItem(StroappDialogColors dc, AuditLogEntry l) {
    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 8)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 14)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(rs(context, 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
                  decoration: BoxDecoration(
                    color: dc.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(rs(context, 6)),
                  ),
                  child: Text(l.action,
                    style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600, color: dc.accent),
                  ),
                ),
                SizedBox(width: rs(context, 8)),
                if (l.resourceType != null)
                  Text(l.resourceType!, style: TextStyle(fontSize: rs(context, 11), color: dc.textSecondary)),
              ],
            ),
            SizedBox(height: rs(context, 6)),
            if (l.userName != null)
              Text(l.userName!, style: TextStyle(fontSize: rs(context, 12), fontWeight: FontWeight.w600, color: dc.textPrimary)),
            if (l.details != null && l.details!.isNotEmpty) ...[
              SizedBox(height: rs(context, 4)),
              Text(l.details!, style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary)),
            ],
            SizedBox(height: rs(context, 4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (l.ipAddress != null)
                  Text(l.ipAddress!, style: TextStyle(fontSize: rs(context, 10), color: dc.textSecondary)),
                if (l.createdAt != null)
                  Text(_formatDate(l.createdAt!), style: TextStyle(fontSize: rs(context, 10), color: dc.textSecondary)),
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
