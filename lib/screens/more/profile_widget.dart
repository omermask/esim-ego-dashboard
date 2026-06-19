import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';

class ProfileWidget extends StatefulWidget {
  final VoidCallback onBack;
  const ProfileWidget({super.key, required this.onBack});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final auth = context.watch<AuthProvider>();
    final user = auth.user ?? {};

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), rs(context, 100)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(dc),
              SizedBox(height: rs(context, 24)),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: rs(context, 80), height: rs(context, 80),
                      decoration: BoxDecoration(
                        color: dc.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(rs(context, 40)),
                      ),
                      child: Center(
                        child: Text(
                          (user['name']?.toString() ?? 'A')[0].toUpperCase(),
                          style: TextStyle(fontSize: rs(context, 32), fontWeight: FontWeight.w700, color: dc.accent),
                        ),
                      ),
                    ),
                    SizedBox(height: rs(context, 12)),
                    Text(user['name']?.toString() ?? 'Admin',
                      style: TextStyle(fontSize: rs(context, 18), fontWeight: FontWeight.w700, color: dc.textPrimary),
                    ),
                    SizedBox(height: rs(context, 4)),
                    Text(user['phone']?.toString() ?? '',
                      style: TextStyle(fontSize: rs(context, 13), color: dc.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: rs(context, 24)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(rs(context, 16)),
                decoration: BoxDecoration(
                  color: dc.bg,
                  borderRadius: BorderRadius.circular(rs(context, 20)),
                  border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trans(context, 'Profile Info'), style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary,
                    )),
                    SizedBox(height: rs(context, 12)),
                    _infoRow(dc, 'Name', user['name']?.toString() ?? '—'),
                    _infoRow(dc, 'Phone', user['phone']?.toString() ?? '—'),
                    _infoRow(dc, 'Email', user['email']?.toString() ?? '—'),
                    _infoRow(dc, 'Role', user['role']?.toString() ?? '—'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StroappDialogColors dc) {
    return Row(
      children: [
        InkWell(
          onTap: widget.onBack,
          child: SvgPicture.asset('assets/icons/rightArrow.svg',
            width: rs(context, 22),
            colorFilter: ColorFilter.mode(dc.textPrimary, BlendMode.srcIn),
          ),
        ),
        SizedBox(width: rs(context, 12)),
        Text(trans(context, 'Profile'),
          style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
        ),
      ],
    );
  }

  Widget _infoRow(StroappDialogColors dc, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(context, 6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: rs(context, 13), color: dc.textSecondary)),
          Text(value, style: TextStyle(fontSize: rs(context, 13), fontWeight: FontWeight.w600, color: dc.textPrimary)),
        ],
      ),
    );
  }
}
