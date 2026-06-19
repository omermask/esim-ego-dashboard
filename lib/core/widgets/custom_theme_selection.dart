import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/custom_theme_selection_style.dart';
import '../widgets/custom_rectangle.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class CustomThemeSelection extends StatefulWidget {
  final String theme;
  final VoidCallback onPress;
  final bool isChecked;
  final double? fixedWidth;

  const CustomThemeSelection({
    super.key,
    required this.theme,
    required this.onPress,
    this.isChecked = false,
    this.fixedWidth,
  });

  @override
  State<CustomThemeSelection> createState() => _CustomThemeSelectionState();
}

class _CustomThemeSelectionState extends State<CustomThemeSelection> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final styles = CustomThemeSelectionStyle(
      context: context,
      isDark: isDark,
      theme: widget.theme,
      fixedWidth: widget.fixedWidth,
      isChecked: widget.isChecked,
    );

    return GestureDetector(
      onTap: widget.onPress,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final dimensions = availableWidth - rs(context, 70);

          return Container(
            width: styles.containerWidth,
            decoration: BoxDecoration(
              border: Border.all(
                color: styles.containerBorderColor,
                width: 1,
              ),
              color: styles.containerBackgroundColor,
              borderRadius: BorderRadius.circular(styles.containerBorderRadius),
            ),
            padding: styles.containerPadding,
            margin: EdgeInsets.only(right: rs(context, 15)),
            child: Row(
              children: [
                SizedBox(
                  width: styles.checkboxSize,
                  child: Container(
                    width: styles.selectionBorderSize,
                    height: styles.selectionBorderSize,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: styles.selectionBorderColor,
                        width: styles.selectionBorderWidth,
                      ),
                      borderRadius:
                          BorderRadius.circular(styles.selectionBorderRadius),
                    ),
                    child: widget.isChecked
                        ? SvgPicture.asset(
                            'assets/icons/tick_circle_icon_241974.svg',
                            colorFilter: const ColorFilter.mode(
                              AppColors.cornflowerBlue,
                              BlendMode.srcIn,
                            ),
                          )
                        : null,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: styles.themeContainerMarginTop,
                      bottom: styles.themeContainerMarginBottom,
                      left: styles.themeContainerMarginLeft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: styles.mb5),
                          child: CustomRectangle(
                            width: dimensions / 1.8,
                            height: 12,
                            bgColor: AppColors.cornflowerBlue,
                            radius: 4,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: styles.mb6),
                          child: CustomRectangle(
                            width: dimensions / 3 - rs(context, 3),
                            height: 6,
                            bgColor: AppColors.sunshade,
                            radius: 3,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              bottom: styles.middleContMarginBottom),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomRectangle(
                                width: dimensions / 3 - rs(context, 3),
                                height: 17,
                                bgColor: widget.theme == 'light'
                                    ? AppColors.snuff
                                    : AppColors.gunPowder,
                                radius: 3,
                              ),
                              CustomRectangle(
                                width: dimensions / 3 - rs(context, 3),
                                height: 17,
                                bgColor: widget.theme == 'light'
                                    ? AppColors.snuff
                                    : AppColors.gunPowder,
                                radius: 3,
                              ),
                              CustomRectangle(
                                width: dimensions / 3 - rs(context, 3),
                                height: 17,
                                bgColor: widget.theme == 'light'
                                    ? AppColors.snuff
                                    : AppColors.gunPowder,
                                radius: 3,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: styles.mb4),
                          child: CustomRectangle(
                            width: dimensions,
                            height: 3,
                            bgColor: widget.theme == 'light'
                                ? AppColors.mischka
                                : AppColors.stormGray,
                            radius: 4,
                          ),
                        ),
                        CustomRectangle(
                          width: dimensions,
                          height: 3,
                          bgColor: widget.theme == 'light'
                              ? AppColors.mischka
                              : AppColors.stormGray,
                          radius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
