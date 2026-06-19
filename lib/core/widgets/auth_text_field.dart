import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors_unified.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String iconPath;
  final bool isPassword;
  final bool isRtl;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.iconPath,
    this.isPassword = false,
    this.isRtl = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final surfaceHighlight = Theme.of(context).brightness == Brightness.dark
        ? AppColors.surfaceHighlightDark
        : AppColors.surfaceHighlightLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: surfaceHighlight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(iconPath, width: 24, height: 24,
                colorFilter: ColorFilter.mode(textPrimary, BlendMode.srcIn),
              ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: isPassword && !isPasswordVisible,
                cursorColor: textPrimary,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                validator: validator,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                  filled: false,
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: SvgPicture.asset(
                            isPasswordVisible
                                ? 'assets/icons/eye_off.svg'
                                : 'assets/icons/eye_on_see_show_view_vision_watch_icon_123215.svg',
                            width: 24, height: 24,
                            colorFilter: ColorFilter.mode(textPrimary, BlendMode.srcIn),
                          ),
                          onPressed: onTogglePassword,
                        )
                      : null,
                  contentPadding: const EdgeInsets.only(bottom: 10),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: textSecondary,
                      width: 1,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: textSecondary,
                      width: 1,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: textSecondary,
                      width: 1,
                    ),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                  errorStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.error,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
