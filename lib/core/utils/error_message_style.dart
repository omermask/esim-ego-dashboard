import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class ErrorMessageStyle {
  final BuildContext context;
  final Color? bg;
  final bool isDark;

  ErrorMessageStyle({
    required this.context,
    this.bg,
    required this.isDark,
  });

  EdgeInsetsGeometry get padding {
    return EdgeInsets.all(rs(context, 12));
  }

  Color get backgroundColor {
    return bg ?? (isDark ? AppColorsDark.bgSecondary : AppColors.bgSecondary);
  }

  TextStyle get textStyle {
    return TextStyle(
      color: AppColors.ceriseRed,
      fontSize: rs(context, 13),
      fontWeight: FontWeight.w500,
    );
  }

  TextAlign get textAlign => TextAlign.center;
}
