import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/models/system_settings_data.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/custom_loader.dart';
import '../../core/widgets/empty_state.dart';

class SystemSettingsWidget extends StatefulWidget {
  final VoidCallback onBack;
  const SystemSettingsWidget({super.key, required this.onBack});

  @override
  State<SystemSettingsWidget> createState() => _SystemSettingsWidgetState();
}

class _SystemSettingsWidgetState extends State<SystemSettingsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().load();
    });
  }

  void _editSetting(SystemSetting s) {
    final ctrl = TextEditingController(text: s.value);
    final descCtrl = TextEditingController(text: s.description);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.key),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Value')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(trans(context, 'Cancel'))),
          TextButton(
            onPressed: () async {
              final err = await context.read<SettingsProvider>().update(
                s.key, ctrl.text.trim(), description: descCtrl.text.trim(),
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (err == null) {
                  context.showSuccess('${s.key} updated');
                } else {
                  context.showError(err);
                }
              }
            },
            child: Text(trans(context, 'Save')),
          ),
        ],
      ),
    );
  }

  void _deleteSetting(SystemSetting s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${s.key}'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(trans(context, 'Cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(trans(context, 'Delete'), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final err = await context.read<SettingsProvider>().delete(s.key);
      if (mounted) {
        if (err == null) {
          context.showSuccess('${s.key} deleted');
        } else {
          context.showError(err);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final sp = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(
              child: sp.loading
                  ? const Center(child: CustomLoader())
                  : sp.settings.isEmpty
                      ? EmptyState(message: 'No settings found')
                      : RefreshIndicator(
                          onRefresh: sp.load,
                          child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 100)),
                            itemCount: sp.settings.length,
                            itemBuilder: (ctx, i) => _buildSettingItem(dc, sp.settings[i]),
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
          Text(trans(context, 'System Settings'),
            style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(StroappDialogColors dc, SystemSetting s) {
    return InkWell(
      onTap: () => _editSetting(s),
      borderRadius: BorderRadius.circular(rs(context, 14)),
      child: Container(
        margin: EdgeInsets.only(bottom: rs(context, 8)),
        padding: EdgeInsets.all(rs(context, 12)),
        decoration: BoxDecoration(
          color: dc.bg,
          borderRadius: BorderRadius.circular(rs(context, 14)),
          border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.key, style: TextStyle(fontWeight: FontWeight.w600, fontSize: rs(context, 13), color: dc.textPrimary)),
                  SizedBox(height: rs(context, 4)),
                  Text(s.value, style: TextStyle(fontSize: rs(context, 12), color: dc.accent)),
                  if (s.description.isNotEmpty) ...[
                    SizedBox(height: rs(context, 2)),
                    Text(s.description, style: TextStyle(fontSize: rs(context, 10), color: dc.textSecondary)),
                  ],
                ],
              ),
            ),
            InkWell(
              onTap: () => _deleteSetting(s),
              borderRadius: BorderRadius.circular(rs(context, 6)),
              child: Container(
                padding: EdgeInsets.all(rs(context, 6)),
                decoration: BoxDecoration(color: const Color(0xFFC62828).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(rs(context, 6))),
                child: SvgPicture.asset('assets/icons/trush_square_icon_242180.svg',
                  width: rs(context, 16), colorFilter: const ColorFilter.mode(Color(0xFFC62828), BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
