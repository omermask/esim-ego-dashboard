import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: rs(context, 70),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.btnSecondary : AppColors.btnSecondary,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColorsDark.ifSecondary : AppColors.ifSecondary,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: 'assets/icons/smart_home_icon_241309.svg',
            label: 'Home',
            index: 0,
            isSelected: currentIndex == 0,
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: 'assets/icons/transaction.svg',
            label: 'Transactions',
            index: 1,
            isSelected: currentIndex == 1,
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: 'assets/icons/profile_user.svg',
            label: 'Profile',
            index: 2,
            isSelected: currentIndex == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required bool isDark,
    required String icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: rs(context, 22),
              height: rs(context, 22),
              colorFilter: ColorFilter.mode(
                isSelected
                    ? (isDark
                        ? AppColorsDark.textTertiaryVariant
                        : AppColors.textTertiaryVariant)
                    : (isDark
                        ? AppColorsDark.tabIconUnfocused
                        : AppColors.tabIconUnfocused),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: rs(context, 5)),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Gilroy-Semibold',
                fontSize: rs(context, 10),
                height: rs(context, 12) / rs(context, 10),
                color: isSelected
                    ? (isDark
                        ? AppColorsDark.textTertiaryVariant
                        : AppColors.textTertiaryVariant)
                    : (isDark
                        ? AppColorsDark.tabIconUnfocused
                        : AppColors.tabIconUnfocused),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

