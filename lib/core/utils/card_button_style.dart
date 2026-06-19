import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';

class CardButtonStyle {
  final BuildContext context;
  final bool isDark;
  final Color? textColor;

  CardButtonStyle({
    required this.context,
    required this.isDark,
    this.textColor,
  });

  EdgeInsetsGeometry get titleMargin {
    return EdgeInsets.only(right: rs(context, 8));
  }

  TextStyle get title {
    return TextStyle(
      color: textColor ?? (isDark ? Colors.white : const Color(0xFF111111)),
      fontSize: rs(context, 14),
      fontWeight: FontWeight.w600,
    );
  }
}
