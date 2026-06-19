import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class CardInfoStyle {
  final BuildContext context;
  final bool isDark;
  final Color? successColor;
  final double? paddingH;
  final double? layout;
  final bool last;
  final bool copy;

  CardInfoStyle({
    required this.context,
    required this.isDark,
    this.successColor,
    this.paddingH,
    this.layout,
    this.last = false,
    this.copy = false,
  });

  EdgeInsetsGeometry get infoCont {
    return EdgeInsets.fromLTRB(
      paddingH ?? rs(context, 16),
      rs(context, 12),
      paddingH ?? rs(context, 16),
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

  TextStyle get text {
    return TextStyle(
      color: successColor ?? (isDark ? AppColorsDark.textPrimary : AppColors.textPrimary),
      fontSize: rs(context, 13),
      fontWeight: FontWeight.w600,
    );
  }
}
