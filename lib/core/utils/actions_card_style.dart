import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';

class ActionsCardStyle {
  final BuildContext context;
  final bool isDark;
  final Color? bg;
  final Color? textColor;
  final Color? borderColor;
  final bool last;
  final double? fixedWidth;

  ActionsCardStyle({
    required this.context,
    required this.isDark,
    this.bg,
    this.textColor,
    this.borderColor,
    this.last = false,
    this.fixedWidth,
  });

  EdgeInsetsGeometry get containerMargin {
    return EdgeInsets.only(bottom: last ? 0 : rs(context, 10));
  }

  BoxDecoration get container {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(rs(context, 14)),
    );
  }

  BoxDecoration get card {
    return BoxDecoration(
      color: bg ?? (isDark ? const Color(0xFF2A2A2C) : const Color(0xFFE2ECE6)),
      borderRadius: BorderRadius.circular(rs(context, 14)),
      border: Border.all(
        color: borderColor ?? (isDark ? const Color(0xFF3F3F46) : const Color(0xFFB6C6BC)),
        width: 1,
      ),
    );
  }

  double get cardWidth => fixedWidth ?? double.infinity;
  double get cardHeight => rs(context, 100);

  EdgeInsetsGeometry get cardPadding {
    return EdgeInsets.all(rs(context, 12));
  }

  EdgeInsetsGeometry get textSMargin {
    return EdgeInsets.only(top: rs(context, 8));
  }

  TextStyle get textS {
    return TextStyle(
      color: textColor ?? (isDark ? Colors.white : const Color(0xFF111111)),
      fontSize: rs(context, 13),
      fontWeight: FontWeight.w600,
    );
  }
}
