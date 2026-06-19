import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class CustomThemeSelectionStyle {
  final BuildContext context;
  final bool isDark;
  final String theme;
  final double? fixedWidth;
  final bool isChecked;

  CustomThemeSelectionStyle({
    required this.context,
    required this.isDark,
    required this.theme,
    this.fixedWidth,
    this.isChecked = false,
  });

  double get containerWidth => fixedWidth ?? double.infinity;
  Color get containerBorderColor => isDark ? AppColorsDark.borderPrimary : AppColors.borderPrimary;
  Color get containerBackgroundColor => isDark ? AppColorsDark.bgQuaternary : AppColors.bgQuaternary;
  double get containerBorderRadius => rs(context, 14);
  EdgeInsetsGeometry get containerPadding => EdgeInsets.all(rs(context, 12));

  double get checkboxSize => rs(context, 24);
  double get selectionBorderSize => rs(context, 24);
  Color get selectionBorderColor => isDark ? AppColorsDark.borderPrimary : AppColors.borderPrimary;
  double get selectionBorderWidth => 1.5;
  double get selectionBorderRadius => rs(context, 12);

  double get themeContainerMarginTop => 0;
  double get themeContainerMarginBottom => 0;
  double get themeContainerMarginLeft => rs(context, 12);
  double get mb5 => rs(context, 5);
  double get mb6 => rs(context, 6);
  double get middleContMarginBottom => rs(context, 6);
  double get mb4 => rs(context, 4);
}
