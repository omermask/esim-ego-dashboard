import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class ActionCard extends StatelessWidget {
  final Widget? icon;
  final String text;
  final VoidCallback? onPress;
  final double? fixedWidth;
  final Color? iconColor;
  final List<Color>? gradientColors;

  const ActionCard({
    super.key,
    this.icon,
    required this.text,
    this.onPress,
    this.fixedWidth,
    this.iconColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = gradientColors ?? [
      AppColors.cornflowerBlue,
      AppColors.cornflowerBlue.withValues(alpha: 0.7)
    ];
    final iconBgColor = iconColor ?? AppColors.cornflowerBlue;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(rs(context, 14)),
      child: InkWell(
        onTap: onPress,
        borderRadius: BorderRadius.circular(rs(context, 14)),
        splashColor: colors[0].withValues(alpha: 0.1),
        highlightColor: colors[0].withValues(alpha: 0.05),
        child: Container(
          width: fixedWidth ?? double.infinity,
          padding: EdgeInsets.all(rs(context, 16)),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.bgQuaternary : AppColors.bgQuaternary,
            borderRadius: BorderRadius.circular(rs(context, 14)),
            border: Border.all(
              color: isDark
                  ? AppColorsDark.borderPrimary
                  : AppColors.borderPrimary,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.bastille.withValues(alpha: 0.2)
                    : AppColors.bastille.withValues(alpha: 0.05),
                blurRadius: rs(context, 10),
                offset: Offset(0, rs(context, 3)),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (icon != null)
                Container(
                  width: rs(context, 52),
                  height: rs(context, 52),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    borderRadius: BorderRadius.circular(rs(context, 12)),
                    boxShadow: [
                      BoxShadow(
                        color: iconBgColor.withValues(alpha: 0.3),
                        blurRadius: rs(context, 8),
                        offset: Offset(0, rs(context, 2)),
                      ),
                    ],
                  ),
                  child: Center(child: icon!),
                ),
              if (icon != null) SizedBox(height: rs(context, 14)),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  fontSize: rs(context, 15),
                  height: 1.2,
                  color: isDark
                      ? AppColorsDark.textPrimary
                      : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

