import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/translation.dart';

class AuthUnderlineTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? leadingIconPath;
  final Widget? leadingWidget;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool showForgotPassword;
  final VoidCallback? onForgotPasswordTap;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;
  final Future<void> Function(String)? onFieldSubmitted;
  final Widget? suffixWidget;

  const AuthUnderlineTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.leadingIconPath,
    this.leadingWidget,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.showForgotPassword = false,
    this.onForgotPasswordTap,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onFieldSubmitted,
    this.suffixWidget,
  });

  @override
  State<AuthUnderlineTextField> createState() => _AuthUnderlineTextFieldState();
}

class _AuthUnderlineTextFieldState extends State<AuthUnderlineTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;
    final hintAndLineColor = isDark
        ? Colors.grey.withValues(alpha: 0.5)
        : Colors.grey.withValues(alpha: 0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: widget.leadingWidget ?? (widget.leadingIconPath != null
                  ? SvgPicture.asset(widget.leadingIconPath!, width: 24, height: 24,
                      colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                    )
                  : const SizedBox(width: 24, height: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                obscureText: _obscureText,
                keyboardType: widget.keyboardType,
                textCapitalization: widget.textCapitalization,
                validator: widget.validator,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onFieldSubmitted,
                cursorColor: primaryColor,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ITFGhroobArabic',
                  letterSpacing: widget.isPassword ? 2.0 : 0.0,
                ),
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(
                    color: hintAndLineColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'ITFGhroobArabic',
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.only(bottom: 8, top: 4),
                  suffixIcon: widget.suffixWidget ?? (widget.isPassword
                      ? IconButton(
                          icon: SvgPicture.asset(
                            _obscureText
                                ? 'assets/icons/eye_on_see_show_view_vision_watch_icon_123215.svg'
                                : 'assets/icons/eye_off.svg',
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                      : null),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: hintAndLineColor, width: 1.5),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: hintAndLineColor, width: 1.5),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2.0),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE53935), width: 2.0),
                  ),
                  focusedErrorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE53935), width: 2.0),
                  ),
                  errorStyle: TextStyle(
                    fontFamily: 'ITFGhroobArabic',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFE53935),
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.showForgotPassword) ...[
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GestureDetector(
              onTap: widget.onForgotPasswordTap,
                child: Text(
                  trans(context, 'Forgot Password?'),
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'ITFGhroobArabic',
                  ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
