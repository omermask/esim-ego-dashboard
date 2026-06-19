import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/freeze_provider.dart';
import '../../data/models/freeze_data.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/custom_loader.dart';

class FreezesWidget extends StatefulWidget {
  final VoidCallback onBack;
  const FreezesWidget({super.key, required this.onBack});

  @override
  State<FreezesWidget> createState() => _FreezesWidgetState();
}

class _FreezesWidgetState extends State<FreezesWidget> {
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FreezeProvider>().load(refresh: true).then((_) {
        if (mounted) setState(() => _initialLoaded = true);
      });
    });
  }

  Future<void> _refresh() async {
    await context.read<FreezeProvider>().load(refresh: true);
  }

  void _showCreateDialog() {
    final userIdCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(trans(context, 'Create Freeze')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: userIdCtrl, decoration: const InputDecoration(labelText: 'User ID')),
              SizedBox(height: rs(context, 12)),
              TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount')),
              SizedBox(height: rs(context, 12)),
              TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Reason')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(trans(context, 'Cancel'))),
          ElevatedButton(
            onPressed: () async {
              final amt = int.tryParse(amtCtrl.text.trim()) ?? 0;
              final err = await context.read<FreezeProvider>().create(
                userIdCtrl.text.trim(), amt, reason: reasonCtrl.text.trim(),
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (err == null) {
                  context.showSuccess(trans(context, 'Freeze created'));
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

  Future<void> _release(String id) async {
    final err = await context.read<FreezeProvider>().release(id);
    if (mounted) {
      if (err == null) {
        context.showSuccess(trans(context, 'Freeze released'));
      } else {
        context.showError(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<FreezeProvider>();
    final freezes = provider.freezes;
    final loading = provider.loading;
    final hasMore = provider.hasMore;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(child: _buildContent(dc, freezes, loading, hasMore, provider)),
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
            child: Text(trans(context, 'Freezes'),
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

  Widget _buildContent(StroappDialogColors dc, List<Freeze> freezes, bool loading, bool hasMore, FreezeProvider provider) {
    if (!_initialLoaded && loading) return const Center(child: CustomLoader());
    if (freezes.isEmpty && !loading) {
      return Center(child: EmptyState(message: trans(context, 'No freezes found'), onRetry: _refresh));
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
          itemCount: freezes.length + (hasMore ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i >= freezes.length) {
              return const Padding(
                padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildFreezeItem(dc, freezes[i]);
          },
        ),
      ),
    );
  }

  Widget _buildFreezeItem(StroappDialogColors dc, Freeze f) {
    final isActive = f.status == 'active';
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
                  child: Text(f.userName ?? f.userId ?? 'Freeze',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFE53935).withValues(alpha: 0.15) : const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(rs(context, 6)),
                  ),
                  child: Text(isActive ? 'Active' : 'Released',
                    style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600,
                      color: isActive ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: rs(context, 8)),
            Text('${f.amount} IQD', style: TextStyle(fontSize: rs(context, 14), fontWeight: FontWeight.w700, color: dc.textPrimary)),
            if (f.reason.isNotEmpty) ...[
              SizedBox(height: rs(context, 4)),
              Text(f.reason, style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary)),
            ],
            if (isActive) ...[
              SizedBox(height: rs(context, 10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _release(f.id),
                    borderRadius: BorderRadius.circular(rs(context, 10)),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 6)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(rs(context, 10)),
                      ),
                      child: Text(trans(context, 'Release'),
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
}
