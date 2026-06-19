import 'package:flutter/material.dart';
import '../utils/check_wallets_style.dart';
import '../theme/app_colors.dart';

class CheckWallets extends StatelessWidget {
  final Color? bg;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final Color? leftIconBg;
  final Color? rightIconBg;
  final String? headerText;
  final String? mainText;
  final Color? mainTextColor;
  final VoidCallback? onPress;
  final BoxDecoration? style;

  const CheckWallets({
    super.key,
    this.bg,
    this.leftIcon,
    this.rightIcon,
    this.leftIconBg,
    this.rightIconBg,
    this.headerText,
    this.mainText,
    this.mainTextColor,
    this.onPress,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final checkWalletsStyle = CheckWalletsStyle(
      context: context,
      isDark: isDark,
      bg: bg,
      rightIconBg: rightIconBg,
      leftIconBg: leftIconBg,
      mainTextColor: mainTextColor,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(checkWalletsStyle.containerBorderRadius),
      ),
      clipBehavior: checkWalletsStyle.containerClipBehavior,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPress,
          splashColor: AppColors.gunPowder.withValues(alpha: 0.3),
          highlightColor: AppColors.gunPowder.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(checkWalletsStyle.cardBorderRadius),
          child: Container(
            decoration: (style ??
                    BoxDecoration(
                      color: checkWalletsStyle.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(checkWalletsStyle.cardBorderRadius),
                    ))
                .copyWith(
              color: checkWalletsStyle.cardBackgroundColor,
              borderRadius: BorderRadius.circular(checkWalletsStyle.cardBorderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leftIcon != null)
                      Container(
                        padding: checkWalletsStyle.leftIconSPadding,
                        decoration: BoxDecoration(
                          color: checkWalletsStyle.leftIconSBackgroundColor,
                          borderRadius: BorderRadius.circular(checkWalletsStyle.leftIconSBorderRadius),
                        ),
                        child: leftIcon,
                      ),
                    Container(
                      margin: checkWalletsStyle.textContainerMargin,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (headerText != null && headerText!.isNotEmpty)
                            Text(
                              headerText!,
                              style: TextStyle(
                                color: checkWalletsStyle.headerTextSColor,
                                fontFamily: 'Gilroy-Medium',
                                fontSize: checkWalletsStyle.headerTextSFontSize,
                                height: checkWalletsStyle.headerTextSLineHeight / checkWalletsStyle.headerTextSFontSize,
                              ),
                            ),
                          if (mainText != null && mainText!.isNotEmpty)
                            Text(
                              mainText!,
                              style: TextStyle(
                                color: checkWalletsStyle.mainTextSColor,
                                fontFamily: 'Gilroy-Semibold',
                                fontSize: checkWalletsStyle.mainTextSFontSize,
                                height: checkWalletsStyle.mainTextSLineHeight / checkWalletsStyle.mainTextSFontSize,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (rightIcon != null)
                  Container(
                    padding: checkWalletsStyle.rightIconSPadding,
                    decoration: checkWalletsStyle.rightIconSBackgroundColor != null
                        ? BoxDecoration(
                            color: checkWalletsStyle.rightIconSBackgroundColor,
                            borderRadius: BorderRadius.circular(checkWalletsStyle.rightIconSBorderRadius),
                          )
                        : null,
                    child: rightIcon,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

