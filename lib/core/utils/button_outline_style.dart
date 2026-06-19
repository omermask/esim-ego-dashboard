import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';

class ButtonOutlineStyle {
  final BuildContext context;
  final bool isDark;
  final Color? bgColor;
  final Color? color;
  final Color? borderColor;
  final bool disabled;
  final Widget? icon;
  final String? title;

  ButtonOutlineStyle({
    required this.context,
    required this.isDark,
    this.bgColor,
    this.color,
    this.borderColor,
    this.disabled = false,
    this.icon,
    this.title,
  });

  BoxDecoration get btnOutlineCont {
    return BoxDecoration(
      color: bgColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(rs(context, 12)),
      border: Border.all(
        color: borderColor ?? (isDark ? const Color(0xFF3F3F46) : const Color(0xFFB6C6BC)),
        width: 1,
      ),
    );
  }

  EdgeInsetsGeometry get btnOutlineTextMargin {
    return EdgeInsets.only(left: icon != null ? rs(context, 6) : 0);
  }

  TextStyle get btnOutlineText {
    return TextStyle(
      color: color ?? (isDark ? Colors.white : const Color(0xFF111111)),
      fontSize: rs(context, 13),
      fontWeight: FontWeight.w600,
    );
  }

  EdgeInsetsGeometry get btnOutlineContPadding {
    return EdgeInsets.symmetric(horizontal: rs(context, 16));
  }
}
