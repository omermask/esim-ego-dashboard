import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';

class CustomButtonStyle {
  final BuildContext context;
  final bool isDark;
  final Color? bgColor;
  final Color? color;
  final bool disabled;
  final Widget? icon;
  final dynamic title;

  CustomButtonStyle({
    required this.context,
    required this.isDark,
    this.bgColor,
    this.color,
    this.disabled = false,
    this.icon,
    this.title,
  });

  BoxDecoration get btnCont {
    return BoxDecoration(
      color: bgColor ?? (isDark ? const Color(0xFFA5CDBF) : const Color(0xFF185A46)),
      borderRadius: BorderRadius.circular(rs(context, 12)),
    );
  }

  TextStyle get btnText {
    return TextStyle(
      color: color ?? (isDark ? const Color(0xFF121212) : Colors.white),
      fontSize: rs(context, 14),
      fontWeight: FontWeight.w600,
    );
  }
}
