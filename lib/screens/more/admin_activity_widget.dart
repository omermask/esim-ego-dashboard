import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/analytics_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/widgets/custom_loader.dart';

class AdminActivityWidget extends StatefulWidget {
  final VoidCallback onBack;
  const AdminActivityWidget({super.key, required this.onBack});

  @override
  State<AdminActivityWidget> createState() => _AdminActivityWidgetState();
}

class _AdminActivityWidgetState extends State<AdminActivityWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadActivity(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final ap = context.watch<AnalyticsProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(
              child: ap.loading && ap.activity.isEmpty
                  ? const Center(child: CustomLoader())
                  : RefreshIndicator(
                      onRefresh: () => ap.loadActivity(refresh: true),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n is ScrollEndNotification && n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                            ap.loadActivity();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 100)),
                          itemCount: ap.activity.length + (ap.hasMoreActivity ? 1 : 0),
                          itemBuilder: (ctx, i) {
                            if (i >= ap.activity.length) {
                              return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                            }
                            return _buildActivityItem(dc, ap.activity[i]);
                          },
                        ),
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
          Text(trans(context, 'Admin Activity'),
            style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(StroappDialogColors dc, dynamic log) {
    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 8)),
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 14)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 6), vertical: rs(context, 2)),
                decoration: BoxDecoration(
                  color: dc.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(rs(context, 4)),
                ),
                child: Text(log.action, style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600, color: dc.accent)),
              ),
              SizedBox(width: rs(context, 8)),
              if (log.resourceType != null)
                Text(log.resourceType, style: TextStyle(fontSize: rs(context, 11), color: dc.textSecondary)),
              const Spacer(),
              if (log.createdAt != null)
                Text(_fmtDate(log.createdAt), style: TextStyle(fontSize: rs(context, 10), color: dc.textSecondary)),
            ],
          ),
          if (log.userName != null) ...[
            SizedBox(height: rs(context, 4)),
            Text(log.userName, style: TextStyle(fontSize: rs(context, 12), fontWeight: FontWeight.w500, color: dc.textPrimary)),
          ],
          if (log.ipAddress != null) ...[
            SizedBox(height: rs(context, 2)),
            Text(log.ipAddress, style: TextStyle(fontSize: rs(context, 10), color: dc.textSecondary)),
          ],
        ],
      ),
    );
  }

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return d; }
  }
}
