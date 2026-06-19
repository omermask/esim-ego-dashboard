import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class BottomInfoStyle {
  final BuildContext context;
  final bool isDark;
  final Color? success;
  final bool note;
  final double? layout;
  final String? text;
  final bool last;
  final bool copy;

  BottomInfoStyle({
    required this.context,
    required this.isDark,
    this.success,
    this.note = false,
    this.layout,
    this.text,
    this.last = false,
    this.copy = false,
  });

  EdgeInsetsGeometry get infoCont {
    return EdgeInsets.fromLTRB(
      rs(context, 16),
      rs(context, note ? 8 : 16),
      rs(context, 16),
      rs(context, last ? 12 : 16),
    );
  }

  BoxDecoration get infoContBorder {
    return BoxDecoration(
      border: last
          ? null
          : Border(
              bottom: BorderSide(
                color: isDark ? AppColorsDark.borderPrimary : AppColors.borderPrimary,
                width: 1,
              ),
            ),
    );
  }

  double? get titleWidth => layout;
  double? get textContParentWidth => layout;

  TextStyle get title {
    return TextStyle(
      color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
      fontSize: rs(context, 11),
      fontWeight: FontWeight.w500,
    );
  }

  EdgeInsetsGeometry get textMargin {
    return EdgeInsets.only(left: rs(context, 6));
  }

  TextStyle get textStyle {
    return TextStyle(
      color: success ?? (isDark ? AppColorsDark.textPrimary : AppColors.textPrimary),
      fontSize: rs(context, 13),
      fontWeight: FontWeight.w600,
    );
  }

  EdgeInsetsGeometry get emailTextPadding {
    return EdgeInsets.only(right: rs(context, 28), top: rs(context, 4));
  }

  TextStyle get emailText {
    return TextStyle(
      color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
      fontSize: rs(context, 11),
      fontWeight: FontWeight.w400,
    );
  }
}
