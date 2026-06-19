import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';

class BottomSheetStyle {
  final BuildContext context;
  final bool isDark;
  final Color? indicatorColor;
  final Color? bgColor;

  BottomSheetStyle({
    required this.context,
    required this.isDark,
    this.indicatorColor,
    this.bgColor,
  });

  BoxDecoration get backgroundStyle {
    return BoxDecoration(
      color: bgColor ?? (isDark ? const Color(0xFF2A2A2C) : const Color(0xFFE2ECE6)),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    );
  }

  double get indicatorWidth => 40;
  double get indicatorHeight => 4;

  BoxDecoration get bottomSheetIndicator {
    return BoxDecoration(
      color: indicatorColor ?? (isDark ? const Color(0xFF3F3F46) : const Color(0xFFB6C6BC)),
      borderRadius: BorderRadius.circular(2),
    );
  }

  EdgeInsetsGeometry get contentContainer {
    return EdgeInsets.all(rs(context, 16));
  }
}
