import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/toaster.dart';
import '../../core/utils/translation.dart';
import '../../core/widgets/auth_card.dart';
import '../../core/widgets/custom_button.dart';
import '../dashboard/dashboard_screen.dart';
import 'two_factor_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _codeControllers) { c.dispose(); }
    for (final f in _codeFocusNodes) { f.dispose(); }
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
      } else {
        if (mounted) setState(() => _resendSeconds--);
      }
    });
  }

  void _onCodeChange(int index, String value) {
    if (value.length == 1 && index < 5) {
      _codeFocusNodes[index + 1].requestFocus();
    }
    if (index == 5 && value.length == 1) {
      _codeFocusNodes[index].unfocus();
      _verifyCode();
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length != 6) {
      _showError('يرجى إدخال رمز التحقق المكون من 6 أرقام');
      return;
    }
    final auth = context.read<AuthProvider>();
    final result = await auth.verifyOtp(code);
    if (!mounted) return;
    if (result == '2FA_REQUIRED') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TwoFactorScreen()),
      );
    } else if (result == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      _showError(result);
    }
  }

  Future<void> _resendCode() async {
    final auth = context.read<AuthProvider>();
    final phone = auth.phone;
    if (phone.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final result = await auth.sendOtp(phone);
    if (!mounted) return;
    if (result == null) {
      _startResendTimer();
      for (final c in _codeControllers) { c.clear(); }
      _codeFocusNodes[0].requestFocus();
      _showSuccess(trans(context, 'Verification code resent!'));
    } else {
      _showError(result);
    }
  }

  void _showError(String message) {
    CustomToaster.showError(context, message: message);
  }

  void _showSuccess(String message) {
    CustomToaster.showSuccess(context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final sc = context.screenColors;
    final dc = context.dialogColors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: sc.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(right: rs(context, 8)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: rs(context, 44),
                height: rs(context, 44),
                decoration: BoxDecoration(
                  color: dc.bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SvgPicture.asset('assets/icons/arrow_back_chevron_direction_left_navigation_right_icon_123223.svg',
                    width: rs(context, 20), height: rs(context, 20),
                    colorFilter: ColorFilter.mode(dc.textPrimary, BlendMode.srcIn)),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(rs(context, 24), 0, rs(context, 24), rs(context, 40)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: rs(context, 20)),
                    Container(
                      width: rs(context, 64),
                      height: rs(context, 64),
                      decoration: BoxDecoration(
                        color: dc.bg,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: SvgPicture.asset('assets/icons/sms_icon_242073.svg',
                          width: rs(context, 32), height: rs(context, 32),
                          colorFilter: ColorFilter.mode(dc.accent, BlendMode.srcIn)),
                    ),
                    SizedBox(height: rs(context, 20)),
                    Text(
                      'تأكيد رقم الهاتف',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rs(context, 22),
                        fontWeight: FontWeight.w700,
                        color: dc.textPrimary,
                      ),
                    ),
                    SizedBox(height: rs(context, 8)),
                    Text(
                      'أدخل رمز التحقق المرسل إلى',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rs(context, 14),
                        color: dc.textSecondary,
                      ),
                    ),
                    SizedBox(height: rs(context, 4)),
                    Text(
                      auth.phone,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rs(context, 16),
                        fontWeight: FontWeight.w600,
                        color: dc.textPrimary,
                      ),
                    ),
                    SizedBox(height: rs(context, 28)),
                    AuthCard(
                      child: Column(
                        children: [
                          SizedBox(height: rs(context, 8)),
                          Form(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(6, (index) {
                                return SizedBox(
                                  width: rs(context, 44),
                                  child: TextField(
                                    controller: _codeControllers[index],
                                    focusNode: _codeFocusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    style: TextStyle(
                                      fontSize: rs(context, 24),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2,
                                      color: dc.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: dc.iconBox,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: dc.accent,
                                            width: 1.5),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (v) =>
                                        _onCodeChange(index, v),
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: rs(context, 32)),
                          CustomButton(
                            text: trans(context, 'Verify'),
                            onPressed: auth.loading ? null : _verifyCode,
                            isLoading: auth.loading,
                          ),
                          SizedBox(height: rs(context, 16)),
                          if (_resendSeconds > 0)
                            Text(
                              'إعادة الإرسال بعد $_resendSeconds ثانية',
                              style: TextStyle(
                                color: dc.textSecondary,
                                fontSize: rs(context, 14),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: auth.loading ? null : _resendCode,
                              child: Text(
                                trans(context, 'Resend'),
                                style: TextStyle(
                                  color: dc.primaryBtn,
                                  fontSize: rs(context, 14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          SizedBox(height: rs(context, 4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
