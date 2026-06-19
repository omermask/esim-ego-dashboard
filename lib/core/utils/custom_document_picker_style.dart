import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class CustomDocumentPickerStyle {
  final BuildContext context;
  final bool isDark;
  final dynamic value;
  final bool isError;
  final double? layoutWidth;

  CustomDocumentPickerStyle({
    required this.context,
    required this.isDark,
    this.value,
    this.isError = false,
    this.layoutWidth,
  });

  EdgeInsetsGeometry get labelMargin {
    return EdgeInsets.only(bottom: rs(context, 6));
  }

  double get labelFontSize => rs(context, 12);
  double get labelLineHeight => rs(context, 16);
  Color get labelColor => isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;

  double get documentPickerContHeight => rs(context, 50);
  Color get documentPickerContBorderColor {
    if (isError) return AppColors.ceriseRed;
    return isDark ? AppColorsDark.borderPrimary : AppColors.borderPrimary;
  }
  double get documentPickerContBorderWidth => isError ? 1.5 : 1;
  Color get documentPickerContBackgroundColor {
    return isDark ? AppColorsDark.bgQuaternary : AppColors.bgQuaternary;
  }
  double get documentPickerContBorderRadius => rs(context, 12);
  EdgeInsetsGeometry get documentPickerContPadding {
    return EdgeInsets.symmetric(horizontal: rs(context, 12));
  }

  double get verticalLineHeight => rs(context, 24);
  double get verticalLineWidth => 1;
  EdgeInsetsGeometry get verticalLineMargin {
    return EdgeInsets.symmetric(horizontal: rs(context, 10));
  }
  Color get verticalLineBackgroundColor => isDark ? AppColorsDark.borderPrimary : AppColors.borderPrimary;

  Color get documentPickerTextColor => isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;
  double get documentPickerTextFontSize => rs(context, 13);

  EdgeInsetsGeometry get errorMargin {
    return EdgeInsets.only(top: rs(context, 4));
  }
  double get errorWidth => double.infinity;
  Color get errorColor => AppColors.ceriseRed;
  double get errorFontSize => rs(context, 11);
  double get errorLineHeight => rs(context, 14);

  EdgeInsetsGeometry get infoMargin {
    return EdgeInsets.only(top: rs(context, 4));
  }
  double get infoWidth => double.infinity;
  Color get infoColor => isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
  double get infoFontSize => rs(context, 11);
  double get infoLineHeight => rs(context, 14);
}
