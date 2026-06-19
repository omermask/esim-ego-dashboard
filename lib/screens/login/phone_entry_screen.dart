import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/theme_provider.dart';
import '../../data/providers/locale_provider.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/toaster.dart';
import '../../core/utils/translation.dart';
import '../../core/widgets/auth_card.dart';
import '../../core/widgets/auth_underline_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/language_selection_dialog.dart';
import 'otp_verification_screen.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _initialLoading = false);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = '964${_phoneController.text.trim()}';
    if (phone.length < 12) {
      _showError(trans(context, 'Please enter a valid phone number'));
      return;
    }
    final auth = context.read<AuthProvider>();
    final result = await auth.sendOtp(phone);
    if (!mounted) return;
    if (result == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OtpVerificationScreen()),
      );
    } else {
      _showError(result);
    }
  }

  void _showError(String message) {
    CustomToaster.showError(context, message: message);
  }

  void _showLanguageDialog() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => LanguageSelectionDialog(
        initialCode: context.read<LocaleProvider>().languageCode,
      ),
    );
    if (code != null && mounted) {
      context.read<LocaleProvider>().setLanguage(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final sc = context.screenColors;
    final dc = context.dialogColors;
    final locale = context.watch<LocaleProvider>();

    if (_initialLoading) {
      return Scaffold(
        backgroundColor: sc.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: sc.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: rs(context, 24)),
            child: Column(
              children: [
                SizedBox(height: rs(context, 16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _showLanguageDialog,
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: dc.iconBox,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('assets/icons/language_121815.svg',
                                width: 20, height: 20,
                                colorFilter: ColorFilter.mode(dc.textPrimary, BlendMode.srcIn)),
                            SizedBox(width: rs(context, 6)),
                            Text(
                              locale.languageCode.toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: dc.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.read<ThemeProvider>().toggle(),
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: dc.iconBox,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: SvgPicture.asset(
                          isDark ? 'assets/icons/sun-sunny.svg' : 'assets/icons/moon_dark_mode.svg',
                          width: 22, height: 22,
                          colorFilter: ColorFilter.mode(dc.textPrimary, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: rs(context, 20)),
                AuthCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: rs(context, 16)),
                      Center(
                        child: SvgPicture.asset(
                          'assets/images/completion.svg',
                          width: rs(context, 120),
                          height: rs(context, 120),
                        ),
                      ),
                      SizedBox(height: rs(context, 20)),
                      Center(
                        child: Text(
                          'eSIM E-Go',
                          style: TextStyle(
                            fontSize: rs(context, 24),
                            fontWeight: FontWeight.w700,
                            color: dc.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: rs(context, 28)),
                      AuthUnderlineTextField(
                        controller: _phoneController,
                        labelText: trans(context, 'PHONE NUMBER'),
                        leadingIconPath: 'assets/icons/Phone-cal.svg',
                        leadingWidget: FittedBox(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              '+964',
                              style: TextStyle(
                                fontSize: rs(context, 16),
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: rs(context, 28)),
                      CustomButton(
                        text: trans(context, 'Login'),
                        onPressed: auth.loading ? null : _submit,
                        isLoading: auth.loading,
                      ),
                      SizedBox(height: rs(context, 8)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
