import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class CheckWalletsStyle {
  final BuildContext context;
  final bool isDark;
  final Color? bg;
  final Color? rightIconBg;
  final Color? leftIconBg;
  final Color? mainTextColor;

  CheckWalletsStyle({
    required this.context,
    required this.isDark,
    this.bg,
    this.rightIconBg,
    this.leftIconBg,
    this.mainTextColor,
  });

  double get containerBorderRadius => rs(context, 14);
  Clip get containerClipBehavior => Clip.antiAlias;

  double get cardBorderRadius => rs(context, 14);
  Color get cardBackgroundColor => bg ?? (isDark ? const Color(0xFF2A2A2C) : AppColors.surfaceLight);

  EdgeInsetsGeometry get leftIconSPadding {
    return EdgeInsets.all(rs(context, 10));
  }

  Color get leftIconSBackgroundColor {
    return leftIconBg ?? (isDark ? const Color(0xFF333333) : const Color(0xFFD0DDD6));
  }

  double get leftIconSBorderRadius => rs(context, 10);

  EdgeInsetsGeometry get textContainerMargin {
    return EdgeInsets.only(left: rs(context, 10));
  }

  Color get headerTextSColor {
    return isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
  }

  double get headerTextSFontSize => rs(context, 11);
  double get headerTextSLineHeight => rs(context, 14);

  Color get mainTextSColor {
    return mainTextColor ?? (isDark ? AppColorsDark.textPrimary : AppColors.textPrimary);
  }

  double get mainTextSFontSize => rs(context, 14);
  double get mainTextSLineHeight => rs(context, 18);

  EdgeInsetsGeometry get rightIconSPadding {
    return EdgeInsets.all(rs(context, 10));
  }

  Color? get rightIconSBackgroundColor => rightIconBg;

  double get rightIconSBorderRadius => rs(context, 10);
}
