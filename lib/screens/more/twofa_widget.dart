import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/twofa_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';

class TwoFAWidget extends StatefulWidget {
  final VoidCallback onBack;
  const TwoFAWidget({super.key, required this.onBack});

  @override
  State<TwoFAWidget> createState() => _TwoFAWidgetState();
}

class _TwoFAWidgetState extends State<TwoFAWidget> {
  final _codeCtrl = TextEditingController();
  String? _secret;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _setup() async {
    final err = await context.read<TwoFAProvider>().setup();
    if (mounted) {
      if (err == null) {
        final data = context.read<TwoFAProvider>().setupData;
        setState(() {
          _secret = data?['secret']?.toString();
        });
      } else {
        context.showError(err);
      }
    }
  }

  Future<void> _enable() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      context.showError('Enter a valid 6-digit code');
      return;
    }
    final err = await context.read<TwoFAProvider>().enable(code);
    if (mounted) {
      if (err == null) {
        context.showSuccess(trans(context, '2FA enabled successfully'));
        setState(() { _secret = null; });
      } else {
        context.showError(err);
      }
    }
  }

  Future<void> _disable() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      context.showError('Enter a valid 6-digit code');
      return;
    }
    final err = await context.read<TwoFAProvider>().disable(code);
    if (mounted) {
      if (err == null) {
        context.showSuccess(trans(context, '2FA disabled'));
      } else {
        context.showError(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<TwoFAProvider>();

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
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(rs(context, 20)),
                decoration: BoxDecoration(
                  color: dc.bg,
                  borderRadius: BorderRadius.circular(rs(context, 20)),
                  border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Column(
                  children: [
                    SvgPicture.asset('assets/icons/shield_security_icon_242117.svg',
                      width: rs(context, 60), colorFilter: ColorFilter.mode(dc.accent, BlendMode.srcIn),
                    ),
                    SizedBox(height: rs(context, 16)),
                    Text(trans(context, 'Two-Factor Authentication'),
                      style: TextStyle(fontSize: rs(context, 18), fontWeight: FontWeight.w700, color: dc.textPrimary),
                    ),
                    SizedBox(height: rs(context, 8)),
                    Text(trans(context, 'Scan the QR code with your authenticator app'),
                      style: TextStyle(fontSize: rs(context, 13), color: dc.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    if (_secret != null) ...[
                      SizedBox(height: rs(context, 16)),
                      Container(
                        padding: EdgeInsets.all(rs(context, 12)),
                        decoration: BoxDecoration(
                          color: dc.iconBox,
                          borderRadius: BorderRadius.circular(rs(context, 12)),
                        ),
                        child: SelectableText(_secret!,
                          style: TextStyle(fontSize: rs(context, 14), fontWeight: FontWeight.w600,
                            color: dc.accent, letterSpacing: 2),
                        ),
                      ),
                    ],
                    SizedBox(height: rs(context, 20)),
                    Container(
                      decoration: BoxDecoration(
                        color: dc.iconBox,
                        borderRadius: BorderRadius.circular(rs(context, 14)),
                      ),
                      child: TextField(
                        controller: _codeCtrl,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 18), letterSpacing: 8),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '000000',
                          hintStyle: TextStyle(color: dc.textSecondary, letterSpacing: 8),
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: rs(context, 14)),
                        ),
                      ),
                    ),
                    SizedBox(height: rs(context, 20)),
                    Row(
                      children: [
                        if (_secret != null)
                          Expanded(
                            child: InkWell(
                              onTap: provider.loading ? null : _enable,
                              borderRadius: BorderRadius.circular(rs(context, 14)),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
                                decoration: BoxDecoration(color: dc.accent, borderRadius: BorderRadius.circular(rs(context, 14))),
                                child: Center(
                                  child: provider.loading
                                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : Text(trans(context, 'Enable'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),
                        if (_secret == null) ...[
                          Expanded(
                            child: InkWell(
                              onTap: provider.loading ? null : _setup,
                              borderRadius: BorderRadius.circular(rs(context, 14)),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
                                decoration: BoxDecoration(color: dc.accent, borderRadius: BorderRadius.circular(rs(context, 14))),
                                child: Center(
                                  child: provider.loading
                                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : Text(trans(context, 'Setup'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: rs(context, 12)),
                          Expanded(
                            child: InkWell(
                              onTap: provider.loading ? null : _disable,
                              borderRadius: BorderRadius.circular(rs(context, 14)),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC62828).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(rs(context, 14)),
                                ),
                                child: Center(
                                  child: Text(trans(context, 'Disable'), style: TextStyle(color: const Color(0xFFC62828), fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
        Text(trans(context, 'Two-Factor Auth'),
          style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
        ),
      ],
    );
  }
}
