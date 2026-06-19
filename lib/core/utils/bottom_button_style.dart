import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';

class BottomButtonStyle {
  final BuildContext context;
  final bool isDark;
  final bool disable;

  BottomButtonStyle({
    required this.context,
    required this.isDark,
    this.disable = false,
  });

  BoxDecoration get footerCont {
    return BoxDecoration(
      color: isDark ? const Color(0xFF2A2A2C) : const Color(0xFFE2ECE6),
    );
  }

  TextStyle get cancelBtn {
    return TextStyle(
      color: isDark ? Colors.white : const Color(0xFF111111),
      fontSize: rs(context, 14),
      fontWeight: FontWeight.w500,
    );
  }

  Color get depositNowBtnBackgroundColor {
    return isDark ? const Color(0xFFA5CDBF) : const Color(0xFF185A46);
  }

  Color get btnTextColor {
    return isDark ? const Color(0xFF121212) : const Color(0xFFEAF5F0);
  }

  BorderRadius get depositNowBtnBorderRadius {
    return BorderRadius.circular(rs(context, 12));
  }
}
