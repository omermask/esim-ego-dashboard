import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/responsive_size.dart';
import '../utils/translation.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TwoFactorDialog extends StatefulWidget {
  final String title;
  final String message;
  final Future<String?> Function(String)? onVerify;

  const TwoFactorDialog({
    super.key,
    this.title = 'Two-Factor Authentication',
    this.message = 'Please enter your 2FA code',
    this.onVerify,
  });

  static Future<String?> show(
    BuildContext context, {
    String? title,
    String? message,
    Future<String?> Function(String)? onVerify,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: TwoFactorDialog(
          title: title ?? 'Two-Factor Authentication',
          message: message ?? 'Please enter your 2FA code',
          onVerify: onVerify,
        ),
      ),
    );
  }

  @override
  State<TwoFactorDialog> createState() => _TwoFactorDialogState();
}

class _TwoFactorDialogState extends State<TwoFactorDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isVerifying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_isVerifying) return;

    final code = _controller.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-digit code');
      return;
    }

    if (widget.onVerify != null) {
      setState(() {
        _isVerifying = true;
        _errorMessage = null;
      });

      final error = await widget.onVerify!(code);

      if (mounted) {
        setState(() => _isVerifying = false);
        if (error != null) {
          setState(() => _errorMessage = error);
          _controller.clear();
          return;
        }
      }
    }

    if (mounted) {
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2A2A2C) : const Color(0xFFE2ECE6);
    final accent = isDark ? const Color(0xFFFFB28B) : const Color(0xFFED6A46);
    final textPrimary = isDark ? Colors.white : const Color(0xFF111111);
    final textSecondary = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF4D5A53);
    final primaryBtn = isDark ? const Color(0xFFA5CDBF) : const Color(0xFF185A46);
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFB6C6BC);
    final inputField = isDark ? const Color(0xFF383838) : const Color(0xFFD0DDD6);

    return Container(
      color: bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: inputField,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/security_icon_241960.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.message,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
                SizedBox(height: rs(context, 16)),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                    color: textPrimary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: inputField,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: primaryBtn,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: rs(context, 12)),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: rs(context, 12),
                      color: Colors.redAccent,
                    ),
                  ),
                ],
                SizedBox(height: rs(context, 20)),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isVerifying ? null : () => Navigator.of(context).pop(null),
                        child: Text(trans(context, 'Cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _confirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBtn,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isVerifying
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(trans(context, 'Verify')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
