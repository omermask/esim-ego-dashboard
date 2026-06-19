import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? topLabel;
  final String? helperText;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.topLabel,
    this.helperText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBorderColor = isDark
        ? Colors.grey.withValues(alpha: 0.2)
        : Colors.grey.withValues(alpha: 0.3);
    final focusedBorderColor = theme.colorScheme.primary;
    const errorColor = Color(0xFFE53935);

    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: defaultBorderColor, width: 1.0),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: errorColor, width: 1.5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topLabel != null) ...[
          Text(
            topLabel!,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'ITFGhroobArabic',
            ),
          ),
          const SizedBox(height: 10),
        ],
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onTap: onTap,
          cursorColor: focusedBorderColor,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
            fontFamily: 'ITFGhroobArabic',
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 15,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
            hintText: hintText,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontFamily: 'ITFGhroobArabic',
            ),
            border: defaultBorder,
            enabledBorder: defaultBorder,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
            prefixIcon: prefixIcon,
            suffixIcon: isPassword && suffixIcon == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SvgPicture.asset(
                      'assets/icons/lock_icon.svg',
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        BlendMode.srcIn,
                      ),
                      width: 22, height: 22,
                    ),
                  )
                : suffixIcon,
            helperText: helperText,
            helperStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'ITFGhroobArabic',
            ),
            errorStyle: TextStyle(
              color: errorColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'ITFGhroobArabic',
            ),
          ),
        ),
      ],
    );
  }
}
